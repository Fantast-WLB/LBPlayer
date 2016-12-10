//
//  ViewController.m
//  LBPlayer
//
//  Created by Mac mini -1 on 16/10/11.
//  Copyright © 2016年 whatTheGhost. All rights reserved.
//

#import "ViewController.h"
#import "LBPlayer.h"
@interface ViewController ()

@property (weak, nonatomic) IBOutlet LBPlayerView *playerView;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    self.playerView.videoURL = [NSURL URLWithString:@"http://www.derunkang.com/l00170upkju.mp4"];
    [self.playerView autoPlay];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

///横屏
-(BOOL)shouldAutorotate
{
    if ([LBControlView shareControlView].isScreenLocked)
    {
        return NO;
    }
    return YES;
}
///支持的屏幕方向
-(UIInterfaceOrientationMask)supportedInterfaceOrientations
{
    return UIInterfaceOrientationMaskAll;
}


@end
