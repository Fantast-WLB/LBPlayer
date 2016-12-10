//
//  LBControlView.m
//  LBPlayer
//
//  Created by Mac mini -1 on 16/10/11.
//  Copyright © 2016年 whatTheGhost. All rights reserved.
//

#import "LBControlView.h"
#import <Masonry.h>

#define TitleFontSize 15
#define TimeFontSize 13
#define TopShadowHeight 44
#define BottomShadowHeight 44
#define OffsetPadding 8
#define TopButtonWidthHeight 33
#define BottomButtonWidthHeight 24

@interface LBControlView ()

/* 返回 */
@property(nonatomic,strong)UIButton* backButton;
/* 视频标题 */
@property(nonatomic,strong)UILabel* titleLabel;
/* (解)锁屏 */
@property(nonatomic,strong)UIButton* lockScreenBtn;
/* 播放 */
@property(nonatomic,strong)UIButton* playButton;
/* 当前时间 */
@property(nonatomic,strong)UILabel* currentTimeLabel;
/* 总时间 */
@property(nonatomic,strong)UILabel* durationTimeLabel;
/* 滚动条 */
@property(nonatomic,strong)UISlider* videoSlider;
/* 切屏按钮 */
@property(nonatomic,strong)UIButton* switchScreenButton;
/* 顶部阴影 */
@property(nonatomic,strong)UIImageView* topShadowView;
/* 底部阴影 */
@property(nonatomic,strong)UIImageView* bottomShadowView;
/* 进度控件 */
@property(nonatomic,strong)UIProgressView* progressView;


@end

@implementation LBControlView

#pragma mark - LifeCycle
-(instancetype)init
{
    if (self = [super init])
    {
        self.backgroundColor = [UIColor clearColor];
    }
    return self;
}

-(void)layoutSubviews
{
    [super layoutSubviews];
    
    [self.topShadowView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.trailing.top.equalTo(self);
        make.height.mas_equalTo(TopShadowHeight);
    }];
    
    [self.backButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.mas_equalTo(self.topShadowView).offset(OffsetPadding);
        make.centerY.equalTo(self.topShadowView);
        make.height.width.mas_equalTo(TopButtonWidthHeight);
    }];
    
    [self.titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.centerX.equalTo(self.topShadowView);
        make.leading.mas_equalTo(self.backButton.mas_trailing).offset(OffsetPadding);
    }];
    self.titleLabel.text = @"标题";
    
    [self.lockScreenBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(self.topShadowView);
        make.trailing.mas_equalTo(self).offset(-OffsetPadding);
        make.height.width.mas_equalTo(TopButtonWidthHeight);
    }];
    
    [self.bottomShadowView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.bottom.trailing.equalTo(self);
        make.height.mas_equalTo(BottomShadowHeight);
    }];
    
    [self.playButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(self.bottomShadowView);
        make.leading.mas_equalTo(self.bottomShadowView).offset(OffsetPadding);
        make.height.width.mas_equalTo(BottomButtonWidthHeight);
    }];
    
    [self.currentTimeLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(self.bottomShadowView);
        make.leading.mas_equalTo(self.playButton.mas_trailing).offset(OffsetPadding);
    }];
    
    [self.videoSlider mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(self.bottomShadowView);
        make.leading.mas_equalTo(self.currentTimeLabel.mas_trailing).offset(OffsetPadding);
    }];
    
    [self.progressView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.trailing.equalTo(self.videoSlider);
        make.centerY.mas_equalTo(self.videoSlider).offset(1);
    }];
    
    [self.durationTimeLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(self.bottomShadowView);
        make.leading.mas_equalTo(self.videoSlider.mas_trailing).offset(OffsetPadding);
    }];
    
    [self.switchScreenButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(self.bottomShadowView);
        make.leading.mas_equalTo(self.durationTimeLabel.mas_trailing).offset(OffsetPadding);
        make.trailing.mas_equalTo(self.bottomShadowView).offset(-OffsetPadding);
        make.height.width.mas_equalTo(BottomButtonWidthHeight);
    }];
    
    UITapGestureRecognizer* tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(changeTheControlViewStatus:)];
    [self addGestureRecognizer:tap];
}

#pragma mark - PrivateMethods
/* 单例控制视图 */
+(instancetype)shareControlView
{
    static LBControlView* instance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[LBControlView alloc]init];
    });
    return instance;
}

/**
 *  显示控制视图
 */
-(void)showControlView
{
    [UIView animateWithDuration:NormalAnimationTime animations:^{
        self.alpha = 1;
    }];
}
/**
 *  隐藏控制视图
 */
-(void)hideControlView
{
    [UIView animateWithDuration:NormalAnimationTime animations:^{
        self.alpha = 0;
    }];
}
/**
 *  改变控制视图状态
 *
 *  @param gesture 点击手势
 */
-(void)changeTheControlViewStatus:(UIGestureRecognizer*)gesture
{
    [self hideControlView];
}

#pragma mark - LazyLoad
-(UIButton *)backButton
{
    if (_backButton == nil)
    {
        _backButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_backButton setImage:[UIImage imageNamed:self.backImageName ? self.backImageName : @"LBBundle.bundle/left.png"] forState:UIControlStateNormal];
    }
    return _backButton;
}

