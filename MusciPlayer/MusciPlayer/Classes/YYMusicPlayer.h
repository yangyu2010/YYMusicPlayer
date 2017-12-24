//
//  YYMusicPlayer.h
//  MusciPlayer
//
//  Created by Yang Yu on 2017/12/23.
//  Copyright © 2017年 Yang Yu. All rights reserved.
//  音乐播放器

#import <Foundation/Foundation.h>

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

/// 静音
@property (nonatomic, assign) BOOL muted;
/// 音量
@property (nonatomic, assign) float volume;
/// 速率
@property (nonatomic, assign) float rate;

/// 总时长
@property (nonatomic, assign, readonly) NSTimeInterval totalTime;
/// 总时长格式化字符串
@property (nonatomic, copy, readonly) NSString *totalTimeFormat;

/// 当前播放时长
@property (nonatomic, assign, readonly) NSTimeInterval currentTime;
/// 当前播放时长字符串
@property (nonatomic, copy, readonly) NSString *currentTimeFormat;


/// 播放进度
@property (nonatomic, assign, readonly) float progress;
/// URL
@property (nonatomic, strong, readonly) NSURL *url;
/// 加载数据的进度
@property (nonatomic, assign, readonly) float loadDataProgress;



@end
