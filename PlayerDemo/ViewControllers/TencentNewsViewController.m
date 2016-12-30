/*!
 @header TencentNewsViewController.m
 
 @abstract  作者Github地址：https://github.com/zhengwenming
 作者CSDN博客地址:http://blog.csdn.net/wenmingzheng
 
 @author   Created by zhengwenming on  16/1/19
 
 @version 1.00 16/1/19 Creation(版本信息)
 
 Copyright © 2016年 郑文明. All rights reserved.
 */

#import "TencentNewsViewController.h"
#import "SidModel.h"
#import "VideoCell.h"
#import "VideoModel.h"
#import "WMPlayer.h"
#import "DetailViewController.h"
#import "AppDelegate.h"
#import "MJRefresh.h"
#import <Masonry.h>
#import "FullViewController.h"


@interface TencentNewsViewController ()<UITableViewDelegate,UITableViewDataSource,UIScrollViewDelegate,WMPlayerDelegate>{
    NSMutableArray *dataSource;
    WMPlayer *wmPlayer;
    NSIndexPath *currentIndexPath;
    BOOL isSmallScreen;
}
@property(nonatomic,retain)VideoCell *currentCell;



@end

@implementation TencentNewsViewController
- (instancetype)init{
    self = [super init];
    if (self) {
        dataSource = [NSMutableArray array];
        isSmallScreen = NO;
    }
    return self;
}
-(BOOL)prefersStatusBarHidden{
    if (wmPlayer) {
        if (wmPlayer.isFullscreen) {
            return YES;
        }else{
            return NO;
        }
    }else{
        return NO;
    }
}




#pragma mark - life cycle

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.table.delegate = self;
    self.table.dataSource = self;
    
    self.table.remembersLastFocusedIndexPath = YES;
    
    [self.table registerNib:[UINib nibWithNibName:@"VideoCell" bundle:nil] forCellReuseIdentifier:@"VideoCell"];
    [self addMJRefresh];
    
    [self performSelector:@selector(loadData) withObject:nil afterDelay:1.0];
}
-(void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
}

-(void)loadData{
    [dataSource addObjectsFromArray:[AppDelegate shareAppDelegate].videoArray];
    [self.table reloadData];
    [self handleScroll];
    
}
-(void)addMJRefresh{
    __weak __typeof(&*self)weakSelf = self;
    __unsafe_unretained UITableView *tableView = self.table;
    // 下拉刷新
    tableView.mj_header= [MJRefreshNormalHeader headerWithRefreshingBlock:^{
        [weakSelf addHudWithMessage:@"加载中..."];
        [[DataManager shareManager] getSIDArrayWithURLString:@"http://c.m.163.com/nc/video/home/0-10.html"
                                                     success:^(NSArray *sidArray, NSArray *videoArray) {
                                                         dataSource =[NSMutableArray arrayWithArray:videoArray];
                                                         dispatch_async(dispatch_get_main_queue(), ^{
                                                             if (currentIndexPath.row>dataSource.count) {
                                                                 [weakSelf releaseWMPlayer];
                                                             }
                                                             [weakSelf removeHud];
                                                             [tableView reloadData];
                                                             [tableView.mj_header endRefreshing];
                                                         });
                                                     }
                                                      failed:^(NSError *error) {
                                                          [weakSelf removeHud];
                                                          
                                                      }];
        
    }];
    
    
    // 设置自动切换透明度(在导航栏下面自动隐藏)
    tableView.mj_header.automaticallyChangeAlpha = YES;
    // 上拉刷新
    tableView.mj_footer = [MJRefreshBackNormalFooter footerWithRefreshingBlock:^{
        NSString *URLString = [NSString stringWithFormat:@"http://c.m.163.com/nc/video/home/%ld-10.html",dataSource.count - dataSource.count%10];
        [weakSelf addHudWithMessage:@"加载中..."];
        [[DataManager shareManager] getSIDArrayWithURLString:URLString
                                                     success:^(NSArray *sidArray, NSArray *videoArray) {
                                                         [dataSource addObjectsFromArray:videoArray];
                                                         dispatch_async(dispatch_get_main_queue(), ^{
                                                             [weakSelf removeHud];
                                                             [tableView reloadData];
                                                             [tableView.mj_header endRefreshing];
                                                         });
                                                         
                                                     }
                                                      failed:^(NSError *error) {
                                                          [weakSelf removeHud];
                                                          
                                                      }];
        // 结束刷新
        [tableView.mj_footer endRefreshing];
    }];
    
    
}

