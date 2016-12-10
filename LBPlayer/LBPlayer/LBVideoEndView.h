//
//  LBVideoEndView.h
//  LBPlayer
//
//  Created by Mac mini -1 on 16/10/12.
//  Copyright © 2016年 whatTheGhost. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "LBPlayer.h"

@interface LBVideoEndView : UIView
/* 返回按钮 */
@property(nonatomic,strong)UIButton* backButton;
/* 重播按钮 */
@property(nonatomic,strong)UIButton* replayButton;

/****** 图标 ******/
/* 返回键图标 */
@property(nonatomic,copy)NSString* backImageName;
/* 重播图标 */
@property(nonatomic,copy)NSString* replayImageName;

/**
 *  单例播放结束视图
 */
+(instancetype)shareEndView;

/**
 *  显示控制视图
 */
-(void)showEndView;
/**
 *  隐藏控制视图
 */
-(void)hideEndView;

@end
