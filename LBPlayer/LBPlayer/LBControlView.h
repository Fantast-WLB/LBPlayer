//
//  LBControlView.h
//  LBPlayer
//
//  Created by Mac mini -1 on 16/10/11.
//  Copyright © 2016年 whatTheGhost. All rights reserved.

#import <UIKit/UIKit.h>
#import "LBPlayer.h"

@interface LBControlView : UIView

/****** 图标 ******/
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


/****** 控件 ******/
/* 返回 */
@property(nonatomic,strong,readonly)UIButton* backButton;
/* 视频标题 */
@property(nonatomic,strong,readonly)UILabel* titleLabel;
/* (解)锁屏 */
@property(nonatomic,strong,readonly)UIButton* lockScreenBtn;
/* 播放 */
@property(nonatomic,strong,readonly)UIButton* playButton;
/* 当前时间 */
@property(nonatomic,strong,readonly)UILabel* currentTimeLabel;
/* 总时间 */
@property(nonatomic,strong,readonly)UILabel* durationTimeLabel;
/* 滚动条 */
@property(nonatomic,strong,readonly)UISlider* videoSlider;
/* 切屏按钮 */
@property(nonatomic,strong,readonly)UIButton* switchScreenButton;
/* 顶部阴影 */
@property(nonatomic,strong,readonly)UIImageView* topShadowView;
/* 底部阴影 */
@property(nonatomic,strong,readonly)UIImageView* bottomShadowView;
/* 进度控件 */
@property(nonatomic,strong,readonly)UIProgressView* progressView;

/****** 其他 ******/
/* 是否锁屏 */
@property(nonatomic,assign)BOOL isScreenLocked;

/* 单例控制视图 */
+(instancetype)shareControlView;

/**
 *  显示控制视图
 */
-(void)showControlView;
/**
 *  隐藏控制视图
 */
-(void)hideControlView;

@end