#pragma mark - UITableViewDelegate

-(NSInteger )numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}
-(NSInteger )tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return dataSource.count;
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 274;
}
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *identifier = @"VideoCell";
    VideoCell *cell = (VideoCell *)[tableView dequeueReusableCellWithIdentifier:identifier];
    cell.model = [dataSource objectAtIndex:indexPath.row];
    [cell.playBtn addTarget:self action:@selector(startPlayVideo:) forControlEvents:UIControlEventTouchUpInside];
    cell.playBtn.tag = indexPath.row;
    
    
    if (wmPlayer&&wmPlayer.superview) {
        if (indexPath.row==currentIndexPath.row) {
            [cell.playBtn.superview sendSubviewToBack:cell.playBtn];
        }else{
            [cell.playBtn.superview bringSubviewToFront:cell.playBtn];
        }
        NSArray *indexpaths = [tableView indexPathsForVisibleRows];
        if (![indexpaths containsObject:currentIndexPath]&&currentIndexPath!=nil) {//复用
            
            if ([[UIApplication sharedApplication].keyWindow.subviews containsObject:wmPlayer]) {
                wmPlayer.hidden = NO;
            }else{
                wmPlayer.hidden = YES;
                [cell.playBtn.superview bringSubviewToFront:cell.playBtn];
            }
        }else{
            if ([cell.backgroundIV.subviews containsObject:wmPlayer]) {
                [cell.backgroundIV addSubview:wmPlayer];
                
                [wmPlayer play];
                wmPlayer.hidden = NO;
            }
            
        }
    }
    
    
    return cell;
}


-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{

}

#pragma mark - WMPlayerDelegate
///播放器事件
-(void)wmplayer:(WMPlayer *)wmplayer clickedCloseButton:(UIButton *)closeBtn{
    NSLog(@"didClickedCloseButton");
    [wmplayer play];
    
}
-(void)wmplayer:(WMPlayer *)wmplayer clickedFullScreenButton:(UIButton *)fullScreenBtn{
    if (fullScreenBtn.isSelected) {//全屏显示
        wmPlayer.isFullscreen = YES;
        [self setNeedsStatusBarAppearanceUpdate];
        [self toFullScreenWithInterfaceOrientation:UIInterfaceOrientationLandscapeLeft];
    }else{
        [self toCell];
        
    }
}
-(void)wmplayer:(WMPlayer *)wmplayer singleTaped:(UITapGestureRecognizer *)singleTap{
    NSLog(@"didSingleTaped");
//    [self.table deselectRowAtIndexPath:currentIndexPath animated:YES];
//    VideoModel *   model = [dataSource objectAtIndex:currentIndexPath.row];
//    
//    DetailViewController *detailVC = [[DetailViewController alloc]init];
//    detailVC.URLString  = model.m3u8_url;
//    detailVC.title = model.title;
//
//    [self.navigationController pushViewController:detailVC animated:YES];
    
}
-(void)wmplayer:(WMPlayer *)wmplayer doubleTaped:(UITapGestureRecognizer *)doubleTap{
    NSLog(@"didDoubleTaped");
}

///播放状态
-(void)wmplayerFailedPlay:(WMPlayer *)wmplayer WMPlayerStatus:(WMPlayerState)state{
    NSLog(@"wmplayerDidFailedPlay");
}
-(void)wmplayerReadyToPlay:(WMPlayer *)wmplayer WMPlayerStatus:(WMPlayerState)state{
    NSLog(@"wmplayerDidReadyToPlay");
}
-(void)wmplayerFinishedPlay:(WMPlayer *)wmplayer{
    NSLog(@"wmplayerDidFinishedPlay");
    VideoCell *currentCell = (VideoCell *)[self.table cellForRowAtIndexPath:[NSIndexPath indexPathForRow:currentIndexPath.row inSection:0]];
    [currentCell.playBtn.superview bringSubviewToFront:currentCell.playBtn];
    [self releaseWMPlayer];
    [self setNeedsStatusBarAppearanceUpdate];
}




