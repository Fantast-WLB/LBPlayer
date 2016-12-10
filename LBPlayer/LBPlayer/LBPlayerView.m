//
//  LBPlayerView.m
//  LBPlayer
//
//  Created by Mac mini -1 on 16/10/11.
//  Copyright © 2016年 whatTheGhost. All rights reserved.
//

#import "LBPlayerView.h"
#import "LBControlView.h"
#import "LBVideoEndView.h"
#import <SVProgressHUD.h>
#import <AVFoundation/AVFoundation.h>

/* 视频播放状态 */
typedef NS_ENUM(NSInteger,VieoStatus)
{
    VideoBegin,//刚开始播放
    VideoPlaying,//播放中
    VideoEnd//结束播放
};

/* 手势方向 */
typedef NS_ENUM(NSInteger,PanDirection)
{
    PanDirectionVertical,//垂直
    PanDirectionHorizontal,//水平
};

@interface LBPlayerView ()<UIGestureRecognizerDelegate>

/* 播放器属性 */
@property(nonatomic,strong)AVPlayer* player;
@property(nonatomic,strong)AVPlayerItem* playerItem;
@property(nonatomic,strong)AVPlayerLayer* playerLayer;
@property(nonatomic,strong)AVURLAsset* URLAsset;
@property(nonatomic,strong)AVAssetImageGenerator* imageGenerator;
@property(nonatomic,assign)VieoStatus videoStatus;

/* 播放控制视图 */
@property(nonatomic,strong)LBControlView* controlView;
/* 播放结束视图 */
@property(nonatomic,strong)LBVideoEndView* endView;
/* 亮度视图 */
@property(nonatomic,strong)UIView* brightnessView;
/* 预览视图 */
@property(nonatomic,strong)UIImageView* previewImageView;
/* 视频占位视图 */
@property(nonatomic,strong)UIImageView* placeholderImageView;
/* 加载网络图 */
@property(nonatomic,strong)UIImageView* connectingImageView;

/* 是否自动更新 */
@property(nonatomic,assign)BOOL isAutoUpdateProgress;

/* 是否全屏 */
@property(nonatomic,assign)BOOL isFullScreen;

/* 是否正在调整进度 */
@property(nonatomic,assign)BOOL isUserDragging;

/* 上一秒的播放进度 */
@property(nonatomic,copy)NSString* lastProgressString;

/******* 手势相关 *******/
/* 手势方向 */
@property(nonatomic,assign)PanDirection panDirection;
/* 水平手势用户目标时间 */
@property(nonatomic,assign)CGFloat targetTime;
@end

@implementation LBPlayerView

#pragma mark - init
-(instancetype)init
{
    if (self = [super init])
    {
        
    }
    return self;
}

-(instancetype)initWithCoder:(NSCoder *)aDecoder
{
    if (self = [super initWithCoder:aDecoder])
    {
        
    }
    return self;
}

-(instancetype)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame])
    {
        
    }
    return self;
}

/* 单例视频播放视图 */
+(instancetype)sharePlayerView
{
    static LBPlayerView* instance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[LBPlayerView alloc]init];
    });
    return instance;
}

-(void)dealloc
{
    [[NSNotificationCenter defaultCenter]removeObserver:self];
}

#pragma mark - Layout
-(void)layoutSubviews
{
    [super layoutSubviews];
    
    self.playerLayer.frame = self.bounds;
    
    self.connectingImageView.center = CGPointMake(self.frame.size.width / 2, self.frame.size.height / 2);
    self.connectingImageView.bounds = CGRectMake(0, 0, 48, 48);
    
    self.placeholderImageView.frame = self.bounds;
    
    self.brightnessView.frame = self.bounds;
    
    self.previewImageView.frame = self.bounds;
    
    self.placeholderImageView.frame = self.bounds;
    
    self.controlView.frame = self.bounds;
    
    self.endView.frame = self.bounds;
    
    [self setUpSubviewActions];
    
}

#pragma mark - PrivateMethods
/* 自动播放 */
-(void)autoPlay
{
    [self playerPlay:self.controlView.playButton];
}

