//
//  YYMusicPlayer.h
//  MusciPlayer
//
//  Created by Yang Yu on 2017/12/23.
//  Copyright © 2017年 Yang Yu. All rights reserved.
//  音乐播放器

#import <Foundation/Foundation.h>

/**
 * 播放器的状态
 * 因为UI界面需要加载状态显示, 所以需要提供加载状态
 - YYMusicPlayerStateUnknown: 未知(比如都没有开始播放音乐)
 - YYMusicPlayerStateLoading: 正在加载()
 - YYMusicPlayerStatePlaying: 正在播放
 - YYMusicPlayerStateStopped: 停止
 - YYMusicPlayerStatePause:   暂停
 - YYMusicPlayerStateFailed:  失败(比如没有网络缓存失败, 地址找不到)
 */
typedef NS_ENUM(NSInteger, YYMusicPlayerState) {
    YYMusicPlayerStateUnknown   = 0,
    YYMusicPlayerStateLoading   = 1,
    YYMusicPlayerStatePlaying   = 2,
    YYMusicPlayerStateStopped   = 3,
    YYMusicPlayerStatePause     = 4,
    YYMusicPlayerStateFailed    = 5
};


@interface YYMusicPlayer : NSObject

/// 单例
+ (instancetype)shareInstance;

#pragma mark- Action

/// 播放URL
- (void)playWithURL:(NSURL *)url;
/// 暂停
- (void)pause;
/// 继续
- (void)resume;
/// 停止
- (void)stop;
/// 设置快进或者快退
- (void)seekWithTimeDiffer:(NSTimeInterval)timeDiffer;
/// 设置进度0~1
- (void)seekWithProgress:(float)progress;


#pragma mark- Property

/// 当前播放器的状态
@property (nonatomic, assign, readonly) YYMusicPlayerState state;
/// 当前是否正在播放
@property (nonatomic, assign, readonly) BOOL isPlaying;


/// 静音
@property (nonatomic, assign) BOOL muted;
/// 音量
@property (nonatomic, assign) float volume;
/// 速率
@property (nonatomic, assign) float rate;

/// 总时长
@property (nonatomic, assign, readonly) NSTimeInterval totalTime;
/// 总时长格式化字符串
@property (nonatomic, assign, readonly) NSString *totalTimeFormat;

/// 当前播放时长
@property (nonatomic, assign, readonly) NSTimeInterval currentTime;
/// 当前播放时长字符串
@property (nonatomic, assign, readonly) NSString *currentTimeFormat;


/// 播放进度
@property (nonatomic, assign, readonly) float progress;
/// URL
@property (nonatomic, strong, readonly) NSURL *url;
/// 加载数据的进度
@property (nonatomic, assign, readonly) float loadDataProgress;



@end