#pragma mark - 播放时机


//规则是：当tableView滑动的时候，我会播放可见cell中，最靠近屏幕中心的那个cell的视频。
-(void)handleScroll{

    // 找到下一个要播放的cell(最在屏幕中心的)
    VideoCell *finnalCell = nil;
    NSArray *visiableCells = [self.table visibleCells];
    NSMutableArray *indexPaths = [NSMutableArray array];
    CGFloat gap = MAXFLOAT;
    for (VideoCell *cell in visiableCells) {

        [indexPaths addObject:[self.table indexPathForCell:cell]];

        if (![cell.model.mp4_url  isEqual: @""]) { // 如果这个cell有视频
            CGPoint coorCentre = [cell.superview convertPoint:cell.center toView:nil];
            CGFloat delta = fabs(coorCentre.y-[UIScreen mainScreen].bounds.size.height*0.5);
            if (delta < gap) {
                gap = delta;
                finnalCell = cell;
            }
        }
    }

    // 注意, 如果正在播放的cell和finnalCell是同一个cell, 不应该再播放
    if (finnalCell != nil && ![[self.table indexPathForCell:finnalCell] isEqual: currentIndexPath])  {
        [self startPlayVideo:finnalCell.playBtn];
        return;
    }

    // TODO: - 再看正在播放视频的那个cell移出视野, 则停止播放
//    BOOL isPlayingCellVisiable = YES;
//    if (![indexPaths containsObject:self.playingCell.indexPath]) {
//        isPlayingCellVisiable = NO;
//    }
//    if (!isPlayingCellVisiable && self.playingCell) {
//        [self stopPlay];
//    }
    
}

// 松手时已经静止,只会调用scrollViewDidEndDragging
- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate{
    if (decelerate == NO) { // scrollView已经完全静止
        [self handleScroll];
    }
}

// 松手时还在运动, 先调用scrollViewDidEndDragging,在调用scrollViewDidEndDecelerating
- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView{
    // scrollView已经完全静止
    [self handleScroll];
}


#pragma mark - player control methods
-(void)startPlayVideo:(UIButton *)sender{
    currentIndexPath = [NSIndexPath indexPathForRow:sender.tag inSection:0];
    NSLog(@"currentIndexPath.row = %ld",currentIndexPath.row);
    if ([UIDevice currentDevice].systemVersion.floatValue>=8||[UIDevice currentDevice].systemVersion.floatValue<7) {
        self.currentCell = (VideoCell *)sender.superview.superview;
    }else{//ios7系统 UITableViewCell上多了一个层级UITableViewCellScrollView
        self.currentCell = (VideoCell *)sender.superview.superview.subviews;
    }
    VideoModel *model = [dataSource objectAtIndex:sender.tag];
    
    //    isSmallScreen = NO;
    if (isSmallScreen) {
        [self releaseWMPlayer];
        isSmallScreen = NO;
        
    }
    if (wmPlayer) {
        [self releaseWMPlayer];
        wmPlayer = [[WMPlayer alloc]initWithFrame:self.currentCell.backgroundIV.bounds];
        wmPlayer.delegate = self;
        wmPlayer.contrainerViewController = self;
        //关闭音量调节的手势
        [wmPlayer hideControls:YES];
        wmPlayer.dragEnable = NO;
        wmPlayer.mute = YES;
        wmPlayer.closeBtnStyle = CloseBtnStylePop;
        wmPlayer.enableVolumeGesture = NO;
        wmPlayer.URLString = model.mp4_url;
        wmPlayer.titleLabel.text = model.title;
        //        [wmPlayer play];
    }else{
        wmPlayer = [[WMPlayer alloc]initWithFrame:self.currentCell.backgroundIV.bounds];
        wmPlayer.delegate = self;
        wmPlayer.contrainerViewController = self;
        //关闭音量调节的手势
        [wmPlayer hideControls:YES];
        wmPlayer.dragEnable = NO;
        wmPlayer.mute = YES;
        wmPlayer.closeBtnStyle = CloseBtnStylePop;
        wmPlayer.enableVolumeGesture = NO;
        wmPlayer.titleLabel.text = model.title;
        wmPlayer.URLString = model.mp4_url;
    }
    [self.currentCell.backgroundIV addSubview:wmPlayer];
    [self.currentCell.backgroundIV bringSubviewToFront:wmPlayer];
    [self.currentCell.playBtn.superview sendSubviewToBack:self.currentCell.playBtn];
    [self.table reloadData];
    
}