/* 初始化播放器 */
-(void)initializeThePlayer
{
    self.URLAsset = [AVURLAsset assetWithURL:self.videoURL];
    
    self.playerItem = [AVPlayerItem playerItemWithAsset:self.URLAsset];
    
    self.player = [AVPlayer playerWithPlayerItem:self.playerItem];
    
    self.playerLayer = [AVPlayerLayer playerLayerWithPlayer:self.player];
    
    [self.layer addSublayer:self.playerLayer];
    
    self.placeholderImageView.hidden = NO;
    
    [self.connectingImageView startAnimating];
    
    self.brightnessView.alpha = 0;
    
    self.previewImageView.hidden = YES;
    
    self.controlView.durationTimeLabel.text = [self getTheVideoTimeString:self.player.currentItem.asset.duration];
    
    [self autoUpdateVideoProgress];
}
/* 子控件方法 */
-(void)setUpSubviewActions
{
    ///控制视图
    [self.controlView.backButton addTarget:self action:@selector(backButtonClicked) forControlEvents:UIControlEventTouchUpInside];
    [self.controlView.lockScreenBtn addTarget:self action:@selector(lockScreenBtnClicked:) forControlEvents:UIControlEventTouchUpInside];
    [self.controlView.playButton addTarget:self action:@selector(playerPlay:) forControlEvents:UIControlEventTouchUpInside];
    [self.controlView.videoSlider addTarget:self action:@selector(sliderTouchBegan:) forControlEvents:UIControlEventTouchDown];
    [self.controlView.videoSlider addTarget:self action:@selector(sliderValueChanged:) forControlEvents:UIControlEventValueChanged];
    [self.controlView.videoSlider addTarget:self action:@selector(sliderTouchEnded:) forControlEvents:UIControlEventTouchUpInside | UIControlEventTouchCancel | UIControlEventTouchUpOutside];
    [self.controlView.switchScreenButton addTarget:self action:@selector(switchScreenButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
    
    UITapGestureRecognizer* tapBackground = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(changeTheControlViewStatus:)];
    [self addGestureRecognizer:tapBackground];
    
    UITapGestureRecognizer* tapSlider = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(tapToChangeTheProgress:)];
    [self.controlView.videoSlider addGestureRecognizer:tapSlider];
    
    ///结束视图
    [self.endView.backButton addTarget:self action:@selector(backButtonClicked) forControlEvents:UIControlEventTouchUpInside];
    [self.endView.replayButton addTarget:self action:@selector(replayButtonClicked) forControlEvents:UIControlEventTouchUpInside];
    
    ///转屏通知
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(screenDidRotate) name:UIDeviceOrientationDidChangeNotification object:nil];
}

/* 自动更新进度 */
-(void)autoUpdateVideoProgress
{
    CMTime timeSlider = CMTimeMake(1, 10);
    __weak typeof(self) weakSelf = self;
    [self.player addPeriodicTimeObserverForInterval:timeSlider queue:nil usingBlock:^(CMTime time) {
        
        if (!weakSelf.isAutoUpdateProgress)
        {
            return;
        }
        
        CGFloat currentTime = CMTimeGetSeconds(weakSelf.player.currentTime);
        CGFloat durationTime = CMTimeGetSeconds(weakSelf.player.currentItem.asset.duration);
        
        weakSelf.controlView.videoSlider.value = currentTime / durationTime;

        if (weakSelf.controlView.videoSlider.value == 1)
        {
            ///视频播放结束
            weakSelf.videoStatus = VideoEnd;
        }
        else if (weakSelf.controlView.videoSlider.value == 0)
        {
            ///视频将开始播放
            weakSelf.videoStatus = VideoBegin;
        }
        else
        {
            ///视频播放中
            weakSelf.videoStatus = VideoPlaying;
        }
        
    }];
    
    CMTime timeCurrent = CMTimeMake(1, 1);
    [self.player addPeriodicTimeObserverForInterval:timeCurrent queue:nil usingBlock:^(CMTime time) {
        
        if (!weakSelf.isAutoUpdateProgress)
        {
            return;
        }
        
        NSString* timeString = [weakSelf getTheVideoTimeString:weakSelf.player.currentTime];
        
        weakSelf.controlView.currentTimeLabel.text = timeString;
        
        if ([weakSelf.lastProgressString isEqualToString:timeString] && weakSelf.videoStatus == VideoPlaying)
        {
            weakSelf.connectingImageView.hidden = NO;
            [weakSelf.connectingImageView startAnimating];
        }
        else
        {
            weakSelf.connectingImageView.hidden = YES;
            [weakSelf.connectingImageView stopAnimating];
        }
        
        weakSelf.lastProgressString = timeString;
    }];

}