-(UILabel *)titleLabel
{
    if (_titleLabel == nil)
    {
        _titleLabel = [[UILabel alloc]init];
        _titleLabel.font = [UIFont systemFontOfSize:TitleFontSize];
        _titleLabel.textAlignment = NSTextAlignmentCenter;
        _titleLabel.textColor = [UIColor whiteColor];
    }
    return _titleLabel;
}

-(UIButton *)lockScreenBtn
{
    if (_lockScreenBtn == nil)
    {
        _lockScreenBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [_lockScreenBtn setImage:[UIImage imageNamed:self.lockScreenImageName ? self.lockScreenImageName : @"LBBundle.bundle/unlock.png"] forState:UIControlStateNormal];
        [_lockScreenBtn setImage:[UIImage imageNamed:self.unlockScreenImageName ? self.unlockScreenImageName : @"LBBundle.bundle/lock.png"] forState:UIControlStateSelected];
        [self.topShadowView addSubview:_lockScreenBtn];
    }
    return _lockScreenBtn;
}

-(UIButton *)playButton
{
    if (_playButton == nil)
    {
        _playButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_playButton setImage:[UIImage imageNamed:self.playImageName ? self.playImageName : @"LBBundle.bundle/play.png"] forState:UIControlStateNormal];
        [_playButton setImage:[UIImage imageNamed:self.pauseImageName ? self.pauseImageName : @"LBBundle.bundle/pause.png"] forState:UIControlStateSelected];
    }
    return _playButton;
}

-(UILabel *)currentTimeLabel
{
    if (_currentTimeLabel == nil)
    {
        _currentTimeLabel = [[UILabel alloc]init];
        _currentTimeLabel.font = [UIFont systemFontOfSize:TimeFontSize];
        _currentTimeLabel.textAlignment = NSTextAlignmentCenter;
        _currentTimeLabel.textColor = [UIColor whiteColor];
        _currentTimeLabel.text = @"00:00";
    }
    return _currentTimeLabel;
}

-(UILabel *)durationTimeLabel
{
    if (_durationTimeLabel == nil)
    {
        _durationTimeLabel = [[UILabel alloc]init];
        _durationTimeLabel.font = [UIFont systemFontOfSize:TimeFontSize];
        _durationTimeLabel.textAlignment = NSTextAlignmentCenter;
        _durationTimeLabel.textColor = [UIColor whiteColor];
        _durationTimeLabel.text = @"--:--";
    }
    return _durationTimeLabel;
}

-(UISlider*)videoSlider
{
    if (_videoSlider == nil)
    {
        _videoSlider = [[UISlider alloc]init];
        [_videoSlider setThumbImage:[UIImage imageNamed:self.sliderNormalIconImageName ? self.sliderNormalIconImageName : @"LBBundle.bundle/progress"] forState:UIControlStateNormal];
        [_videoSlider setThumbImage:[UIImage imageNamed:self.sliderSelectedIconImageName ? self.sliderSelectedIconImageName : @"LBBundle.bundle/progress"] forState:UIControlStateSelected];
        _videoSlider.maximumTrackTintColor = [UIColor colorWithRed:0.5 green:0.5 blue:0.5 alpha:0.5];
        _videoSlider.minimumTrackTintColor = [UIColor whiteColor];
    }
    return _videoSlider;
}

-(UIButton *)switchScreenButton
{
    if (_switchScreenButton == nil)
    {
        _switchScreenButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_switchScreenButton setImage:[UIImage imageNamed:self.fullScreenImageName ? self.fullScreenImageName : @"LBBundle.bundle/fullscreen"] forState:UIControlStateNormal];
        [_switchScreenButton setImage:[UIImage imageNamed:self.shrinkscreenImageName ? self.shrinkscreenImageName : @"LBBundle.bundle/shrinkscreen"] forState:UIControlStateSelected];
    }
    return _switchScreenButton;
}

-(UIImageView *)topShadowView
{
    if (_topShadowView == nil)
    {
        _topShadowView = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"LBBundle.bundle/shadow_top.png"]];
        _topShadowView.userInteractionEnabled = YES;
        [self addSubview:_topShadowView];
        [_topShadowView addSubview:self.backButton];
        [_topShadowView addSubview:self.titleLabel];
    }
    return _topShadowView;
}

-(UIImageView *)bottomShadowView
{
    if (_bottomShadowView == nil)
    {
        _bottomShadowView = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"LBBundle.bundle/shadow_bottom.png"]];
        _bottomShadowView.userInteractionEnabled = YES;
        [self addSubview:_bottomShadowView];
        [_bottomShadowView addSubview:self.playButton];
        [_bottomShadowView addSubview:self.currentTimeLabel];
        [_bottomShadowView addSubview:self.videoSlider];
        [_bottomShadowView addSubview:self.progressView];
        [_bottomShadowView addSubview:self.durationTimeLabel];
        [_bottomShadowView addSubview:self.switchScreenButton];
    }
    return _bottomShadowView;
}

-(UIProgressView *)progressView
{
    if (_progressView == nil)
    {
        _progressView = [[UIProgressView alloc] initWithProgressViewStyle:UIProgressViewStyleDefault];
        _progressView.progressTintColor = [UIColor colorWithRed:1 green:1 blue:1 alpha:0.5];
        _progressView.trackTintColor    = [UIColor clearColor];

    }
    return _progressView;
}
@end

