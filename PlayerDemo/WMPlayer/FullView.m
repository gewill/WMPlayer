//
//  FullView.m
//  网络视频播放(AVPlayer)
//
//  Created by apple on 15/8/26.
//  Copyright (c) 2015年 FMG. All rights reserved.
//

#import "FullView.h"
#import <Masonry/Masonry.h>

@implementation FullView

- (id)initWithCoder:(NSCoder *)aDecoder
{
    if (self = [super initWithCoder:aDecoder]) {
        [self mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.equalTo(self.superview);
            make.center.equalTo(self.superview);
        }];;
        self.backgroundColor = [UIColor blackColor];
    }
    return self;
}

- (void)dealloc {
    NSLog(@"dealloc FMGVideoPlayView —> FullView");
}

@end