/* 根据播放时间获取时间字符串 */
-(NSString*)getTheVideoTimeString:(CMTime)time
{
    CGFloat duration = CMTimeGetSeconds(time);
    int minute = duration / 60;
    int second = (int)duration % 60;
    
    return [NSString stringWithFormat:@"%02d:%02d",minute,second].length > 6 ? @"--:--" : [NSString stringWithFormat:@"%02d:%02d",minute,second];
}

/* 设置屏幕方向 */
-(void)setInterfaceOrientation:(UIInterfaceOrientation)orientation
{
    if ([[UIDevice currentDevice] respondsToSelector:@selector(setOrientation:)])
    {
        SEL selector = NSSelectorFromString(@"setOrientation:");
        NSInvocation *invocation = [NSInvocation invocationWithMethodSignature:[UIDevice instanceMethodSignatureForSelector:selector]];
        [invocation setSelector:selector];
        [invocation setTarget:[UIDevice currentDevice]];
        [invocation setArgument:&orientation atIndex:2];
        [invocation invoke];
        if (orientation == UIInterfaceOrientationLandscapeLeft || orientation == UIInterfaceOrientationLandscapeRight)
        {
            self.isFullScreen = YES;
        }
        else if (orientation == UIInterfaceOrientationPortrait)
        {
            self.isFullScreen = NO;
        }
    }
}
/* 播放完毕 */
-(void)videoEnd
{
    [self.controlView hideControlView];
    
    [self.endView showEndView];
}

/* 调节播放进度 */
-(void)adjustProgress:(CGFloat)value
{
    self.isAutoUpdateProgress = NO;
    
    self.targetTime += value / 200;
    
    // 需要限定播放进度的范围
    CMTime totalTime = self.playerItem.duration;
    CGFloat totalDuration = (CGFloat)totalTime.value/totalTime.timescale;
    if (self.targetTime > totalDuration)
    {
        self.targetTime = totalDuration;
    }
    if (self.targetTime < 0)
    {
        self.targetTime = 0;
    }
    
    // 当前快进的时间
    NSString* currentTime = [self getTheVideoTimeString:CMTimeMake(self.targetTime, 1)];
    // 总时间
    NSString* durationTime = [self getTheVideoTimeString:self.playerItem.duration];
    
    [SVProgressHUD showProgress:self.targetTime / totalDuration status:[NSString stringWithFormat:@"%@ / %@",currentTime,durationTime]];
    // 更新slider的进度
    self.controlView.videoSlider.value = self.targetTime / totalDuration;
    // 更新现在播放的时间
    self.controlView.currentTimeLabel.text = currentTime;
}

/* 调节音量 */
-(void)adjustVolume:(CGFloat)value
{
    CGFloat volume = self.player.volume - value / 10000;
    if (volume >= 0 && volume <= 1)
    {
        self.player.volume = volume;
        int showNum = (int)(volume * 100);
        [SVProgressHUD showProgress:volume status:[NSString stringWithFormat:@"音量：%d",showNum]];
    }
    else if (volume > 1)
    {
        self.player.volume = 1;
        [SVProgressHUD showInfoWithStatus:@"音量已经最大"];
    }
    else
    {
        self.player.volume = 0;
        [SVProgressHUD showInfoWithStatus:@"音量已经最小"];
    }

}

