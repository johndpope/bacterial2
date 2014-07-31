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

#import "PZWebManager.h"
#import "DataStorageManager.h"
#import "GameCenterManager.h"

#define dataStorageManagerConfig [DataStorageManager sharedDataStorageManager].config
#define dataExp [DataStorageManager sharedDataStorageManager].exp

@implementation ScoreScene
{
    BOOL _over;
    BOOL isR4;
    int _score;
    
    CCButton *btnContinue;
    CCButton *btnScoreboard;
    CCButton *btnTop10;
    CCButton *btnActivity;
    CCButton *btnMask;
    CCSprite *imgReward;
    CCTextField *iptCode;
    CCNode *nodeActivity1;
    YouMiView *adView;
    UIImage *screenShot;
}

-(void)didLoadFromCCB
{
    isR4 = iPhone5;
    _over = NO;
    nodeActivity1.visible = NO;
    imgReward.visible = NO;
    btnActivity.visible = NO;
    btnMask.enabled = NO;
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
        
        NSDictionary *rewardResult = [dataStorageManagerConfig objectForKey:@"share_reward"];
        int reward = [[rewardResult objectForKey:@"result"] intValue];
        if(reward > 0)
        {
            imgReward.visible = YES;
        }
        
        NSDictionary *activityResult = [dataStorageManagerConfig objectForKey:@"activity"];
        int activity = [[activityResult objectForKey:@"result"] intValue];
        if(activity == 1)
        {
            btnActivity.visible = YES;
            [[NSNotificationCenter defaultCenter] removeObserver:self name:@"activityDownloadCode" object:nil];
            [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(activityDownloadCode:) name:@"activityDownloadCode" object:nil];
            [[NSNotificationCenter defaultCenter] removeObserver:self name:@"activityConnectionError1009" object:nil];
            [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(activityConnectionError1009:) name:@"activityConnectionError1009" object:nil];
        }
    }
}

-(void)onExit
{
    [super onExit];
    [adView removeFromSuperview];
    adView = nil;
    screenShot = nil;
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"activityDownloadCode" object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"activityConnectionError1009" object:nil];
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
                                       delegate:self];
}

-(void)didFinishGetUMSocialDataInViewController:(UMSocialResponseEntity *)response
{
    //根据`responseCode`得到发送结果,如果分享成功
    if(response.responseCode == UMSResponseCodeSuccess)
    {
        NSLog(@"share to sns name is %@",[[response.data allKeys] objectAtIndex:0]);
        if(dataStorageManagerConfig)
        {
            NSDictionary *rewardResult = [dataStorageManagerConfig objectForKey:@"share_reward"];
            int reward = [[rewardResult objectForKey:@"result"] intValue];
            if(reward > 0)
            {
                dataExp = dataExp + reward;
                [[DataStorageManager sharedDataStorageManager] saveData];
            }
        }
    }
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

-(void)btnCommentTouch
{
    [[UIApplication sharedApplication]  openURL:[NSURL URLWithString:@"itms-apps://itunes.apple.com/app/id894478844"]];
}

-(void)btnActivityTouch
{
    nodeActivity1.visible = YES;
}

-(void)btnCloseTouch
{
    [iptCode setString:@""];
    nodeActivity1.visible = NO;
}

-(void)btnConfirmTouch
{
    NSString *code = iptCode.string;
    if(![code isEqualToString:@""])
    {
        NSDictionary *data = [[NSDictionary alloc] initWithObjectsAndKeys:code, @"code", nil];
        [[PZWebManager sharedPZWebManager] asyncPostRequest:@"http://b2.profzone.net/activity/download_code" withData:data];
    }
}

-(void)activityDownloadCode:(NSNotification *)notification
{
    
}

-(void)activityConnectionError1009:(NSNotification *)notification
{
    
}

@end
