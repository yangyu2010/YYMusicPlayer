//
//  YYMusicPlayer.m
//  MusciPlayer
//
//  Created by Yang Yu on 2017/12/23.
//  Copyright © 2017年 Yang Yu. All rights reserved.
//

#import "YYMusicPlayer.h"
#import <AVFoundation/AVFoundation.h>

@interface YYMusicPlayer ()

/// AVPlayer
@property (nonatomic, strong) AVPlayer *player;

/// 是否是用户手动暂停, 优先级最高
@property (nonatomic, assign) BOOL isUserPause;

@end

@implementation YYMusicPlayer

#pragma mark- 单例

static YYMusicPlayer *_shareInstance;
+ (instancetype)shareInstance {
    if (!_shareInstance) {
        _shareInstance = [[YYMusicPlayer alloc] init];
    }
    
    return _shareInstance;
}

+ (instancetype)allocWithZone:(struct _NSZone *)zone {
    if (!_shareInstance) {
        static dispatch_once_t onceToken;
        dispatch_once(&onceToken, ^{
            _shareInstance = [super allocWithZone:zone];
        });
    }
    return _shareInstance;
}


#pragma mark- Property

/// 播放器状态
- (void)setState:(YYMusicPlayerState)state {
    _state = state;
    
    // 更新状态, 可以在这里通知外面
    // 代理 block 通知
}

/// 当前是否正在播放
- (BOOL)isPlaying {
    if (self.state == YYMusicPlayerStateLoading ||
        self.state == YYMusicPlayerStatePlaying) {
        return YES;
    }
    return NO;
}

/// 设置速率set
- (void)setRate:(float)rate {
    [self.player setRate:rate];
}

/// 速率get
- (float)rate {
    return self.player.rate;
}

/// 静音set
- (void)setMuted:(BOOL)muted {
    self.player.muted = muted;
}

/// 静音get
- (BOOL)muted {
    return self.player.muted;
}

/// 音量set
- (void)setVolume:(float)volume {
    if (volume < 0 || volume > 1) {
        return;
    }
    if (volume > 0) {
        [self setMuted:NO];
    }
    
    self.player.volume = volume;
}

/// 音量get
- (float)volume {
    return self.player.volume;
}

/// 总时长
- (NSTimeInterval)totalTime {
    if (!self.player) {
        return 0;
    }
    CMTime totalTime = self.player.currentItem.duration;
    NSTimeInterval totoalSec = CMTimeGetSeconds(totalTime);
    if (isnan(totoalSec)) {
        return 0;
    }
    return totoalSec;
}

/// 总时长格式化字符串
- (NSString *)totalTimeFormat {
    return [NSString stringWithFormat:@"%02zd:%02zd", (int)self.totalTime / 60, (int)self.totalTime % 60];
}

/// 当前播放时长
- (NSTimeInterval)currentTime {
    if (!self.player) {
        return 0;
    }
    CMTime currentTime = self.player.currentItem.currentTime;
    NSTimeInterval currentSec = CMTimeGetSeconds(currentTime);
    if (isnan(currentSec)) {
        return 0;
    }
    return currentSec;
}

/// 当前播放时长字符串
- (NSString *)currentTimeFormat {
    return [NSString stringWithFormat:@"%02zd:%02zd", (int)self.currentTime / 60, (int)self.currentTime % 60];
}

/// 播放进度
- (float)progress {
    if (self.totalTime == 0) {
        return 0;
    }
    return self.currentTime / self.totalTime;
}

/// 加载数据的进度
- (float)loadDataProgress {
    if (self.totalTime == 0) {
        return 0;
    }
    CMTimeRange timeRange = [[self.player.currentItem loadedTimeRanges].lastObject CMTimeRangeValue];
    CMTime loadTime = CMTimeAdd(timeRange.start, timeRange.duration);
    NSTimeInterval loadTimeSec = CMTimeGetSeconds(loadTime);
    return loadTimeSec / self.totalTime;
}


#pragma mark- Action

/// 播放URL
- (void)playWithURL:(NSURL *)url {
//    [AVPlayer playerWithURL:url];
    
    if (url == nil) {
        return ;
    }
    
    NSURL *currentURL = [(AVURLAsset *)self.player.currentItem.asset URL];
    if ([url isEqual:currentURL]) {
        NSLog(@"当前播放任务已经存在了");
        [self resume];
        return;
    }
    
    _url = url;
    
    // 1.资源的请求
    AVURLAsset *asset = [AVURLAsset assetWithURL:url];
    
    // 2.1先移除再添加
    [self removeObserver];
    
    // 2.资源的组织
    AVPlayerItem *item = [AVPlayerItem playerItemWithAsset:asset];
    
    // 当资源的组织者, 告诉我们资源准备好了之后, 我们再播放
    // KVO 监听 AVPlayerItemStatus status
    [item addObserver:self forKeyPath:@"status" options:NSKeyValueObservingOptionNew context:nil];
    // playbackLikelyToKeepUp
    [item addObserver:self forKeyPath:@"playbackLikelyToKeepUp" options:NSKeyValueObservingOptionNew context:nil];

    // KVC
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(playEnd) name:AVPlayerItemDidPlayToEndTimeNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(playInterrupt) name:AVPlayerItemPlaybackStalledNotification object:nil];
    
    
    // 3.资源的播放
    self.player = [AVPlayer playerWithPlayerItem:item];
}

