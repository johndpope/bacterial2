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
#import "PZLabelScore.h"
#import "UMSocial.h"
#import "UMSocialScreenShoter.h"
#import "MobClick.h"
#import "YouMiWall.h"
#import "YouMiPointsManager.h"

#import "CashStoreViewController.h"
#import "UpgradeViewController.h"
#import "DataStorageManager.h"
#import "GameCenterManager.h"

#define dataStorageManagerConfig [DataStorageManager sharedDataStorageManager].config
#define dataStorageManagerAchievement [DataStorageManager sharedDataStorageManager].achievementConst

@implementation ScoreScene
{
    BOOL isR4;
    BOOL _over;
    int _score;
    int _time;
    CGFloat _rate;
    int _exp;
    PZLabelScore *_lblScore;
    PZLabelScore *_lblTime;
    PZLabelScore *_lblRate;
    PZLabelScore *_lblExp;
    CCButton *btnContinue;
    CCButton *btnScoreboard;
    CCButton *btnTop10;
    CCNode *nodeAd;
}

-(void)didLoadFromCCB
{
    if(iPhone5)
    {
        isR4 = YES;
    }
    else
    {
        isR4 = NO;
    }
    _lblScore = [PZLabelScore initWithScore:0 fileName:@"" itemWidth:14 itemHeight:22];
    _lblScore.anchorPoint = ccp(0.f, 0.f);
    if(isR4)
    {
        _lblScore.position = ccp(24.f, 486.f);
    }
    else
    {
        _lblScore.position = ccp(24.f, 410.f);
    }
    [self addChild:_lblScore];

    _lblTime = [PZLabelScore initWithScore:0 fileName:@"" itemWidth:14 itemHeight:22];
    _lblTime.anchorPoint = ccp(0.f, 0.f);
    if(isR4)
    {
        _lblTime.position = ccp(24.f, 416.f);
    }
    else
    {
        _lblTime.position = ccp(24.f, 340.f);
    }
    [self addChild:_lblTime];
    
    _lblRate = [PZLabelScore initWithScore:0 fileName:@"" itemWidth:14 itemHeight:22];
    _lblRate.anchorPoint = ccp(0.f, 0.f);
    if(isR4)
    {
        _lblRate.position = ccp(24.f, 346.f);
    }
    else
    {
        _lblRate.position = ccp(24.f, 270.f);
    }
    [self addChild:_lblRate];

    _lblExp = [PZLabelScore initWithScore:0 fileName:@"" itemWidth:14 itemHeight:22];
    _lblExp.anchorPoint = ccp(0.f, 0.f);
    if(isR4)
    {
        _lblExp.position = ccp(24.f, 281.f);
    }
    else
    {
        _lblExp.position = ccp(24.f, 205.f);
    }
    [self addChild:_lblExp];
    
    _over = NO;
    
    btnTop10.enabled = [GameCenterManager sharedGameCenterManager].enabled;
    btnScoreboard.visible = NO;

    if(dataStorageManagerConfig)
    {
        NSDictionary *scoreboardResult = [dataStorageManagerConfig objectForKey:@"score_board"];
        int scoreboard = [[scoreboardResult objectForKey:@"result"] intValue];
        if(scoreboard == 1)
        {
            btnScoreboard.visible = YES;
            int *points = [YouMiPointsManager pointsRemained];
            if(*points > 0)
            {
                [YouMiPointsManager spendPoints:*points];
                [DataStorageManager sharedDataStorageManager].exp = [DataStorageManager sharedDataStorageManager].exp + *points;
                [[DataStorageManager sharedDataStorageManager] saveData];
                
                [self setExp:[DataStorageManager sharedDataStorageManager].exp];
            }
            free(points);
        }
        
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
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"reloadExp" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reloadExp) name:@"reloadExp" object:nil];
}

-(void)onExit
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"reloadExp" object:nil];
    [super onExit];
}

-(void)reloadExp
{
    [self setExp:[DataStorageManager sharedDataStorageManager].exp];
}

-(void)setOver:(BOOL)over
{
    _over = over;
    btnContinue.enabled = !over;
    if (over)
    {
        [[GameCenterManager sharedGameCenterManager] reportScore:_score];
    }
}

-(void)setScore:(int)score
{
    _score = score;
    [_lblScore setScore:score];

    if([GameCenterManager sharedGameCenterManager].enabled && dataStorageManagerAchievement)
    {
        NSDictionary *goalList = [dataStorageManagerAchievement objectForKey:@"exp"];
        NSArray *goalListKeys = [goalList allKeys];
        NSDictionary *goal;
        for(NSString *key in goalListKeys)
        {
            goal = [goalList objectForKey:key];
            int goalValue = [[goal objectForKey:@"goal"] intValue];
            if(_score > goalValue)
            {
                [[GameCenterManager sharedGameCenterManager] reportAchievementIdentifier:key percentComplete:100.f];
            }
            else
            {
                [[GameCenterManager sharedGameCenterManager] reportAchievementIdentifier:key percentComplete:(CGFloat)(_score / goalValue)];
            }
        }
    }
}

-(void)setRate:(CGFloat)rate
{
    _rate = rate;
    [_lblRate setScore:rate];
}

-(void)setExp:(int)exp
{
    _exp = exp;
    [_lblExp setScore:exp];
}

-(void)setTime:(int)time
{
    _time = time;
    [_lblTime setScore:time];
}

-(void)showScoreboard
{
    [YouMiWall showOffers:YES didShowBlock:^{
        NSLog(@"有米积分墙已显示");
    } didDismissBlock:^{
        NSLog(@"有米积分墙已退出");
    }];
}

-(void)btnCloseAd
{
    [self removeChild:nodeAd cleanup:YES];
}

-(void)btnAdTouch
{
    [MobClick event:@"touchTaobaoUrl"];
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"http://moesister.taobao.com/"]];
}

-(void)back
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

-(void)share
{
    UIImage *screenshot = [[UMSocialScreenShoterCocos2d screenShoter] getScreenShot];
    [UMSocialSnsService presentSnsIconSheetView:(UIViewController *)[CCDirector sharedDirector].view.nextResponder
                                         appKey:@"53ca09da56240bbd9b011e55"
                                      shareText:[NSString stringWithFormat:@"我在细菌培育者中获得了 %i 的生物酶，你也来试试吧！", _score]
                                     shareImage:screenshot
                                shareToSnsNames:[NSArray arrayWithObjects:UMShareToSina,UMShareToTencent,UMShareToRenren,UMShareToWechatSession,UMShareToWechatTimeline,UMShareToWechatFavorite,nil]
                                       delegate:nil];
}

-(void)store
{
    CashStoreViewController *storeView;
    if(isR4)
    {
        storeView = [[CashStoreViewController alloc] initWithNibName:@"CashStoreR4View" bundle:nil];
    }
    else
    {
        storeView = [[CashStoreViewController alloc] initWithNibName:@"CashStoreView" bundle:nil];
    }
    [[[CCDirector sharedDirector] view] addSubview:storeView.view];
}

-(void)upgrade
{
    UpgradeViewController *upgradeView;
    if(isR4)
    {
        upgradeView = [[UpgradeViewController alloc] initWithNibName:@"UpgradeR4View" bundle:nil];
    }
    else
    {
        upgradeView = [[UpgradeViewController alloc] initWithNibName:@"UpgradeView" bundle:nil];
    }
    [[[CCDirector sharedDirector] view] addSubview:upgradeView.view];
}

-(void)continueGame
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

-(void)top10
{
    [[GameCenterManager sharedGameCenterManager] showLeaderboard];
}

@end