/* 调节亮度 */
-(void)adjustBrightness:(CGFloat)value
{
    NSLog(@"亮度%lf",value);
    
    CGFloat alpha = self.brightnessView.alpha + value / 1000;
    
    if (alpha >= 0 && alpha <= 1)
    {
        self.brightnessView.alpha = alpha;
        int showNum = (int)(alpha * 100);
        [SVProgressHUD showProgress:alpha status:[NSString stringWithFormat:@"亮度：%d",1 - showNum]];
    }
    else if (alpha > 1)
    {
        self.brightnessView.alpha = 1;
        [SVProgressHUD showInfoWithStatus:@"亮度已经最小"];
    }
    else
    {
        self.brightnessView.alpha = 0;
        [SVProgressHUD showInfoWithStatus:@"亮度已经最大"];
    }

}

#pragma mark - SubviewActions
/* 返回 */
-(void)backButtonClicked
{
    if (self.isFullScreen)
    {
        [self switchScreenButtonClicked:self.controlView.switchScreenButton];
        return;
    }
    if (self.backBlock)
    {
        self.backBlock();
    }
}
/* (解)锁屏 */
-(void)lockScreenBtnClicked:(UIButton*)sender
{
    sender.selected = !sender.selected;
    self.controlView.isScreenLocked = sender.selected;
}
/* 播放 */
-(void)playerPlay:(UIButton*)sender
{
    sender.selected = !sender.selected;
    if (sender.selected)
    {
        [self.player play];
        
        if (self.placeholderImageView.hidden == NO)
        {
            self.placeholderImageView.hidden = YES;
        }
        
        self.isAutoUpdateProgress = YES;
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            if (self.isUserDragging)
            {
                return;
            }
            [self.controlView hideControlView];
        });
    }
    else
    {
        [self.player pause];
        self.isAutoUpdateProgress = NO;
    }
}
/* 按下进度条 */
-(void)sliderTouchBegan:(UISlider*)slider
{
    self.isAutoUpdateProgress = NO;
    self.isUserDragging = YES;
    [self.player pause];
}
/* 滑动进度条 */
-(void)sliderValueChanged:(UISlider*)slider
{
    CMTime current = self.player.currentItem.asset.duration;
    current.value *= self.controlView.videoSlider.value;
    self.controlView.currentTimeLabel.text = [self getTheVideoTimeString:current];
    
    if (self.self.controlView.videoSlider.value == 0)
    {
        self.videoStatus = VideoBegin;
    }
    else if (self.self.controlView.videoSlider.value == 1)
    {
        self.videoStatus = VideoEnd;
    }
    else
    {
        self.videoStatus = VideoPlaying;
    }
    
    ///预览进度
    CGFloat total = (CGFloat)self.player.currentItem.duration.value / _playerItem.duration.timescale;
    //计算出拖动的当前秒数
    NSInteger currentSecond = floorf(total * slider.value);
    //转换成CMTime才能给player来控制播放进度
    CMTime dragedCMTime = CMTimeMake(currentSecond, 1);
    self.previewImageView.hidden = NO;
    dispatch_queue_t queue = dispatch_queue_create("perview.queue", DISPATCH_QUEUE_CONCURRENT);
    dispatch_async(queue, ^{
        NSError *error;
        CMTime actualTime;
        CGImageRef cgImage = [self.imageGenerator copyCGImageAtTime:dragedCMTime actualTime:&actualTime error:&error];
        CMTimeShow(actualTime);
        UIImage *image = [UIImage imageWithCGImage:cgImage];
        CGImageRelease(cgImage);
        dispatch_async(dispatch_get_main_queue(), ^{
            self.previewImageView.image = image;
        });
    });


}
/* 松开进度条 */
-(void)sliderTouchEnded:(UISlider*)slider
{
    self.isUserDragging = NO;
    
    CMTime duration = self.player.currentItem.asset.duration;
    duration.value *= self.controlView.videoSlider.value;
    [self.player seekToTime:duration completionHandler:^(BOOL finished) {
        
        if (self.controlView.playButton.selected)
        {
            [self.player play];
            self.isAutoUpdateProgress = YES;
        }
        
        self.previewImageView.hidden = YES;
        
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            if (self.isAutoUpdateProgress)
            {
                [self.controlView hideControlView];
            }
        });
    }];
}
/* 切换全屏 */
-(void)switchScreenButtonClicked:(UIButton*)sender
{
    if (self.controlView.isScreenLocked)
    {
        return;
    }
    sender.selected = !sender.selected;
    if (sender.selected)
    {
        ///切换至全屏
        [self setInterfaceOrientation:UIInterfaceOrientationLandscapeRight];
    }
    else
    {
        ///恢复
        [self setInterfaceOrientation:UIInterfaceOrientationPortrait];
    }
}
/* 重播 */
-(void)replayButtonClicked
{
    [self.endView hideEndView];
    
    CMTime time = CMTimeMake(0, 1);
    [self.player seekToTime:time completionHandler:^(BOOL finished) {
        
        if (self.controlView.playButton.selected)
        {
            [self.player play];
        }
        self.isAutoUpdateProgress = YES;
    }];
}
/* 改变控制视图的状态 */
-(void)changeTheControlViewStatus:(UIGestureRecognizer*)gesture
{
    if (self.endView.alpha == 1)
    {
        return;
    }
    [self.controlView showControlView];
}
/* 点击进度条 */
-(void)tapToChangeTheProgress:(UIGestureRecognizer*)gesture
{
    CGPoint point = [gesture locationInView:self.controlView.videoSlider];
    CGFloat width = self.controlView.videoSlider.frame.size.width;
    CGFloat progress = point.x / width;
    self.controlView.videoSlider.value = progress;
    [self sliderTouchEnded:self.controlView.videoSlider];
}
/* 用户平移手势 */
-(void)userPanOnThePlayerView:(UIPanGestureRecognizer*)gesture
{
    ///获取点击位置
    CGPoint location = [gesture locationInView:self];
    ///根据上次和本次移动速率差来判断方向，
    CGPoint veloctyPoint = [gesture velocityInView:self];
    switch (gesture.state)
    {
        case UIGestureRecognizerStateBegan:
        {
            ///使用绝对值来判断移动的方向
            CGFloat x = fabs(veloctyPoint.x);
            CGFloat y = fabs(veloctyPoint.y);
            if (x > y)
            { ///x轴速率高于y轴则为水平移动
                self.panDirection = PanDirectionHorizontal;
                // 给sumTime初值
                CMTime time = self.player.currentTime;
                self.targetTime = time.value / time.timescale;
            }
            else if (x < y)
            { /// 垂直移动
                self.panDirection = PanDirectionVertical;
            }
            break;
        }
        case UIGestureRecognizerStateChanged:
        {
            switch (self.panDirection)
            {
                case PanDirectionHorizontal:
                {
                    // 移动中一直显示快进label
                    [self adjustProgress:veloctyPoint.x]; // 水平移动的方法只要x方向的值
                    break;
                }
                case PanDirectionVertical:
                {
                    if (location.x > self.frame.size.width / 2)
                    {   ///右侧调节音量
                        [self adjustVolume:veloctyPoint.y];
                    }
                    else
                    {   ///左侧调节亮度
                        [self adjustBrightness:veloctyPoint.y];
                    }
                    
                    break;
                }
                default:
                    break;
            }
            break;
        }
        case UIGestureRecognizerStateEnded:
        {
            switch (self.panDirection)
            {
                case PanDirectionHorizontal:
                {
                    
                    if (self.controlView.videoSlider.value == 1)
                    {
                        ///视频播放结束
                        self.videoStatus = VideoEnd;
                    }
                    else if (self.controlView.videoSlider.value == 0)
                    {
                        ///视频将开始播放
                        self.videoStatus = VideoBegin;
                    }
                    else
                    {
                        ///视频播放中
                        self.videoStatus = VideoPlaying;
                    }
                    
                    [self.player seekToTime:CMTimeMake(self.targetTime, 1) completionHandler:^(BOOL finished) {
                        
                        self.targetTime = 0;
                        
                        [SVProgressHUD dismiss];
                        
                        if (self.controlView.playButton.selected)
                        {
                            [self.player play];
                            self.isAutoUpdateProgress = YES;
                        }
                    }];
                    break;
                }
                case PanDirectionVertical:
                {
                    [SVProgressHUD dismiss];
                    break;
                }
                default:
                    break;
            }
            break;
        }
        default:
            break;
    }

}

