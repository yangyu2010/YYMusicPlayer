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
/// 设置倍速
- (void)setRate:(float)rate;
/// 静音
- (void)setMuted:(BOOL)muted;
/// 音量
- (void)setVolume:(float)volume;

@end
