//
//  LBVideoEndView.m
//  LBPlayer
//
//  Created by Mac mini -1 on 16/10/12.
//  Copyright © 2016年 whatTheGhost. All rights reserved.
//

#import "LBVideoEndView.h"
#import <Masonry.h>

#define BackgroundAlpha 0.5
#define OffsetPadding 32
@interface LBVideoEndView ()

/* 背景 */
@property(nonatomic,strong)UIView* backgroundView;

@end

@implementation LBVideoEndView

#pragma mark - init
-(instancetype)init
{
    if (self = [super init])
    {
        
    }
    return self;
}

/**
 *  单例播放结束视图
 */
+(instancetype)shareEndView
{
    static LBVideoEndView* instance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[LBVideoEndView alloc]init];
        instance.alpha = 0;
    });
    return instance;
}

#pragma mark - Layout
-(void)layoutSubviews
{
    [super layoutSubviews];
    
    [self.backgroundView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self);
    }];
    
    [self.backButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(self.backgroundView);
        make.leading.mas_equalTo(self.backgroundView).offset(OffsetPadding);
    }];
    
    [self.replayButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(self.backgroundView);
        make.trailing.mas_equalTo(self.backgroundView).offset(-OffsetPadding);
    }];
}

#pragma mark - PrivateMethods
/**
 *  显示控制视图
 */
-(void)showEndView
{
    [UIView animateWithDuration:NormalAnimationTime animations:^{
        self.alpha = 1;
    }];
}
/**
 *  隐藏控制视图
 */
-(void)hideEndView
{
    [UIView animateWithDuration:NormalAnimationTime animations:^{
        self.alpha = 0;
    }];
}

#pragma mark - LazyLoad
-(UIView *)backgroundView
{
    if (_backgroundView == nil)
    {
        _backgroundView = [[UIView alloc]init];
        _backgroundView.alpha = BackgroundAlpha;
        _backgroundView.backgroundColor = [UIColor blackColor];
        [self addSubview:_backgroundView];
    }
    return _backgroundView;
}

-(UIButton *)backButton
{
    if (_backButton == nil)
    {
        _backButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_backButton setImage:[UIImage imageNamed:self.backImageName ? self.backImageName : @"LBBundle.bundle/left.png"] forState:UIControlStateNormal];
        [self.backgroundView addSubview:_backButton];
    }
    return _backButton;
}

-(UIButton *)replayButton
{
    if (_replayButton == nil)
    {
        _replayButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_replayButton setImage:[UIImage imageNamed:self.replayImageName ? self.replayImageName : @"LBBundle.bundle/replay.png"] forState:UIControlStateNormal];
        [self.backgroundView addSubview:_replayButton];
    }
    return _replayButton;
}
@end
