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

@property (nonatomic, strong) AVPlayer *player;

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

#pragma mark- Public

/// 播放URL
- (void)playWithURL:(NSURL *)url {
//    [AVPlayer playerWithURL:url];
    
    // 1.资源的请求
    AVURLAsset *asset = [AVURLAsset assetWithURL:url];
    
    // 2.资源的组织
    AVPlayerItem *item = [AVPlayerItem playerItemWithAsset:asset];
    
    // 当资源的组织者, 告诉我们资源准备好了之后, 我们再播放
    // KVO 监听 AVPlayerItemStatus status
    [item addObserver:self forKeyPath:@"status" options:NSKeyValueObservingOptionNew context:nil];
    
    // 3.资源的播放
    self.player = [AVPlayer playerWithPlayerItem:item];
}

/// 暂停
- (void)pause {
    [self.player pause];
}

/// 继续
- (void)resume {
    [self.player play];
}

/// 停止
- (void)stop {
    [self.player pause];
    self.player = nil;
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
            NSLog(@"确定加载这个时间点的音频资源");
        } else {
            NSLog(@"取消加载这个时间点的音频资源");
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
            NSLog(@"确定加载这个时间点的音频资源");
        } else {
            NSLog(@"取消加载这个时间点的音频资源");
        }
    }];
}

/// 设置倍速
- (void)setRate:(float)rate {
    [self.player setRate:rate];
}

/// 静音
- (void)setMuted:(BOOL)muted {
    self.player.muted = muted;
}

/// 音量
- (void)setVolume:(float)volume {
    if (volume < 0 || volume > 1) {
        return;
    }
    if (volume > 0) {
        [self setMuted:NO];
    }
    
    self.player.volume = volume;
}


#pragma mark - KVO

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context {
    
    if ([keyPath isEqualToString:@"status"]) {
        AVPlayerItemStatus status = [change[NSKeyValueChangeNewKey] integerValue];
        if (status == AVPlayerItemStatusReadyToPlay) {
            NSLog(@"资源准备好了, 这时候播放就没有问题");
            [self.player play];
        }else {
            NSLog(@"状态未知");
        }
    }
    
}



@end
