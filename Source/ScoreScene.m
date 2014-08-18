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

#import <AdSupport/AdSupport.h>

#define dataStorageManagerConfig [DataStorageManager sharedDataStorageManager].config
#define dataExp [DataStorageManager sharedDataStorageManager].exp
#define dataStep [DataStorageManager sharedDataStorageManager].stepCount
#define dataUper [DataStorageManager sharedDataStorageManager].uperCount
#define dataKiller [DataStorageManager sharedDataStorageManager].killerCount

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
    CCButton *btnLoadingMask;
    CCButton *btnMessageMask;
    CCSprite *imgReward;
    CCSprite *spriteLoading;
    CCTextField *iptCode;
    CCLabelTTF *lblLoadingMessage;
    CCLabelTTF *lblMessage;
    CCNode *nodeActivity1;
    CCNode *nodeLoading;
    CCNode *nodeMessage;
    YouMiView *adView;
    UIImage *screenShot;
}

-(void)didLoadFromCCB
{
    isR4 = iPhone5;
    _over = NO;
    nodeActivity1.visible = NO;
    nodeLoading.visible = NO;
    nodeMessage.visible = NO;
    imgReward.visible = NO;
    btnActivity.visible = NO;
    btnMask.enabled = NO;
    btnLoadingMask.enabled = NO;
    btnMessageMask.enabled = NO;
    btnTop10.enabled = [GameCenterManager sharedGameCenterManager].enabled;
    
    CCAnimationManager *animate = spriteLoading.animationManager;
    [animate setCompletedAnimationCallbackBlock:^(id sender)
    {
        [sender runAnimationsForSequenceNamed:@"loading"];
    }];

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
                                         appKey:@"53d22a9c56240b9ab2080b1c"
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
//        NSLog(@"share to sns name is %@",[[response.data allKeys] objectAtIndex:0]);
        if(dataStorageManagerConfig)
        {
            NSDictionary *rewardResult = [dataStorageManagerConfig objectForKey:@"share_reward"];
            int reward = [[rewardResult objectForKey:@"result"] intValue];
            if(reward > 0)
            {
                dataExp = dataExp + reward;
                [[DataStorageManager sharedDataStorageManager] saveData];
                
                [lblMessage setString:[NSString stringWithFormat:@"分享成功！\n奖励%i金币！", reward]];
                nodeMessage.visible = YES;
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
    [[UIApplication sharedApplication]  openURL:[NSURL URLWithString:@"itms-apps://itunes.apple.com/app/id901134887"]];
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
        NSString *idfa = [[[ASIdentifierManager sharedManager] advertisingIdentifier] UUIDString];
        NSDictionary *data = [[NSDictionary alloc] initWithObjectsAndKeys:
                              code, @"code",
                              idfa, @"idfa", nil];
        [[PZWebManager sharedPZWebManager] asyncPostRequest:@"http://b2.profzone.net/activity/download_code" withData:data];
        nodeActivity1.visible = NO;
        nodeLoading.visible = YES;
        [lblLoadingMessage setString:@"加载中..."];
    }
}

-(void)activityDownloadCode:(NSNotification *)notification
{
    NSDictionary *data = [notification object];
    int code = [[data objectForKey:@"code"] intValue];
    if(code == 1001)
    {
        NSDictionary *items = [data objectForKey:@"items"];
        NSArray *keys = [items allKeys];
        int value;
        for(NSString *key in keys)
        {
            if([key isEqualToString:@"gold"])
            {
                value = [[items objectForKey:@"gold"] intValue];
                dataExp = dataExp + value;
            }
            else if([key isEqualToString:@"step"])
            {
                value = [[items objectForKey:@"step"] intValue];
                dataStep = dataStep + value;
            }
            else if([key isEqualToString:@"uper"])
            {
                value = [[items objectForKey:@"uper"] intValue];
                dataUper = dataUper + value;
            }
            else if([key isEqualToString:@"killer"])
            {
                value = [[items objectForKey:@"killer"] intValue];
                dataKiller = dataKiller + value;
            }
        }
        [[DataStorageManager sharedDataStorageManager] saveData];
        
        [lblMessage setString:@"已成功获得奖励"];
        nodeMessage.visible = YES;
    }
    else if(code == 1404)
    {
        [lblMessage setString:@"这个下载码我好像没找到哦"];
        nodeMessage.visible = YES;
    }
    else if(code == 1400)
    {
        [lblMessage setString:@"嗯？我发现这个下载码有问题哦\n我已经通知管理员了，稍等一下吧"];
        nodeMessage.visible = YES;
    }
    else if(code == 1401)
    {
        [lblMessage setString:@"嗯？这个下载码已经使用过了哦"];
        nodeMessage.visible = YES;
    }
    else if(code == 1403)
    {
        [lblMessage setString:@"您的设备已经参加过该活动了哟"];
        nodeMessage.visible = YES;
    }
    else
    {
        [lblMessage setString:@"我已经很努力了\n可是服务器君好像挂啦……"];
        nodeMessage.visible = YES;
    }
    nodeLoading.visible = NO;
}

-(void)activityConnectionError1009:(NSNotification *)notification
{
    nodeLoading.visible = NO;
    [lblMessage setString:@"似乎没有连接互联网哦"];
    nodeMessage.visible = YES;
}

-(void)btnMessageConfirmTouch
{
    nodeMessage.visible = NO;
}

@end
