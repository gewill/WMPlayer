//
//  WMFullViewController.m
//  网络视频播放(AVPlayer)
//
//  Created by apple on 15/8/16.
//  Copyright (c) 2015年 FMG. All rights reserved.
//

#import "WMFullView.h"
#import "WMFullViewController.h"

@interface WMFullViewController ()

@property(nonatomic, unsafe_unretained) BOOL preferHide;

@end

@implementation WMFullViewController

- (void)loadView {
  WMFullView *fullView = [[WMFullView alloc] init];
  self.view = fullView;
}

- (void)viewDidLoad {
  [super viewDidLoad];
    
}

- (void)dealloc {
    NSLog(@"dealloc FMGVideoPlayView —> WMFullViewController");
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
  return UIInterfaceOrientationMaskAllButUpsideDown;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:
    (UIInterfaceOrientation)toInterfaceOrientation {
  return YES;
}

- (BOOL)prefersStatusBarHidden {
  return YES;
}



@end
