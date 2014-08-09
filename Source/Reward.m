//
//  Reward.m
//  bacterial2
//
//  Created by 李翌文 on 14-8-7.
//  Copyright (c) 2014年 Apportable. All rights reserved.
//

#import "Reward.h"
#import "MainScene.h"
#import "PZLabelScore.h"
#import "define.h"

@implementation Reward
{
    MainScene *scene;
    PZLabelScore *lblReward;
    CCButton *btnMask;
}

-(void)didLoadFromCCB
{
    btnMask.enabled = NO;
    lblReward = [PZLabelScore initWithScore:0 fileName:@"number/number" itemWidth:14 itemHeight:22];
    if(iPhone5)
    {
        lblReward.position = ccp(160.f, 237.f);
    }
    else
    {
        lblReward.position = ccp(160.f, 195.f);
    }
    [self addChild:lblReward];
}

-(void)onEnter
{
    [super onEnter];
    scene = (MainScene *)self.parent;
}

-(void)btnCloseTouch
{
    scene.isRunning = YES;
    [self removeFromParentAndCleanup:YES];
}

-(void)setRewardGold:(int)rewardGold
{
    _rewardGold = rewardGold;
    [lblReward setScore:rewardGold];
    lblReward.position = ccp((self.contentSize.width - lblReward.contentSize.width) / 2.f, lblReward.position.y);
}

@end
