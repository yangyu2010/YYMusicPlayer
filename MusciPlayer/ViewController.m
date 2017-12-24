//
//  ViewController.m
//  MusciPlayer
//
//  Created by Yang Yu on 2017/12/23.
//  Copyright © 2017年 Yang Yu. All rights reserved.
//

#import "ViewController.h"
#import "YYMusicPlayer.h"

@interface ViewController ()

@property (weak, nonatomic) IBOutlet UILabel *playTimeLabel;
@property (weak, nonatomic) IBOutlet UILabel *totalTimeLabel;
@property (weak, nonatomic) IBOutlet UISlider *playProgressSlider;
@property (weak, nonatomic) IBOutlet UIButton *btnMuted;
@property (weak, nonatomic) IBOutlet UISlider *volumeSlider;
@property (weak, nonatomic) IBOutlet UIProgressView *loadPV;

@property (nonatomic, strong) NSTimer *timer;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self timer];
}

#pragma mark- Get
- (NSTimer *)timer {
    if (!_timer) {
        _timer = [NSTimer timerWithTimeInterval:1 target:self selector:@selector(uploadPlayInfo) userInfo:nil repeats:YES];
        [[NSRunLoop currentRunLoop] addTimer:_timer forMode:NSRunLoopCommonModes];
    }
    return _timer;
}

#pragma mark- Action

- (IBAction)play:(id)sender {
    
//    // 本地音乐
//    NSString *path = [[NSBundle mainBundle] pathForResource:@"test123" ofType:@"m4a"];
//    NSURL *url = [NSURL fileURLWithPath:path];
    
    // 远程
    NSURL *url = [NSURL URLWithString:@"http://audio.xmcdn.com/group23/M04/63/C5/wKgJNFg2qdLCziiYAGQxcTOSBEw402.m4a"];
    [[YYMusicPlayer shareInstance] playWithURL:url];
}

- (IBAction)pause:(id)sender {
    [[YYMusicPlayer shareInstance] pause];
}

- (IBAction)resume:(id)sender {
    [[YYMusicPlayer shareInstance] resume];
}

- (IBAction)kuaijin:(id)sender {
    [[YYMusicPlayer shareInstance] seekWithTimeDiffer:15.0];
}

- (IBAction)progress:(UISlider *)sender {
    [[YYMusicPlayer shareInstance] seekWithProgress:sender.value];
}

- (IBAction)rate:(id)sender {
    [[YYMusicPlayer shareInstance] setRate:2];
}

- (IBAction)muted:(UIButton *)sender {
    sender.selected = !sender.selected;
    [[YYMusicPlayer shareInstance] setMuted:sender.selected];
}

- (IBAction)volume:(UISlider *)sender {
    [[YYMusicPlayer shareInstance] setVolume:sender.value];
}


#pragma mark- Private
- (void)uploadPlayInfo {
    
    NSLog(@"state s%zd", [YYMusicPlayer shareInstance].state);
    
    if ([YYMusicPlayer shareInstance].isPlaying) {
        NSLog(@"正在播放");
    } else {
        NSLog(@"没有播放了");
    }
    
    self.playTimeLabel.text =  [YYMusicPlayer shareInstance].currentTimeFormat;
    
    self.totalTimeLabel.text = [YYMusicPlayer shareInstance].totalTimeFormat;
    
    self.playProgressSlider.value = [YYMusicPlayer shareInstance].progress;
    
    self.volumeSlider.value = [YYMusicPlayer shareInstance].volume;
    
    self.loadPV.progress = [YYMusicPlayer shareInstance].loadDataProgress;
    
    self.btnMuted.selected = [YYMusicPlayer shareInstance].muted;
    
}


@end
