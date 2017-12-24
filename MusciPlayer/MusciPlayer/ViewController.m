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

@end

@implementation ViewController


- (IBAction)play:(id)sender {
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



@end
