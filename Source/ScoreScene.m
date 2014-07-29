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
    CCNode *nodeAd;
}

-(void)didLoadFromCCB
{
    isR4 = iPhone5;
    _over = NO;
    
    btnTop10.enabled = [GameCenterManager sharedGameCenterManager].enabled;

    if(dataStorageManagerConfig)
    {
        if(nodeAd)
        {
            NSDictionary *adResult = [dataStorageManagerConfig objectForKey:@"ad"];
            int ad = [[adResult objectForKey:@"result"] intValue];
            if(ad == 0)
            {
                nodeAd.visible = NO;
            }
        }
    }
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

-(void)btnCloseAdTouch
{
    [self removeChild:nodeAd cleanup:YES];
}

-(void)btnAdTouch
{
    [MobClick event:@"touchTaobaoUrl"];
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"http://moesister.taobao.com/"]];
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
    UIImage *screenshot = [[UMSocialScreenShoterCocos2d screenShoter] getScreenShot];
    [UMSocialSnsService presentSnsIconSheetView:(UIViewController *)[CCDirector sharedDirector].view.nextResponder
                                         appKey:@"53ca09da56240bbd9b011e55"
                                      shareText:[NSString stringWithFormat:@"我在细菌培育者中获得了 %i 的生物酶，你也来试试吧！", _score]
                                     shareImage:screenshot
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