/// 暂停
- (void)pause {
    if (!self.isPlaying) {
        return ;
    }
    
    _isUserPause = YES;
    [self.player pause];
    if (self.player) {
        self.state = YYMusicPlayerStatePause;
    }
}

/// 继续
- (void)resume {
    [self.player play];
    /// 就是代表,当前播放器存在, 并且, 数据组织者里面的数据准备, 已经足够播放了
    /// readonly 通过KVO监听
    if (self.player && self.player.currentItem.playbackLikelyToKeepUp) {
        self.state = YYMusicPlayerStatePlaying;
    }
    _isUserPause = NO;
}

/// 停止
- (void)stop {
    [self.player pause];
    self.player = nil;
    if (self.player) {
        self.state = YYMusicPlayerStateStopped;
    }
}

/// 设置快进或者快退 负数就是后退
- (void)seekWithTimeDiffer:(NSTimeInterval)timeDiffer {
    
    // 1.获取当前播放到哪里了
    CMTime currentTime = self.player.currentItem.currentTime;
    NSTimeInterval currentSec = CMTimeGetSeconds(currentTime);
    
    // 2.+ - 时长
    currentSec += timeDiffer;
    CMTime needSetTime = CMTimeMake(currentSec, 1);  // NSEC_PER_SEC 1 NSEC_PER_SEC*1
    
    
    // 3.设置进度
    [self.player seekToTime:needSetTime completionHandler:^(BOOL finished) {
        if (finished) {
//            NSLog(@"确定加载这个时间点的音频资源");
        } else {
//            NSLog(@"取消加载这个时间点的音频资源");
        }
    }];
}

/// 设置进度0~1
- (void)seekWithProgress:(float)progress {
    if (progress < 0 || progress > 1) {
        return;
    }
    
    // 1.总时长
    CMTime totalTime = self.player.currentItem.duration;
    NSTimeInterval totoalSec = CMTimeGetSeconds(totalTime);
    
    // 2.获取当前需要调整到哪个时间
    NSTimeInterval currentSec = totoalSec * progress;
    CMTime currentTime = CMTimeMake(currentSec, 1);
    
    // 3.设置进度
    [self.player seekToTime:currentTime completionHandler:^(BOOL finished) {
        if (finished) {
//            NSLog(@"确定加载这个时间点的音频资源");
        } else {
//            NSLog(@"取消加载这个时间点的音频资源");
        }
    }];
}

#pragma mark- Private
/// 播放结束后的通知回调, 可用于自动播放下一首
- (void)playEnd {
    NSLog(@"播放完毕");
    self.state = YYMusicPlayerStateStopped;
}

/// 播放被打断
/// 可能是来电话等
/// 资源加载跟不上, 网络卡
- (void)playInterrupt {
    NSLog(@"播放被打断");
    [self pause];
}

#pragma mark - KVO

/// An instance 0x15e572de0 of class AVPlayerItem was deallocated while key value observers were still registered with it.
/// 对象销毁前 要移除KVO
- (void)removeObserver {
    if (self.player.currentItem) {
        [self.player.currentItem removeObserver:self forKeyPath:@"status"];
        [self.player.currentItem removeObserver:self forKeyPath:@"playbackLikelyToKeepUp"];
        
    }
}

/// KVO回调
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context {
    
    // 第一次AVPlayer资源准备好的时候会更新 status
    // 当用户拖动进度slider 这个时候更新playbackLikelyToKeepUp
    
    if ([keyPath isEqualToString:@"status"]) {
        AVPlayerItemStatus status = [change[NSKeyValueChangeNewKey] integerValue];
        if (status == AVPlayerItemStatusReadyToPlay) {
            NSLog(@"资源准备好了, 这时候播放就没有问题");
            [self resume];
        }else {
            NSLog(@"状态未知");
            self.state = YYMusicPlayerStateFailed;
        }
    } else if ([keyPath isEqualToString:@"playbackLikelyToKeepUp"]) {
        if ([change[NSKeyValueChangeNewKey] boolValue]) {
            NSLog(@"当前的资源, 准备的已经足够播放了");
            // 如果用户点击了暂停, 不用处理, 没有点击, 直接播放
            if (!_isUserPause) {
                [self resume];
            }
        } else {
            NSLog(@"资源还不够, 还在加载中...");
            self.state = YYMusicPlayerStateLoading;
        }
    }
    
}

#pragma mark- Dealloc
- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

@end
