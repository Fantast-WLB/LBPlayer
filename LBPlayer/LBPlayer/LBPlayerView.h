//
//  LBPlayerView.h
//  LBPlayer
//
//  Created by Mac mini -1 on 16/10/11.
//  Copyright © 2016年 whatTheGhost. All rights reserved.
//

#import <UIKit/UIKit.h>

///返回键的Block
typedef void(^LBBackBlcok)(void);

@interface LBPlayerView : UIView

/* 视频URL */
@property(nonatomic,strong)NSURL* videoURL;
/* 视频标题 */
@property(nonatomic,copy)NSString* videoTitle;
/* 返回键Block */
@property(nonatomic,copy)LBBackBlcok backBlock;
/* 背景图 */
@property(nonatomic,copy)NSString* backgroundImageName;


/************ 自定义视图 ************/
/* 返回键图标 */
@property(nonatomic,copy)NSString* backImageName;
/* 锁屏图标 */
@property(nonatomic,copy)NSString* lockScreenImageName;
/* 解锁图标 */
@property(nonatomic,copy)NSString* unlockScreenImageName;
/* 播放图标 */
@property(nonatomic,copy)NSString* playImageName;
/* 暂停图标 */
@property(nonatomic,copy)NSString* pauseImageName;
/* 滚动条图标 */
@property(nonatomic,copy)NSString* sliderNormalIconImageName;
/* 滚动条选中图标 */
@property(nonatomic,copy)NSString* sliderSelectedIconImageName;
/* 全屏图标 */
@property(nonatomic,copy)NSString* fullScreenImageName;
/* 缩屏图标 */
@property(nonatomic,copy)NSString* shrinkscreenImageName;
/* 重播图标 */
@property(nonatomic,copy)NSString* replayImageName;
/* 视频占位图 */
@property(nonatomic,copy)NSString* placeholderImageName;
/* 网络加载动画图 */
@property(nonatomic,strong)NSArray* animationImages;

/* 单例视频播放视图 */
+(instancetype)sharePlayerView;

/* 自动播放 */
-(void)autoPlay;

@end
