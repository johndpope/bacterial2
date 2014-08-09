//
//  ScoreNode.m
//  bacterial2
//
//  Created by 李翌文 on 14-7-26.
//  Copyright (c) 2014年 Apportable. All rights reserved.
//

#import "define.h"
#import "ScoreNode.h"
#import "ScoreScene.h"
#import "PZLabelScore.h"
#import "MainScene.h"

@implementation ScoreNode
{
    PZLabelScore *lblScore;
    CCButton *btnMessageMask;
    MainScene *mainScene;
}

-(void)didLoadFromCCB
{
    lblScore = [PZLabelScore initWithScore:0 fileName:@"number/number" itemWidth:14 itemHeight:22];
    if(iPhone5)
    {
        lblScore.position = ccp(160.f, 294.f);
    }
    else
    {
        lblScore.position = ccp(160.f, 250.f);
    }
    [self addChild:lblScore];
    
    btnMessageMask.enabled = NO;
}

-(void)onEnter
{
    [super onEnter];
    mainScene = (MainScene *)self.parent;
}

-(void)btnResetTouch
{
    [mainScene reset];
    [self removeFromParentAndCleanup:YES];
}

-(void)btnMenuTouch
{
    ScoreScene *s = [mainScene showScoreScene];
    [s setOver:YES];
}

-(void)btnBuyTouch
{
    CCScene *s;
    if(iPhone5)
    {
        s = [CCBReader loadAsScene:@"VirtualStore-r4"];
    }
    else
    {
        s = [CCBReader loadAsScene:@"VirtualStore"];
    }
    
    [[CCDirector sharedDirector] replaceScene:s withTransition:[CCTransition transitionMoveInWithDirection:CCTransitionDirectionLeft duration:.3f]];
}

-(void)setScore:(int)score
{
    _score = score;
    [lblScore setScore:score];
    lblScore.position = ccp((self.contentSize.width - lblScore.contentSize.width) / 2.f, lblScore.position.y);
}

@end
