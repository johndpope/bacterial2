//
//  VirtualStore.m
//  bacterial2
//
//  Created by 李翌文 on 14-7-23.
//  Copyright (c) 2014年 Apportable. All rights reserved.
//

#import "define.h"
#import "VirtualStore.h"
#import "PZLabelScore.h"
#import "DataStorageManager.h"
#import "YouMiWall.h"
#import "MobClickGameAnalytics.h"

#define BUYSTEP50 @"step50"
#define BUYSTEP500 @"step500"
#define BUYUPER1 @"uper1"
#define BUYUPER10 @"uper10"
#define BUYKILLER1 @"killer1"
#define BUYKILLER10 @"killer10"

#define dataExp [DataStorageManager sharedDataStorageManager].exp
#define dataStep [DataStorageManager sharedDataStorageManager].stepCount
#define dataUper [DataStorageManager sharedDataStorageManager].uperCount
#define dataKiller [DataStorageManager sharedDataStorageManager].killerCount
#define dataConfig [DataStorageManager sharedDataStorageManager].config

@implementation VirtualStore
{
    PZLabelScore *lblGold;
    CCButton *btnScoreboard;
    CCLabelTTF *lblCostStep50;
    CCLabelTTF *lblCostStep500;
    CCLabelTTF *lblCostUper1;
    CCLabelTTF *lblCostUper10;
    CCLabelTTF *lblCostKiller1;
    CCLabelTTF *lblCostKiller10;
    CCNode *containerMessage;
    CCButton *btnMask;
    CCButton *btnConfirm;
    CCButton *btnCancel;
    CCLabelTTF *lblMessage;
    
    BOOL isR4;
    BOOL isBuyGold;
    NSString *currentSelected;
    int gold;
    NSDictionary *virtual;
}

-(void)didLoadFromCCB
{
    isR4 = iPhone5;
    
    lblGold = [PZLabelScore initWithScore:0 fileName:@"number/number" itemWidth:14 itemHeight:22];
    lblGold.anchorPoint = ccp(0.f, 0.f);
    if(isR4)
    {
        lblGold.position = ccp(89.f, 468.f);
    }
    else
    {
        lblGold.position = ccp(89.f, 398.f);
    }
    [self addChild:lblGold];
    
    gold = dataExp;
    [lblGold setScore:gold];
    containerMessage.visible = NO;
    btnScoreboard.visible = NO;
    btnMask.enabled = NO;
    currentSelected = 0;
    isBuyGold = NO;
    
    if(dataConfig)
    {
        NSDictionary *virtualResult = [dataConfig objectForKey:@"virtual_const"];
        if(virtualResult)
        {
            virtual = [virtualResult objectForKey:@"result"];
        }
        
        NSDictionary *scoreboardResult = [dataConfig objectForKey:@"score_board"];
        int scoreboard = [[scoreboardResult objectForKey:@"result"] intValue];
        if(scoreboard == 1)
        {
            btnScoreboard.visible = YES;
            int *points = [YouMiPointsManager pointsRemained];
            if(*points > 0)
            {
                [YouMiPointsManager spendPoints:*points];
                dataExp = dataExp + *points;
                [[DataStorageManager sharedDataStorageManager] saveData];
                
                [self setGold:dataExp];
            }
            free(points);
        }
    }
    
    if(!virtual)
    {
        NSString *file = [[NSBundle mainBundle] pathForResource:@"virtual_const" ofType:@"plist"];
        virtual = [[NSDictionary alloc] initWithContentsOfFile:file];
    }
    
    [lblCostStep50 setString:[NSString stringWithFormat:@"%i", [[[virtual objectForKey:@"step50"] objectForKey:@"cost"] intValue]]];
    [lblCostStep500 setString:[NSString stringWithFormat:@"%i", [[[virtual objectForKey:@"step500"] objectForKey:@"cost"] intValue]]];
    [lblCostUper1 setString:[NSString stringWithFormat:@"%i", [[[virtual objectForKey:@"uper1"] objectForKey:@"cost"] intValue]]];
    [lblCostUper10 setString:[NSString stringWithFormat:@"%i", [[[virtual objectForKey:@"uper10"] objectForKey:@"cost"] intValue]]];
    [lblCostKiller1 setString:[NSString stringWithFormat:@"%i", [[[virtual objectForKey:@"killer1"] objectForKey:@"cost"] intValue]]];
    [lblCostKiller10 setString:[NSString stringWithFormat:@"%i", [[[virtual objectForKey:@"killer10"] objectForKey:@"cost"] intValue]]];
}

-(void)btnCloseTouch
{
    CCScene *s;
    if(isR4)
    {
        s = [CCBReader loadAsScene:@"MainScene-r4"];
    }
    else
    {
        s = [CCBReader loadAsScene:@"MainScene"];
    }
    
    [[CCDirector sharedDirector] replaceScene:s];
}

-(void)btnBuyGoldTouch
{
    CCScene *s;
    if(isR4)
    {
        s = [CCBReader loadAsScene:@"StoreScene-r4"];
    }
    else
    {
        s = [CCBReader loadAsScene:@"StoreScene"];
    }
    
    [[CCDirector sharedDirector] replaceScene:s withTransition:[CCTransition transitionMoveInWithDirection:CCTransitionDirectionLeft duration:.3f]];
}

-(void)btnScoreboardTouch
{
    [YouMiWall enable];
    [YouMiWall showOffers:YES didShowBlock:^{
        
    } didDismissBlock:^{
        
    }];
}

