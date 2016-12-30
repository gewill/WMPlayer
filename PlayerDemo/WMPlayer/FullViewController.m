//
//  FullViewController.m
//  网络视频播放(AVPlayer)
//
//  Created by apple on 15/8/16.
//  Copyright (c) 2015年 FMG. All rights reserved.
//

#import "FullView.h"
#import "FullViewController.h"

@interface FullViewController ()

@property(nonatomic, unsafe_unretained) BOOL preferHide;

@end

@implementation FullViewController

- (void)loadView {
  FullView *fullView = [[FullView alloc] init];
  self.view = fullView;
}

- (void)viewDidLoad {
  [super viewDidLoad];
}

- (void)dealloc {
    NSLog(@"dealloc FMGVideoPlayView —> FullViewController");
}

- (void)viewWillAppear:(BOOL)animated {
  [super viewWillAppear:animated];
  _preferHide = [[UIApplication sharedApplication] isStatusBarHidden];
  [[UIApplication sharedApplication] setStatusBarHidden:YES];
}

- (void)viewWillDisappear:(BOOL)animated {
  [super viewWillDisappear:animated];

  [[UIApplication sharedApplication] setStatusBarHidden:_preferHide];
}

- (UIInterfaceOrientationMask)supportedInterfaceOrientations {
  return UIInterfaceOrientationMaskPortrait;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:
    (UIInterfaceOrientation)toInterfaceOrientation {
  return YES;
}

- (BOOL)prefersStatusBarHidden {
  return YES;
}

@end
