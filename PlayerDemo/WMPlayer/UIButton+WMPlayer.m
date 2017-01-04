//
//  UIButton+UIButton_WMPlayer.m
//  PlayerDemo
//
//  Created by Will on 1/3/17.
//  Copyright © 2017 DS-Team. All rights reserved.
//

#import "UIButton+WMPlayer.h"

@implementation UIButton (WMPlayer)

- (void)centerVerticallyWithPadding:(float)padding
{
    CGSize imageSize = self.imageView.frame.size;
    CGSize titleSize = self.titleLabel.frame.size;
    
    CGFloat totalHeight = (imageSize.height + titleSize.height + padding);
    
    self.imageEdgeInsets = UIEdgeInsetsMake(- (totalHeight - imageSize.height),
                                            0.0f,
                                            0.0f,
                                            - titleSize.width);
    
    self.titleEdgeInsets = UIEdgeInsetsMake(0.0f,
                                            - imageSize.width,
                                            - (totalHeight - titleSize.height),
                                            0.0f);
    
}


- (void)centerVertically
{
    const CGFloat kDefaultPadding = 10.0f;
    
    [self centerVerticallyWithPadding:kDefaultPadding];
}  

@end