-(void)btnStep50Touch
{
    if(virtual)
    {
        int cost = [[[virtual objectForKey:BUYSTEP50] objectForKey:@"cost"] intValue];
        if(gold >= cost)
        {
            currentSelected = BUYSTEP50;
            [self showMessageBox:@"你要购买50步吗？" type:1];
        }
        else
        {
            isBuyGold = YES;
            [self showMessageBox:@"你的金币不够哦，要去购买吗？" type:1];
        }
    }
    else
    {
        [self showMessageBox:@"数据解析错误" type:2];
    }
}

-(void)btnStep500Touch
{
    if(virtual)
    {
        int cost = [[[virtual objectForKey:BUYSTEP500] objectForKey:@"cost"] intValue];
        if(gold >= cost)
        {
            currentSelected = BUYSTEP500;
            [self showMessageBox:@"你要购买500步吗？" type:1];
        }
        else
        {
            isBuyGold = YES;
            [self showMessageBox:@"你的金币不够哦，要去购买吗？" type:1];
        }
    }
    else
    {
        [self showMessageBox:@"数据解析错误" type:2];
    }
}

-(void)btnUper1Touch
{
    if(virtual)
    {
        int cost = [[[virtual objectForKey:BUYUPER1] objectForKey:@"cost"] intValue];
        if(gold >= cost)
        {
            currentSelected = BUYUPER1;
            [self showMessageBox:@"你要购买1个升级器吗？" type:1];
        }
        else
        {
            isBuyGold = YES;
            [self showMessageBox:@"你的金币不够哦，要去购买吗？" type:1];
        }
    }
    else
    {
        [self showMessageBox:@"数据解析错误" type:2];
    }
}

-(void)btnUper10Touch
{
    if(virtual)
    {
        int cost = [[[virtual objectForKey:BUYUPER10] objectForKey:@"cost"] intValue];
        if(gold >= cost)
        {
            currentSelected = BUYUPER10;
            [self showMessageBox:@"你要购买10个升级器吗？" type:1];
        }
        else
        {
            isBuyGold = YES;
            [self showMessageBox:@"你的金币不够哦，要去购买吗？" type:1];
        }
    }
    else
    {
        [self showMessageBox:@"数据解析错误" type:2];
    }
}

-(void)btnKiller1Touch
{
    if(virtual)
    {
        int cost = [[[virtual objectForKey:BUYKILLER1] objectForKey:@"cost"] intValue];
        if(gold >= cost)
        {
            currentSelected = BUYKILLER1;
            [self showMessageBox:@"你要购买1个抑制器吗？" type:1];
        }
        else
        {
            isBuyGold = YES;
            [self showMessageBox:@"你的金币不够哦，要去购买吗？" type:1];
        }
    }
    else
    {
        [self showMessageBox:@"数据解析错误" type:2];
    }
}

-(void)btnKiller10Touch
{
    if(virtual)
    {
        int cost = [[[virtual objectForKey:BUYKILLER10] objectForKey:@"cost"] intValue];
        if(gold >= cost)
        {
            currentSelected = BUYKILLER10;
            [self showMessageBox:@"你要购买10个抑制器吗？" type:1];
        }
        else
        {
            isBuyGold = YES;
            [self showMessageBox:@"你的金币不够哦，要去购买吗？" type:1];
        }
    }
    else
    {
        [self showMessageBox:@"数据解析错误" type:2];
    }
}

-(void)btnConfirmTouch
{
    if (isBuyGold)
    {
        [self btnBuyGoldTouch];
        isBuyGold = NO;
        return;
    }
    if (currentSelected)
    {
        if(virtual)
        {
            int cost = [[[virtual objectForKey:currentSelected] objectForKey:@"cost"] intValue];
            int count;
            if(gold >= cost)
            {
                [self setGold:(gold - cost)];
                if([currentSelected isEqualToString:BUYSTEP50] || [currentSelected isEqualToString:BUYSTEP500])
                {
                    count = [[[[virtual objectForKey:currentSelected] objectForKey:@"additional"] objectForKey:@"step"] intValue];
                    dataStep = dataStep + count;
                    [MobClickGameAnalytics buy:@"step" amount:count price:cost];
                }
                else if([currentSelected isEqualToString:BUYUPER1] || [currentSelected isEqualToString:BUYUPER10])
                {
                    count = [[[[virtual objectForKey:currentSelected] objectForKey:@"additional"] objectForKey:@"uper"] intValue];
                    dataUper = dataUper + count;
                    [MobClickGameAnalytics buy:@"uper" amount:count price:cost];
                }
                else if([currentSelected isEqualToString:BUYKILLER1] || [currentSelected isEqualToString:BUYKILLER10])
                {
                    count = [[[[virtual objectForKey:currentSelected] objectForKey:@"additional"] objectForKey:@"killer"] intValue];
                    dataKiller = dataKiller + count;
                    [MobClickGameAnalytics buy:@"killer" amount:count price:cost];
                }
            }
            else
            {
                [self showMessageBox:@"你的金币不够哦，要去购买吗？" type:1];
            }
            
            [[DataStorageManager sharedDataStorageManager] saveData];
        }
        else
        {
            [self showMessageBox:@"数据解析错误" type:2];
        }
        currentSelected = nil;
    }
    containerMessage.visible = NO;
}

-(void)setGold:(int)g
{
    gold = g;
    [lblGold setScore:g];
    dataExp = g;
}

-(void)btnCancelTouch
{
    if (currentSelected)
    {
        currentSelected = nil;
    }
    containerMessage.visible = NO;
}

-(void)showMessageBox:(NSString *)message type:(int)type
{
    [lblMessage setString:message];
    if(type == 1)
    {
        btnConfirm.position = ccp(-61.f, -40.f);
        btnCancel.visible = YES;
    }
    else
    {
        btnConfirm.position = ccp(0.f, -40.f);
        btnCancel.visible = NO;
    }
    containerMessage.visible = YES;
}

@end