#pragma mark - Notification
/* 屏幕旋转后调用 */
-(void)screenDidRotate
{
    if (self.controlView.isScreenLocked)
    {
        return;
    }
    UIDeviceOrientation orientation = [UIDevice currentDevice].orientation;
    if (orientation == UIDeviceOrientationPortrait)
    {
        self.controlView.switchScreenButton.selected = NO;
        self.isFullScreen = NO;
    }
    else if (orientation == UIDeviceOrientationLandscapeLeft || orientation == UIDeviceOrientationLandscapeRight)
    {
        self.controlView.switchScreenButton.selected = YES;
        self.isFullScreen = YES;
    }
}

#pragma mark - KVO
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    if (object == self.player.currentItem)
    {
        if ([keyPath isEqualToString:@"status"])
        {
            if (self.player.currentItem.status == AVPlayerItemStatusReadyToPlay)
            {
                // 视频加载完成后，再添加平移手势
                UIPanGestureRecognizer *pan = [[UIPanGestureRecognizer alloc]initWithTarget:self action:@selector(userPanOnThePlayerView:)];
                pan.delegate = self;
                [self addGestureRecognizer:pan];
            }
            else if (self.player.currentItem.status == AVPlayerItemStatusFailed)
            {
                [SVProgressHUD showErrorWithStatus:@"视频加载失败..."];
            }
        }
        else if ([keyPath isEqualToString:@"loadedTimeRanges"])
        {
            // 计算缓冲进度
            NSTimeInterval timeInterval = [self availableDuration];
            CMTime duration = self.playerItem.duration;
            CGFloat totalDuration = CMTimeGetSeconds(duration);
            [self.controlView.progressView setProgress:timeInterval / totalDuration animated:NO];
        }
    }
}