-(void)toCell{
    wmPlayer.dragEnable = NO;
    VideoCell *currentCell = (VideoCell *)[self.table cellForRowAtIndexPath:[NSIndexPath indexPathForRow:currentIndexPath.row inSection:0]];
    [wmPlayer removeFromSuperview];
    [UIView animateWithDuration:0.7f animations:^{
        wmPlayer.transform = CGAffineTransformIdentity;
        wmPlayer.frame = currentCell.backgroundIV.bounds;
        wmPlayer.playerLayer.frame =  wmPlayer.bounds;
        [currentCell.backgroundIV addSubview:wmPlayer];
        [currentCell.backgroundIV bringSubviewToFront:wmPlayer];
        [wmPlayer.contentView mas_remakeConstraints:^(MASConstraintMaker *make) {
            
            make.edges.equalTo(wmPlayer).with.offset(0);
            make.width.mas_equalTo([UIScreen mainScreen].bounds.size.width);
            make.height.mas_equalTo(wmPlayer.frame.size.height);
            
        }];
        if ([UIDevice currentDevice].systemVersion.floatValue >= 8.0) {
            wmPlayer.effectView.frame = CGRectMake([UIScreen mainScreen].bounds.size.width/2-155/2, [UIScreen mainScreen].bounds.size.height/2-155/2, 155, 155);
        }else{
            //            wmPlayer.lightView.frame = CGRectMake(kScreenWidth/2-155/2, kScreenHeight/2-155/2, 155, 155);
        }
        
        [wmPlayer.FF_View  mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.center.mas_equalTo(CGPointMake([UIScreen mainScreen].bounds.size.width/2-180, wmPlayer.frame.size.height/2-144));
            make.height.mas_equalTo(60);
            make.width.mas_equalTo(120);
            
        }];
        
        [wmPlayer.bottomView mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(wmPlayer).with.offset(0);
            make.right.equalTo(wmPlayer).with.offset(0);
            make.height.mas_equalTo(50);
            make.bottom.equalTo(wmPlayer).with.offset(0);
        }];
        [wmPlayer.topView mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(wmPlayer).with.offset(0);
            make.right.equalTo(wmPlayer).with.offset(0);
            make.height.mas_equalTo(70);
            make.top.equalTo(wmPlayer).with.offset(0);
        }];
        [wmPlayer.titleLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(wmPlayer.topView).with.offset(45);
            make.right.equalTo(wmPlayer.topView).with.offset(-45);
            make.center.equalTo(wmPlayer.topView);
            make.top.equalTo(wmPlayer.topView).with.offset(0);
        }];
        [wmPlayer.closeBtn mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(wmPlayer).with.offset(5);
            make.height.mas_equalTo(30);
            make.width.mas_equalTo(30);
            make.top.equalTo(wmPlayer).with.offset(20);
        }];
        [wmPlayer.loadFailedLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.center.equalTo(wmPlayer);
            make.width.equalTo(wmPlayer);
            make.height.equalTo(@30);
        }];
    }completion:^(BOOL finished) {
        wmPlayer.isFullscreen = NO;
        [self setNeedsStatusBarAppearanceUpdate];
        isSmallScreen = NO;
//        wmPlayer.fullScreenBtn.selected = NO;
        wmPlayer.FF_View.hidden = YES;
    }];
    
}

