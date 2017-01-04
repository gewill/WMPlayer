/*!
 @header SinaNewsViewController.m
 
 @abstract  作者Github地址：https://github.com/zhengwenming
            作者CSDN博客地址:http://blog.csdn.net/wenmingzheng
 
 @author   Created by zhengwenming on  16/1/19
 
 @version 1.00 16/1/19 Creation(版本信息)
 
   Copyright © 2016年 郑文明. All rights reserved.
 */

#import "SinaNewsViewController.h"
#import <Masonry/Masonry.h>
#import "UIButton+WMPlayer.h"


@interface SinaNewsViewController ()

/**
 *  wmPlayer内部一个UIView，所有的控件统一管理在此view中
 */
@property (nonatomic,strong) UIView        *contentView;

/**
 *  提示视图
 */
@property (nonatomic, strong) UIView *tipView;
/**
 *  提示文字
 */
@property (nonatomic, strong) UILabel *tipTitleLabel;

/**
 *  点赞按钮
 */
@property (nonatomic, strong) UIButton *likeButton;
/**
 *  重播按钮
 */
@property (nonatomic, strong) UIButton *replayButton;
/**
 *  重试按钮
 */
@property (nonatomic, strong) UIButton *retryButton;

@end

@implementation SinaNewsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    //wmplayer内部的一个view，用来管理子视图
    self.contentView = [[UIView alloc]init];
    self.contentView.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:self.contentView];
    //autoLayout contentView
    [self.contentView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.view);
    }];

    
    // 提示视图
    self.tipView = [[UIView alloc] init];
    self.tipView.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.6];
    self.tipView.userInteractionEnabled = YES;
    UITapGestureRecognizer *tipViewSingleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(colseTheVideo:)];
    tipViewSingleTap.numberOfTapsRequired = 1;
    tipViewSingleTap.numberOfTouchesRequired = 1;
    [self.tipView addGestureRecognizer:tipViewSingleTap];
    [self.contentView addSubview:self.tipView];
    [self.tipView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.contentView);
    }];
    
    self.tipTitleLabel = [[UILabel alloc] init];
    self.tipTitleLabel.font = [UIFont systemFontOfSize:14];
    self.tipTitleLabel.textColor = [UIColor whiteColor];
    self.tipTitleLabel.textAlignment = NSTextAlignmentCenter;
    self.tipTitleLabel.text = @"make.centerX.equalTo(self.tipView.mas_centerX);";
    [self.tipView addSubview:self.tipTitleLabel];
    [self.tipTitleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self.tipView.mas_centerX);
        make.top.equalTo(self.tipView.mas_top).with.offset(120);
        make.leading.equalTo(self.tipView.mas_leading).with.offset(14);
        make.trailing.equalTo(self.tipView.mas_trailing).with.offset(14);
    }];
    
    self.replayButton = [UIButton buttonWithType: UIButtonTypeCustom];
    [self.replayButton setImage:[UIImage imageNamed:@"end_replay"] forState:UIControlStateNormal];
    [self.replayButton setTitle:@"重播" forState:UIControlStateNormal];
    [self.replayButton setTintColor:[UIColor whiteColor]];
    self.replayButton.titleLabel.font = [UIFont systemFontOfSize:14];
    self.replayButton.backgroundColor = [UIColor redColor];
    [self.replayButton addTarget:self action:@selector(replayButtonClick:) forControlEvents:UIControlEventTouchUpInside];
    [self.tipView addSubview:self.replayButton];
    [self.replayButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self.tipView.mas_centerX).with.offset(-33);
        make.centerY.equalTo(self.tipView.mas_centerY);
        make.height.equalTo(@200);
        make.width.equalTo(@200);
        
    }];
    [self.replayButton centerVertically];
    
    self.likeButton = [UIButton buttonWithType: UIButtonTypeCustom];
    [self.likeButton setImage:[UIImage imageNamed:@"end_like"] forState:UIControlStateNormal];
    [self.likeButton setTitle:@"点赞" forState:UIControlStateNormal];
    [self.likeButton setTintColor:[UIColor whiteColor]];
    self.likeButton.titleLabel.font = [UIFont systemFontOfSize:14];
    [self.likeButton centerVertically];
    [self.likeButton addTarget:self action:@selector(likeButtonClick:) forControlEvents:UIControlEventTouchUpInside];
    [self.tipView addSubview:self.likeButton];
    [self.likeButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self.tipView.mas_centerX).with.offset(33);
        make.centerY.equalTo(self.tipView.mas_centerY);
    }];
    
    
    self.retryButton = [UIButton buttonWithType: UIButtonTypeCustom];
    [self.retryButton setImage:[UIImage imageNamed:@"end_replay2"] forState:UIControlStateNormal];
    [self.retryButton setTitle:@"重试" forState:UIControlStateNormal];
    [self.retryButton setTintColor:[UIColor whiteColor]];
    self.retryButton.titleLabel.font = [UIFont systemFontOfSize:14];
    [self.retryButton centerVertically];
    [self.retryButton addTarget:self action:@selector(retryButtonClick:) forControlEvents:UIControlEventTouchUpInside];
    [self.tipView addSubview:self.retryButton];
    [self.retryButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self.tipView.mas_centerX);
        make.centerY.equalTo(self.tipView.mas_centerY).with.offset(60);
    }];

}

@end