/**
 *  计算缓冲进度
 *
 *  @return 缓冲进度
 */
- (NSTimeInterval)availableDuration {
    NSArray *loadedTimeRanges = [[_player currentItem] loadedTimeRanges];
    CMTimeRange timeRange = [loadedTimeRanges.firstObject CMTimeRangeValue];// 获取缓冲区域
    float startSeconds = CMTimeGetSeconds(timeRange.start);
    float durationSeconds = CMTimeGetSeconds(timeRange.duration);
    NSTimeInterval result = startSeconds + durationSeconds;// 计算缓冲总进度
    return result;
}

#pragma mark - Setter
/************ 自定义视图 ************/
-(void)setBackImageName:(NSString *)backImageName
{
    self.controlView.backImageName = backImageName;
    self.endView.backImageName = backImageName;
}
-(void)setLockScreenImageName:(NSString *)lockScreenImageName  {self.controlView.lockScreenImageName = lockScreenImageName;}
-(void)setUnlockScreenImageName:(NSString *)unlockScreenImageName  {self.controlView.unlockScreenImageName = unlockScreenImageName;}
-(void)setPlayImageName:(NSString *)playImageName  {self.controlView.playImageName = playImageName;}
-(void)setPauseImageName:(NSString *)pauseImageName  {self.controlView.pauseImageName = pauseImageName;}
-(void)setSliderNormalIconImageName:(NSString *)sliderNormalIconImageName  {self.controlView.sliderNormalIconImageName = sliderNormalIconImageName;}
-(void)setSliderSelectedIconImageName:(NSString *)sliderSelectedIconImageName  {self.controlView.sliderSelectedIconImageName = sliderSelectedIconImageName;}
-(void)setFullScreenImageName:(NSString *)fullScreenImageName  {self.controlView.fullScreenImageName = fullScreenImageName;}
-(void)setShrinkscreenImageName:(NSString *)shrinkscreenImageName  {self.controlView.shrinkscreenImageName = shrinkscreenImageName;}
-(void)setReplayImageName:(NSString *)replayImageName  {self.endView.replayImageName = replayImageName;}
     