-(void)toFullScreenWithInterfaceOrientation:(UIInterfaceOrientation )interfaceOrientation{
    [wmPlayer removeFromSuperview];
    wmPlayer.dragEnable = NO;
    wmPlayer.transform = CGAffineTransformIdentity;
    if (interfaceOrientation==UIInterfaceOrientationLandscapeLeft) {
        wmPlayer.transform = CGAffineTransformMakeRotation(-M_PI_2);
    }else if(interfaceOrientation==UIInterfaceOrientationLandscapeRight){
        wmPlayer.transform = CGAffineTransformMakeRotation(M_PI_2);
    }
    wmPlayer.frame = CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height);
    wmPlayer.playerLayer.frame =  CGRectMake(0,0, [UIScreen mainScreen].bounds.size.height,[UIScreen mainScreen].bounds.size.width);
    
    [wmPlayer.contentView mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.width.mas_equalTo([UIScreen mainScreen].bounds.size.height);
        make.height.mas_equalTo([UIScreen mainScreen].bounds.size.width);
        make.left.equalTo(wmPlayer).with.offset(0);
        make.top.equalTo(wmPlayer).with.offset(0);
    }];
    if ([UIDevice currentDevice].systemVersion.floatValue >= 8.0) {
        wmPlayer.effectView.frame = CGRectMake([UIScreen mainScreen].bounds.size.height/2-155/2, [UIScreen mainScreen].bounds.size.width/2-155/2, 155, 155);
    }else{
        //        wmPlayer.lightView.frame = CGRectMake(kScreenHeight/2-155/2, kScreenWidth/2-155/2, 155, 155);
    }
    [wmPlayer.FF_View  mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(wmPlayer).with.offset([UIScreen mainScreen].bounds.size.height/2-120/2);
        make.top.equalTo(wmPlayer).with.offset([UIScreen mainScreen].bounds.size.width/2-60/2);
        make.height.mas_equalTo(60);
        make.width.mas_equalTo(120);
    }];
    [wmPlayer.bottomView mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.height.mas_equalTo(50);
        make.width.mas_equalTo([UIScreen mainScreen].bounds.size.height);
        make.bottom.equalTo(wmPlayer.contentView).with.offset(0);
    }];
    
    [wmPlayer.topView mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.height.mas_equalTo(70);
        make.left.equalTo(wmPlayer).with.offset(0);
        make.width.mas_equalTo([UIScreen mainScreen].bounds.size.height);
    }];
    
    [wmPlayer.closeBtn mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(wmPlayer.topView).with.offset(5);
        make.height.mas_equalTo(30);
        make.width.mas_equalTo(30);
        make.top.equalTo(wmPlayer).with.offset(20);
        
    }];
    
    [wmPlayer.titleLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(wmPlayer.topView).with.offset(45);
        make.right.equalTo(wmPlayer.topView).with.offset(-45);
        make.center.equalTo(wmPlayer.topView);
        make.top.equalTo(wmPlayer.topView).with.offset(0);
    }];
    
    [wmPlayer.loadFailedLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(wmPlayer).with.offset(0);
        make.top.equalTo(wmPlayer).with.offset([UIScreen mainScreen].bounds.size.width/2-30/2);
        make.height.equalTo(@30);
        make.width.mas_equalTo([UIScreen mainScreen].bounds.size.height);
    }];
    
    [wmPlayer.loadingView mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(wmPlayer).with.offset([UIScreen mainScreen].bounds.size.height/2-22/2);
        make.top.equalTo(wmPlayer).with.offset([UIScreen mainScreen].bounds.size.width/2-22/2);
        make.height.mas_equalTo(22);
        make.width.mas_equalTo(22);
    }];
    
    [self.view addSubview:wmPlayer];
    [[UIApplication sharedApplication].keyWindow addSubview:wmPlayer];
//    wmPlayer.fullScreenBtn.selected = YES;
    wmPlayer.isFullscreen = YES;
    wmPlayer.FF_View.hidden = YES;
}


/**
 *  释放WMPlayer
 */
-(void)releaseWMPlayer{
    //堵塞主线程
    //    [wmPlayer.player.currentItem cancelPendingSeeks];
    //    [wmPlayer.player.currentItem.asset cancelLoading];
    [wmPlayer pause];
    
    
    [wmPlayer removeFromSuperview];
    [wmPlayer.playerLayer removeFromSuperlayer];
    [wmPlayer.player replaceCurrentItemWithPlayerItem:nil];
    wmPlayer.player = nil;
    wmPlayer.currentItem = nil;
    //释放定时器，否侧不会调用WMPlayer中的dealloc方法
    [wmPlayer.autoDismissTimer invalidate];
    wmPlayer.autoDismissTimer = nil;
    
    
    wmPlayer.playOrPauseBtn = nil;
    wmPlayer.playerLayer = nil;
    wmPlayer = nil;
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    
}
-(void)dealloc{
    NSLog(@"%@ dealloc",[self class]);
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    
    [self releaseWMPlayer];
}




@end
