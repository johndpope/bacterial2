//
//  ScoreScene.m
//  bacterial
//
//  Created by 李翌文 on 14-6-30.
//  Copyright (c) 2014年 Apportable. All rights reserved.
//

#import "define.h"
#import "MainScene.h"
#import "ScoreScene.h"
#import "VirtualStore.h"
#import "UMSocial.h"
#import "UMSocialScreenShoter.h"
#import "MobClick.h"
#import "YouMiView.h"

#import "DataStorageManager.h"
#import "GameCenterManager.h"

#define dataStorageManagerConfig [DataStorageManager sharedDataStorageManager].config

@implementation ScoreScene
{
    BOOL _over;
    BOOL isR4;
    int _score;
    
    CCButton *btnContinue;
    CCButton *btnScoreboard;
    CCButton *btnTop10;
    YouMiView *adView;
    UIImage *screenShot;
}

-(void)didLoadFromCCB
{
    isR4 = iPhone5;
    _over = NO;
    
    btnTop10.enabled = [GameCenterManager sharedGameCenterManager].enabled;

    if(dataStorageManagerConfig)
    {
        NSDictionary *adResult = [dataStorageManagerConfig objectForKey:@"ad"];
        int ad = [[adResult objectForKey:@"result"] intValue];
        if (ad == 1)
        {
            adView = [[YouMiView alloc] initWithContentSizeIdentifier:YouMiBannerContentSizeIdentifier320x50 delegate:nil];
            adView.indicateTranslucency = YES;
            adView.indicateRounded = NO;
            [adView start];

            [[[CCDirector sharedDirector] view] addSubview:adView];
        }
    }
}

-(void)onExit
{
    [super onExit];
    [adView removeFromSuperview];
    adView = nil;
    screenShot = nil;
}

-(void)setOver:(BOOL)over
{
    _over = over;
    btnContinue.enabled = !over;
}

-(void)setScore:(int)score
{
    _score = score;
}

-(void)setScreenshot:(UIImage *)screenshot
{
    screenShot = screenshot;
}

-(void)btnResetTouch
{
    MainScene *main;
    if(isR4)
    {
        main = (MainScene *)[CCBReader load:@"MainScene-r4"];
    }
    else
    {
        main = (MainScene *)[CCBReader load:@"MainScene"];
    }
    CCScene *scene = [CCScene new];
    [scene addChild:main];
    [main reset];
    [[CCDirector sharedDirector] replaceScene:scene];
}

-(void)btnShareTouch
{
    [UMSocialSnsService presentSnsIconSheetView:(UIViewController *)[CCDirector sharedDirector].view.nextResponder
                                         appKey:@"53ca09da56240bbd9b011e55"
                                      shareText:[NSString stringWithFormat:@"我在细菌博士的游戏中获得了 %i 的分数，你也来试试吧！", _score]
                                     shareImage:screenShot
                                shareToSnsNames:[NSArray arrayWithObjects:UMShareToSina,UMShareToTencent,UMShareToRenren,UMShareToWechatSession,UMShareToWechatTimeline,UMShareToWechatFavorite,nil]
                                       delegate:nil];
}

-(void)btnVirtualStoreTouch
{
    CCScene *s;
    if(isR4)
    {
        s = [CCBReader loadAsScene:@"VirtualStore-r4"];
    }
    else
    {
        s = [CCBReader loadAsScene:@"VirtualStore"];
    }
    
    [[CCDirector sharedDirector] replaceScene:s withTransition:[CCTransition transitionMoveInWithDirection:CCTransitionDirectionLeft duration:.3f]];
}

-(void)btnContinueTouch
{
    MainScene *main;
    if(isR4)
    {
        main = (MainScene *)[CCBReader load:@"MainScene-r4"];
    }
    else
    {
        main = (MainScene *)[CCBReader load:@"MainScene"];
    }
    CCScene *scene = [CCScene new];
    [scene addChild:main];
    [[CCDirector sharedDirector] replaceScene:scene];
}

-(void)btnTop10Touch
{
    [[GameCenterManager sharedGameCenterManager] showLeaderboard];
}

@end