-(void)setVideoStatus:(VieoStatus)videoStatus
{
    if (videoStatus == VideoEnd)
    {
        [self videoEnd];
    }
    else
    {
        [self.endView hideEndView];
    }
}

/* 设置视频URL */
-(void)setVideoURL:(NSURL *)videoURL
{
    _videoURL = videoURL;
    
    [self initializeThePlayer];
}

/* 设置播放器item */
- (void)setPlayerItem:(AVPlayerItem *)playerItem
{
    if (_playerItem == playerItem)
    {
        return;
    }
    
    if (_playerItem)
    {
        [_playerItem removeObserver:self forKeyPath:@"status"];
        [_playerItem removeObserver:self forKeyPath:@"loadedTimeRanges"];
    }
    _playerItem = playerItem;
    if (playerItem)
    {
        [playerItem addObserver:self forKeyPath:@"status" options:NSKeyValueObservingOptionNew context:nil];
        [playerItem addObserver:self forKeyPath:@"loadedTimeRanges" options:NSKeyValueObservingOptionNew context:nil];
    }
}

/* 设置占位图 */
-(void)setPlaceholderImageName:(NSString *)placeholderImageName
{
    _placeholderImageName = placeholderImageName;
    self.placeholderImageView.image = [UIImage imageNamed:placeholderImageName];
}

#pragma mark - LazyLoad
-(LBControlView *)controlView
{
    if (_controlView == nil)
    {
        _controlView = [LBControlView shareControlView];
        [self addSubview:_controlView];
    }
    return _controlView;
}

-(LBVideoEndView *)endView
{
    if (_endView == nil)
    {
        _endView = [LBVideoEndView shareEndView];
        [self addSubview:_endView];
    }
    return _endView;
}

-(UIView *)brightnessView
{
    if (_brightnessView == nil)
    {
        _brightnessView = [[UIView alloc]init];
        _brightnessView.backgroundColor = [UIColor darkGrayColor];
        [self addSubview:_brightnessView];
    }
    return _brightnessView;
}

-(UIImageView *)previewImageView
{
    if (_previewImageView == nil)
    {
        _previewImageView = [[UIImageView alloc]init];
        _previewImageView.backgroundColor = [UIColor clearColor];
        [self addSubview:_previewImageView];
    }
    return _previewImageView;
}

-(AVAssetImageGenerator *)imageGenerator
{
    if (_imageGenerator == nil)
    {
        _imageGenerator = [AVAssetImageGenerator assetImageGeneratorWithAsset:self.URLAsset];
    }
    return _imageGenerator;
}

-(UIImageView *)placeholderImageView
{
    if (_placeholderImageView == nil)
    {
        _placeholderImageView = [[UIImageView alloc]init];
        _placeholderImageView.image = [UIImage imageNamed:@"LBBundle.bundle/placeholder"];
        [self addSubview:_placeholderImageView];
    }
    return _placeholderImageView;
}

-(UIImageView *)connectingImageView
{
    if (_connectingImageView == nil)
    {
        _connectingImageView = [[UIImageView alloc]init];
        _connectingImageView.animationImages = self.animationImages ? self.animationImages : @[[UIImage imageNamed:@"LBBundle.bundle/01"],[UIImage imageNamed:@"LBBundle.bundle/02"],[UIImage imageNamed:@"LBBundle.bundle/03"],[UIImage imageNamed:@"LBBundle.bundle/04"],[UIImage imageNamed:@"LBBundle.bundle/05"],[UIImage imageNamed:@"LBBundle.bundle/08"],[UIImage imageNamed:@"LBBundle.bundle/07"],[UIImage imageNamed:@"LBBundle.bundle/06"],[UIImage imageNamed:@"LBBundle.bundle/01"]];
        _connectingImageView.animationDuration = ConnectingAnimationTime;
        _connectingImageView.layer.cornerRadius = 8;
        [self addSubview:_connectingImageView];
    }
    return _connectingImageView;
}

@end
