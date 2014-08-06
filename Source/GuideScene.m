//
//  MainScene.m
//  PROJECTNAME
//
//  Created by Viktor on 10/10/13.
//  Copyright (c) 2013 Apportable. All rights reserved.
//

#import "GuideScene.h"
#import "ScoreScene.h"
#import "Becterial.h"
#import "define.h"
#import "PZLabelScore.h"
#import "PZWebManager.h"
#import "CashStoreManager.h"
#import "DataStorageManager.h"
#import "GameCenterManager.h"
#import "ScoreNode.h"
#import "MobClickGameAnalytics.h"
#import "UMSocialScreenShoter.h"

#define defaultStepCount 500
#define dataExp [DataStorageManager sharedDataStorageManager].exp
#define dataStepCount [DataStorageManager sharedDataStorageManager].stepCount
#define dataKillerCount [DataStorageManager sharedDataStorageManager].killerCount
#define dataUperCount [DataStorageManager sharedDataStorageManager].uperCount
#define dataStorageManagerAchievement [DataStorageManager sharedDataStorageManager].achievementConst
#define dataStorageManagerGuide [DataStorageManager sharedDataStorageManager].guide
#define dataStorageManagerGuideStep [DataStorageManager sharedDataStorageManager].guideStep

@implementation GuideScene
{
    BOOL isR4;
    CCLabelTTF *_lblKillerCount;
    CCLabelTTF *_lblUperCount;
    PZLabelScore *_lblExp; //金币
    PZLabelScore *_lblStepCount; //步数
    PZLabelScore *_lblScore; //分数
    CCNode *_container;
    CCButton *imgGuideMask;
    CCSprite *spriteShining;
    CCSprite *spriteShining1;
    CCSprite *spriteBigShining;
    CCSprite *imgContinue;
    CCSprite *imgGuideBoard;
    CCSprite *imgAction;
    CCNode *nodeMessage;
    CCNode *nodeGuide;
    CCNode *nodeLabel;
    CCLabelTTF *lblGuideMessage;
    NSMutableArray *_becterialContainer;
    NSMutableArray *_becterialList;
    NSMutableArray *_enemyList;
    NSMutableArray *_enemyContainer;
    int runningAction;
    CGFloat enemyGenerateTime;
    CGFloat runningTime;
    
    int _lastX;
    int _lastY;
    Becterial *_lastBacterial;

    int bacterialCount;
    int enemyCount;
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
    _isRunning = YES;
    _lblScore = [PZLabelScore initWithScore:0 fileName:@"number/number" itemWidth:14 itemHeight:22];
    if(isR4)
    {
        _lblScore.position = ccp(10.f, 510.f);
    }
    else
    {
        _lblScore.position = ccp(58.f, 456.f);
    }
    [nodeLabel addChild:_lblScore];

    _lblExp = [PZLabelScore initWithScore:0 fileName:@"number/number" itemWidth:14 itemHeight:22];
    if(isR4)
    {
        _lblExp.position = ccp(167.f, 510.f);
    }
    else
    {
        _lblExp.position = ccp(216.f, 456.f);
    }
    [nodeLabel addChild:_lblExp];
    
    _lblStepCount = [PZLabelScore initWithScore:0 fileName:@"number/number" itemWidth:14 itemHeight:22];
    if(isR4)
    {
        _lblStepCount.position = ccp(10.f, 416.f);
    }
    else
    {
        _lblStepCount.position = ccp(10.f, 390.f);
    }
    [nodeLabel addChild:_lblStepCount];
    
    _isRunning = NO;
    _maxLevel = 0;
    self.userInteractionEnabled = YES;
    
    [spriteShining.animationManager setCompletedAnimationCallbackBlock:^(id sender)
     {
         [sender runAnimationsForSequenceNamed:@"loop"];
     }];
    [spriteShining1.animationManager setCompletedAnimationCallbackBlock:^(id sender)
     {
         [sender runAnimationsForSequenceNamed:@"loop"];
     }];
    [spriteBigShining.animationManager setCompletedAnimationCallbackBlock:^(id sender)
     {
         [sender runAnimationsForSequenceNamed:@"loop"];
     }];
}

// -(void)update:(CCTime)delta
// {
//     if(_isRunning)
//     {
//         runningTime = runningTime + delta;
//         enemyGenerateTime = enemyGenerateTime + delta;
//         if(runningTime <= 121.f)
//         {
//             if(enemyGenerateTime >= 30.f)
//             {
//                 //产生新的生物虫
//                 [self putNewEnemy:1 telent:YES];
//                 enemyGenerateTime = 0.f;
//             }
//         }
//         else if(runningTime <= 301.f)
//         {
//             if(enemyGenerateTime >= 20.f)
//             {
//                 //产生新的生物虫
//                 [self putNewEnemy:(arc4random() % 3) telent:YES];
//                 enemyGenerateTime = 0.f;
//             }
//         }
//         else if(runningTime <= 601.f)
//         {
//             if(enemyGenerateTime >= 10.f)
//             {
//                 //产生新的生物虫
//                 [self putNewEnemy:(arc4random() % 3) telent:YES];
//                 enemyGenerateTime = 0.f;
//             }
//         }
//         else if(runningTime <= 901.f)
//         {
//             if(enemyGenerateTime >= 5.f)
//             {
//                 //产生新的生物虫
//                 [self putNewEnemy:(arc4random() % 3) telent:YES];
//                 enemyGenerateTime = 0.f;
//             }
//         }
//         else
//         {
//             if(enemyGenerateTime >= 3.f)
//             {
//                 //产生新的生物虫
//                 [self putNewEnemy:(arc4random() % 3) telent:YES];
//                 enemyGenerateTime = 0.f;
//             }
//         }
//     }
// }

-(void)prepareStage
{
    int capacityX = 5;
    int capacityY = 6;
    _becterialContainer = [NSMutableArray arrayWithCapacity:capacityX];
    _enemyContainer = [NSMutableArray arrayWithCapacity:capacityX];
    for (int i = 0; i < capacityX; i++)
    {
        NSMutableArray *_tmp = [NSMutableArray arrayWithCapacity:capacityY];
        NSMutableArray *_tmp1 = [NSMutableArray arrayWithCapacity:capacityY];
        for (int j = 0; j < capacityY; j++)
        {
            [_tmp addObject:[NSNull null]];
            [_tmp1 addObject:[NSNumber numberWithBool:YES]];
        }
        [_becterialContainer addObject:_tmp];
        [_enemyContainer addObject:_tmp1];
    }
    
    if([self loadGame])
    {
        for (int i = 0; i < [_becterialList count]; i++)
        {
            Becterial *b = [_becterialList objectAtIndex:i];
            b.anchorPoint = ccp(.5f, .5f);
            NSMutableArray *tmp = [_becterialContainer objectAtIndex:b.positionX];
            [tmp replaceObjectAtIndex:b.positionY withObject:b];
            b.position = ccp(b.positionX * 60.5f + 30.f, b.positionY * 60.5f + 30.f);
            [_container addChild:b];
        }
        [self checkResult];
    }
    else
    {
        _becterialList = [[NSMutableArray alloc] init];
        _enemyList = [[NSMutableArray alloc] init];
        self.stepCount = defaultStepCount;
        self.exp = 2000;
        self.killerCount = 10;
        self.uperCount = 10;
        _maxLevel = 0;
    }
}

-(void)didReceiveGuideNotification:(NSNotification *) notification
{
    if([notification.name isEqualToString:@"guideClickBiomass"])
    {
        self.guideStep++;
    }
    else if([notification.name isEqualToString:@"guideFinish"])
    {
        [[NSNotificationCenter defaultCenter] removeObserver:self name:@"guideClickBiomass" object:nil];
        [[NSNotificationCenter defaultCenter] removeObserver:self name:@"guideClickScore" object:nil];
        [[NSNotificationCenter defaultCenter] removeObserver:self name:@"guideClickEnemy" object:nil];
        [[NSNotificationCenter defaultCenter] removeObserver:self name:@"guideClickBacterial" object:nil];
        [[NSNotificationCenter defaultCenter] removeObserver:self name:@"guideClickBiomass2" object:nil];
        [[NSNotificationCenter defaultCenter] removeObserver:self name:@"guideClickScore2" object:nil];
        [[NSNotificationCenter defaultCenter] removeObserver:self name:@"guideClickEnemy2" object:nil];
        [[NSNotificationCenter defaultCenter] removeObserver:self name:@"guideClickBacterial2" object:nil];
        [[NSNotificationCenter defaultCenter] removeObserver:self name:@"guideTouchBacterial" object:nil];
        [[NSNotificationCenter defaultCenter] removeObserver:self name:@"guideTouchBacterialEnd" object:nil];
        [[NSNotificationCenter defaultCenter] removeObserver:self name:@"guideFinish" object:nil];
    }
}

-(void)onEnter
{
    [super onEnter];
    [self prepareStage];
}

-(void)onExit
{
    [super onExit];

    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"guideClickBiomass" object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"guideClickScore" object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"guideClickEnemy" object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"guideClickBacterial" object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"guideClickBiomass2" object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"guideClickScore2" object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"guideClickEnemy2" object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"guideClickBacterial2" object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"guideTouchBacterial" object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"guideTouchBacterialEnd" object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"guideFinish" object:nil];

    [self saveGame];
}

-(void)touchBegan:(UITouch *)touch withEvent:(UIEvent *)event
{
    CGPoint position = [touch locationInWorld];
    position = [_container convertToNodeSpace:position];
    
    int x = position.x / 60.5f;
    int y = position.y / 60.5f;
    
    if(_guideStep == 1)
    {
        self.guideStep++;
    }
    else if(_guideStep == 2)
    {
        self.guideStep++;
    }
    else if(_guideStep == 3)
    {
        if (x == 1 && y == 4)
        {
            [self putNewBacterial:x andY:y];
            self.guideStep++;
        }
    }
    else if(_guideStep == 4)
    {
        if (x == 2 && y == 4)
        {
            [self putNewBacterial:x andY:y];
            self.guideStep++;
        }
    }
    else if(_guideStep == 5)
    {
        if (x == 3 && y == 4)
        {
            [self putNewBacterial:x andY:y];
            self.guideStep++;
        }
    }
    else if(_guideStep == 6)
    {
        self.guideStep++;
    }
    else if(_guideStep == 7)
    {
        self.guideStep++;
    }
    else if(_guideStep == 8)
    {
        if (x == 1 && y == 4)
        {
            [self putNewBacterial:x andY:y];
            self.guideStep++;
        }
    }
    else if(_guideStep == 9)
    {
        if (x == 1 && y == 3)
        {
            [self putNewBacterial:x andY:y];
            self.guideStep++;
        }
    }
    else if(_guideStep == 10)
    {
        if (x == 1 && y == 2)
        {
            [self putNewBacterial:x andY:y];
            [self evolution];
            self.guideStep++;
        }
    }
    else if(_guideStep == 11)
    {
        if (x == 1 && y == 2)
        {
            [self putNewBacterial:x andY:y];
            self.guideStep++;
        }
    }
    else if(_guideStep == 12)
    {
        if (x == 2 && y == 2)
        {
            [self putNewBacterial:x andY:y];
            self.guideStep++;
        }
    }
    else if(_guideStep == 13)
    {
        self.guideStep++;
    }
    else if(_guideStep == 14)
    {
        self.guideStep++;
    }
    else if(_guideStep == 15)
    {
        if (x == 1 && y == 1)
        {
            [self putNewBacterial:x andY:y];
            self.guideStep++;
        }
    }
    else if(_guideStep == 16)
    {
        if (x == 2 && y == 1)
        {
            [self putNewBacterial:x andY:y];
            self.guideStep++;
        }
    }
    else if(_guideStep == 17)
    {
        if (x == 3 && y == 1)
        {
            [self putNewBacterial:x andY:y];
            [self evolution];
            self.guideStep++;
        }
    }
    else if(_guideStep == 19)
    {
        if (x == 4 && y == 4)
        {
            [self putNewBacterial:x andY:y];
            self.guideStep++;
        }
    }
    else if(_guideStep == 20)
    {
        if (x == 4 && y == 3)
        {
            [self putNewBacterial:x andY:y];
            self.guideStep++;
        }
    }
    else if(_guideStep == 21)
    {
        if (x == 4 && y == 2)
        {
            [self putNewBacterial:x andY:y];
            [self evolution];
            self.guideStep++;
        }
    }
    else if(_guideStep == 23)
    {
        [self checkResult];
        self.guideStep++;
    }
    else if(_guideStep == 24)
    {
        self.guideStep++;
    }
    else if(_guideStep == 25)
    {
        self.guideStep++;
    }
    else if(_guideStep == 26)
    {
        self.guideStep++;
    }
    else if(_guideStep == 27)
    {
        self.guideStep++;
    }
    else if(_guideStep == 32)
    {
        self.guideStep++;
    }
    else if(_guideStep == 33)
    {
        self.guideStep++;
    }
    else
    {
        _score = 0;
        _maxLevel = 0;
        bacterialCount = 0;
        enemyCount = 0;
        enemyGenerateTime = 0;
        runningTime = 0;
        dataExp = dataExp - 10;
        dataStepCount = defaultStepCount;
        dataStorageManagerGuide = NO;
        dataKillerCount = dataKillerCount + 1;
        dataUperCount = dataUperCount + 3;
        [_becterialList removeAllObjects];
        [self saveGame];
        
        CCScene *scene;
        if(isR4)
        {
            scene = [CCBReader loadAsScene:@"MainScene-r4"];
        }
        else
        {
            scene = [CCBReader loadAsScene:@"MainScene"];
        }
        [[CCDirector sharedDirector] replaceScene:scene];
    }
    [self saveGame];
}

-(BOOL)generateBacterial:(int)type
{
    return [self generateBacterial:type level:1];
}

-(BOOL)generateBacterial:(int)type level:(int)level
{
    if(type == 0 || type == 1)
    {
        Becterial *bacterial;
        NSMutableArray *list = [[NSMutableArray alloc] init];
        NSMutableArray *listFirst = [[NSMutableArray alloc] init];
        NSMutableArray *tmp1;
        for (int i = 0; i < [_becterialContainer count]; i++)
        {
            NSMutableArray *tmp = [_becterialContainer objectAtIndex:i];
            for (int j = 0; j < [tmp count]; j++)
            {
                if([tmp objectAtIndex:j] == [NSNull null])
                {
                    CGPoint p = ccp(i, j);
                    [list addObject:[NSValue valueWithCGPoint:p]];

                    if(type == 1)
                    {
                        //如果是生物虫，还要筛选没有被包围的空格
                        BOOL top = j == 5;
                        BOOL left = i == 0;
                        BOOL bottom = j == 0;
                        BOOL right = i == 4;

                        if(!top)
                        {
                            tmp1 = [_becterialContainer objectAtIndex:i];
                            if([tmp1 objectAtIndex:j + 1] != [NSNull null])
                            {
                                bacterial = (Becterial *)[tmp1 objectAtIndex:j + 1];
                                if(bacterial.level > level)
                                {
                                    top = YES;
                                }
                            }

                            if(!top)
                            {
                                [listFirst addObject:[NSValue valueWithCGPoint:p]];
                                continue;
                            }
                        }

                        if(!left)
                        {
                            tmp1 = [_becterialContainer objectAtIndex:i - 1];
                            if([tmp1 objectAtIndex:j] != [NSNull null])
                            {
                                bacterial = (Becterial *)[tmp1 objectAtIndex:j];
                                if(bacterial.level > level)
                                {
                                    left = YES;
                                }
                            }

                            if(!left)
                            {
                                [listFirst addObject:[NSValue valueWithCGPoint:p]];
                                continue;
                            }
                        }

                        if(!bottom)
                        {
                            tmp1 = [_becterialContainer objectAtIndex:i];
                            if([tmp1 objectAtIndex:j - 1] != [NSNull null])
                            {
                                bacterial = (Becterial *)[tmp1 objectAtIndex:j - 1];
                                if(bacterial.level > level)
                                {
                                    bottom = YES;
                                }
                            }

                            if(!bottom)
                            {
                                [listFirst addObject:[NSValue valueWithCGPoint:p]];
                                continue;
                            }
                        }

                        if(!right)
                        {
                            tmp1 = [_becterialContainer objectAtIndex:i + 1];
                            if([tmp1 objectAtIndex:j] != [NSNull null])
                            {
                                bacterial = (Becterial *)[tmp1 objectAtIndex:j];
                                if(bacterial.level > level)
                                {
                                    right = YES;
                                }
                            }

                            if(!right)
                            {
                                [listFirst addObject:[NSValue valueWithCGPoint:p]];
                                continue;
                            }
                        }
                    }
                }
            }
        }

        if(type == 1)
        {
            long firstCount = [listFirst count];
            if(firstCount > 0)
            {
                CGPoint position = [[listFirst objectAtIndex:(arc4random() % firstCount)] CGPointValue];
                return [self generateBacterial:type x:position.x y:position.y level:level];
            }
        }

        long count = [list count];
        if(count > 0)
        {
            CGPoint position = [[list objectAtIndex:(arc4random() % count)] CGPointValue];
            return [self generateBacterial:type x:position.x y:position.y level:level];
        }
    }
    return NO;
}

-(BOOL)generateBacterial:(int)type x:(int)x y:(int)y
{
    return [self generateBacterial:type x:x y:y level:1];
}

-(BOOL)generateBacterial:(int)type x:(int)x y:(int)y level:(int)level
{
    if(type == 0 || type == 1)
    {
        level = fmax(1, fmin(MAXLEVEL, level));
        NSMutableArray *tmp = [_becterialContainer objectAtIndex:x];
        if([tmp objectAtIndex:y] == [NSNull null])
        {
            Becterial *b = [[Becterial alloc] init];
            b.positionX = x;
            b.positionY = y;
            b.anchorPoint = ccp(.5f, .5f);
            b.type = type;
            b.level = level;
            b.position = ccp(x * 60.5f + 30.f, y * 60.5f + 30.f);
            [_container addChild:b];
            self.maxLevel = 1;
            
            NSMutableArray *_tmp = [_becterialContainer objectAtIndex:x];
            [_tmp replaceObjectAtIndex:y withObject:b];
            [_becterialList addObject:b];
            if(type == 1)
            {
                [_enemyList addObject:b];
            }
            
            return YES;
        }
    }
    return NO;
}

-(void)moveBecterial:(Becterial *)becterial x:(int)x y:(int)y
{
    if (dataStorageManagerGuide && (_guideStep == 18 || _guideStep == 22))
    {
        if (x == 2 && y == 2)
        {
            self.guideStep++;
        }
        else if(x == 3 && y == 3)
        {
            self.guideStep++;
        }
        else
        {
            return;
        }
        
        NSMutableArray *tmp = [_becterialContainer objectAtIndex:x];
        if([tmp objectAtIndex:y] == [NSNull null] && self.stepCount > 0)
        {
            [tmp replaceObjectAtIndex:y withObject:becterial];
            tmp = [_becterialContainer objectAtIndex:becterial.positionX];
            [tmp replaceObjectAtIndex:becterial.positionY withObject:[NSNull null]];
            becterial.positionX = x;
            becterial.positionY = y;
            
            CCActionMoveTo *aMoveTo = [CCActionMoveTo actionWithDuration:.2f position:ccp(x * 60.5f + 30.f, y * 60.5f + 30.f)];
            CCActionCallBlock *aCallBlock = [CCActionCallBlock actionWithBlock:^(void)
            {
                runningAction--;
                if(runningAction == 0)
                {
                    if(![self evolution])
                    {
                        [self saveGame];
                    }
                }
            }];
            self.stepCount--;
            [becterial runAction:[CCActionSequence actionWithArray:@[aMoveTo, aCallBlock]]];
            runningAction++;
        }
    }
}

-(BOOL)isEvolution:(Becterial *)becterial
{
    if (becterial.type == 0 && becterial.level > 0)
    {
        if((becterial.positionX == 0 && becterial.positionY == 5) ||
           (becterial.positionX == 4 && becterial.positionY == 5) ||
           (becterial.positionX == 0 && becterial.positionY == 0) ||
           (becterial.positionX == 4 && becterial.positionY == 0))
        {
            return NO;
        }

        Becterial *other1;
        Becterial *other2;
        NSMutableArray *list = [[NSMutableArray alloc] init];
        
        int startX = becterial.positionX;
        int startY = becterial.positionY;
        int currentX1, currentX2;
        int currentY1, currentY2;
        NSMutableArray *tmp;

        //按照横竖左上右上的顺序判断是否在一条线上
        //横
        currentX1 = startX - 1;
        currentX2 = startX + 1;
        if(currentX1 >= 0 && currentX2 <= 4)
        {
            tmp = [_becterialContainer objectAtIndex:currentX1];
            if([tmp objectAtIndex:startY] != [NSNull null])
            {
                other1 = (Becterial *)[tmp objectAtIndex:startY];
                if(other1 != becterial && other1.type == 0 && other1.level == becterial.level)
                {
                    tmp = [_becterialContainer objectAtIndex:currentX2];
                    if([tmp objectAtIndex:startY] != [NSNull null])
                    {
                        other2 = (Becterial *)[tmp objectAtIndex:startY];
                        if(other2 != becterial && other2.type == 0 && other2.level == becterial.level)
                        {
                            [list addObject:other1];
                            [list addObject:other2];
                            [self doEvolution:list withBacterial:becterial];
                            return YES;
                        }
                    }
                }
            }
        }
        //竖
        currentY1 = startY + 1;
        currentY2 = startY - 1;
        if(currentY2 >= 0 && currentY1 <= 5)
        {
            tmp = [_becterialContainer objectAtIndex:startX];
            if([tmp objectAtIndex:currentY1] != [NSNull null])
            {
                other1 = (Becterial *)[tmp objectAtIndex:currentY1];
                if(other1 != becterial && other1.type == 0 && other1.level == becterial.level)
                {
                    tmp = [_becterialContainer objectAtIndex:startX];
                    if([tmp objectAtIndex:currentY2] != [NSNull null])
                    {
                        other2 = (Becterial *)[tmp objectAtIndex:currentY2];
                        if(other2 != becterial && other2.type == 0 && other2.level == becterial.level)
                        {
                            [list addObject:other1];
                            [list addObject:other2];
                            [self doEvolution:list withBacterial:becterial];
                            return YES;
                        }
                    }
                }
            }
        }
        //左上
        currentX1 = startX - 1;
        currentX2 = startX + 1;
        currentY1 = startY + 1;
        currentY2 = startY - 1;
        if(currentX1 >= 0 && currentY1 <= 5 && currentX2 <= 4 && currentY2 >= 0)
        {
            tmp = [_becterialContainer objectAtIndex:currentX1];
            if([tmp objectAtIndex:currentY1] != [NSNull null])
            {
                other1 = (Becterial *)[tmp objectAtIndex:currentY1];
                if(other1 != becterial && other1.type == 0 && other1.level == becterial.level)
                {
                    tmp = [_becterialContainer objectAtIndex:currentX2];
                    if([tmp objectAtIndex:currentY2] != [NSNull null])
                    {
                        other2 = (Becterial *)[tmp objectAtIndex:currentY2];
                        if(other2 != becterial && other2.type == 0 && other2.level == becterial.level)
                        {
                            [list addObject:other1];
                            [list addObject:other2];
                            [self doEvolution:list withBacterial:becterial];
                            return YES;
                        }
                    }
                }
            }
        }
        //右上
        currentX1 = startX + 1;
        currentX2 = startX - 1;
        currentY1 = startY + 1;
        currentY2 = startY - 1;
        if(currentX1 <= 4 && currentY1 <= 5 && currentX2 >= 0 && currentY2 >= 0)
        {
            tmp = [_becterialContainer objectAtIndex:currentX1];
            if([tmp objectAtIndex:currentY1] != [NSNull null])
            {
                other1 = (Becterial *)[tmp objectAtIndex:currentY1];
                if(other1 != becterial && other1.type == 0 && other1.level == becterial.level)
                {
                    tmp = [_becterialContainer objectAtIndex:currentX2];
                    if([tmp objectAtIndex:currentY2] != [NSNull null])
                    {
                        other2 = (Becterial *)[tmp objectAtIndex:currentY2];
                        if(other2 != becterial && other2.type == 0 && other2.level == becterial.level)
                        {
                            [list addObject:other1];
                            [list addObject:other2];
                            [self doEvolution:list withBacterial:becterial];
                            return YES;
                        }
                    }
                }
            }
        }
    }
    return NO;
}

-(void)doEvolution:(NSMutableArray *)list withBacterial:(Becterial *)becterial
{

    BOOL isCallback = NO;
    Becterial *other;
    for(int m = 0; m < [list count]; m++)
    {
        other = [list objectAtIndex:m];
        [[_becterialContainer objectAtIndex:other.positionX] replaceObjectAtIndex:other.positionY withObject:[NSNull null]];
        
        CCActionMoveTo *aMoveTo = [CCActionMoveTo actionWithDuration:.2f position:ccp(becterial.position.x, becterial.position.y)];
        CCActionRemove *aRemove = [CCActionRemove action];
        if(!isCallback)
        {
            CCActionCallBlock *aCallBlock = [CCActionCallBlock actionWithBlock:^(void)
            {
                becterial.level++;
                self.score = _score + BACTERIAL_BASIC_SCORE * pow(2, becterial.level - 1);
                self.maxLevel = becterial.level;
                
                [[NSNotificationCenter defaultCenter] postNotificationName:@"guideRevolutionDone" object:nil];
                
                runningAction--;
                if(runningAction == 0)
                {
                    //进化动画结束
                    if(![self evolution])
                    {
                        [self saveGame];
                        [self checkResult];
                    }
                }
            }];
            isCallback = YES;
            [other runAction:[CCActionSequence actionWithArray:@[aMoveTo, aRemove, aCallBlock]]];
            runningAction++;
        }
        else
        {
            [other runAction:[CCActionSequence actionWithArray:@[aMoveTo, aRemove]]];
        }
        [_becterialList removeObjectIdenticalTo:other];
    }
}

-(BOOL)evolution
{
    BOOL result = YES;
    for(int i = 0; i < [_becterialList count]; i++)
    {
        Becterial *b = [_becterialList objectAtIndex:i];
        if(![self isEvolution:b])
        {
            result = NO;
        }
    }
    return result;
}

-(void)putNewBacterial:(int)x andY:(int)y
{
    if([self generateBacterial:0 x:x y:y])
    {
        self.score = _score + BACTERIAL_BASIC_SCORE;
        
        // if(![self evolution])
        // {
        //     [self saveGame];
        // }

        // [self checkResult];
    }
}

-(void)putNewEnemy:(int)level telent:(BOOL)telent
{
    if(!telent)
    {
        [self putNewEnemy:1];
    }
    else
    {
        Becterial *bacterial;
        NSMutableArray *list = [[NSMutableArray alloc] init];
        NSMutableArray *listFirst = [[NSMutableArray alloc] init];
        NSMutableArray *tmp1;
        for (int i = 0; i < [_becterialContainer count]; i++)
        {
            NSMutableArray *tmp = [_becterialContainer objectAtIndex:i];
            for (int j = 0; j < [tmp count]; j++)
            {
                if([tmp objectAtIndex:j] == [NSNull null])
                {
                    CGPoint p = ccp(i, j);
                    [list addObject:[NSValue valueWithCGPoint:p]];

                    BOOL top = j == 5;
                    BOOL left = i == 0;
                    BOOL bottom = j == 0;
                    BOOL right = i == 4;

                    if(!top)
                    {
                        tmp1 = [_becterialContainer objectAtIndex:i];
                        if([tmp1 objectAtIndex:j + 1] != [NSNull null])
                        {
                            bacterial = (Becterial *)[tmp1 objectAtIndex:j + 1];
                            if(bacterial.level > 1)
                            {
                                top = YES;
                            }
                        }

                        if(!top)
                        {
                            [listFirst addObject:[NSValue valueWithCGPoint:p]];
                            continue;
                        }
                    }

                    if(!left)
                    {
                        tmp1 = [_becterialContainer objectAtIndex:i - 1];
                        if([tmp1 objectAtIndex:j] != [NSNull null])
                        {
                            bacterial = (Becterial *)[tmp1 objectAtIndex:j];
                            if(bacterial.level > 1)
                            {
                                left = YES;
                            }
                        }

                        if(!left)
                        {
                            [listFirst addObject:[NSValue valueWithCGPoint:p]];
                            continue;
                        }
                    }

                    if(!bottom)
                    {
                        tmp1 = [_becterialContainer objectAtIndex:i];
                        if([tmp1 objectAtIndex:j - 1] != [NSNull null])
                        {
                            bacterial = (Becterial *)[tmp1 objectAtIndex:j - 1];
                            if(bacterial.level > 1)
                            {
                                bottom = YES;
                            }
                        }

                        if(!bottom)
                        {
                            [listFirst addObject:[NSValue valueWithCGPoint:p]];
                            continue;
                        }
                    }

                    if(!right)
                    {
                        tmp1 = [_becterialContainer objectAtIndex:i + 1];
                        if([tmp1 objectAtIndex:j] != [NSNull null])
                        {
                            bacterial = (Becterial *)[tmp1 objectAtIndex:j];
                            if(bacterial.level > 1)
                            {
                                right = YES;
                            }
                        }

                        if(!right)
                        {
                            [listFirst addObject:[NSValue valueWithCGPoint:p]];
                            continue;
                        }
                    }
                }
            }
        }
//        int index = 0;
        long firstCount = [listFirst count];
        if(firstCount > 0)
        {
            CGPoint position = [[listFirst objectAtIndex:(arc4random() % firstCount)] CGPointValue];

            [listFirst removeAllObjects];
            listFirst = nil;
            if([self generateBacterial:1 x:position.x y:position.y level:level])
            {
                // [self checkResult];
            }
            return;
        }

        long count = [list count];
        if(count > 0)
        {
            CGPoint position = [[list objectAtIndex:(arc4random() % count)] CGPointValue];
            Becterial *leftBecterial = position.x > 0 ? (Becterial *)[[_becterialContainer objectAtIndex:(position.x - 1)] objectAtIndex:position.y] : nil;
            Becterial *rightBecterial = position.x < 4 ? (Becterial *)[[_becterialContainer objectAtIndex:(position.x + 1)] objectAtIndex:position.y] : nil;
            Becterial *topBecterial = position.y < 5 ? (Becterial *)[[_becterialContainer objectAtIndex:position.x] objectAtIndex:(position.y + 1)] : nil;
            Becterial *bottomBecterial = position.y > 0 ? (Becterial *)[[_becterialContainer objectAtIndex:position.x] objectAtIndex:(position.y - 1)] : nil;
            if(leftBecterial && leftBecterial.level > level)
            {
                level = leftBecterial.level;
            }
            if(rightBecterial && rightBecterial.level > level)
            {
                level = rightBecterial.level;
            }
            if(topBecterial && topBecterial.level > level)
            {
                level = topBecterial.level;
            }
            if(bottomBecterial && bottomBecterial.level > level)
            {
                level = bottomBecterial.level;
            }
            level = fmax(1, level);

            [list removeAllObjects];
            list = nil;
            if([self generateBacterial:1 x:position.x y:position.y level:level])
            {
                // [self checkResult];
            }
            return;
        }
    }
}

-(void)putNewEnemy
{
    [self putNewEnemy:1];
}

-(void)putNewEnemy:(int)level
{
    if([self generateBacterial:1 level:level])
    {
        // if(![self evolution])
        // {
        //     [self saveGame];
        // }

        // [self checkResult];
    }
}

-(void)putNewEnemy:(int)x andY:(int)y
{
    [self putNewEnemy:x andY:y level:1];
}

-(void)putNewEnemy:(int)x andY:(int)y level:(int)level
{
    if([self generateBacterial:1 x:x y:y level:level])
    {
        // if(![self evolution])
        // {
        //     [self saveGame];
        // }

        // [self checkResult];
    }
}

-(void)btnSkipTouch
{
    _score = 0;
    _maxLevel = 0;
    bacterialCount = 0;
    enemyCount = 0;
    enemyGenerateTime = 0;
    runningTime = 0;
    dataStorageManagerGuide = NO;
    [_becterialList removeAllObjects];
    [self saveGame];
    
    CCScene *scene;
    if(isR4)
    {
        scene = [CCBReader loadAsScene:@"MainScene-r4"];
    }
    else
    {
        scene = [CCBReader loadAsScene:@"MainScene"];
    }
    [[CCDirector sharedDirector] replaceScene:scene];
}

-(void)setStepCount:(int)stepCount
{
    if(_stepCount != stepCount)
    {
        _stepCount = stepCount;
        _lblStepCount.score = stepCount;
        dataStepCount = stepCount;
    }
}

-(void)setScore:(CGFloat)score
{
    if(_score != score)
    {
        _score = score;
        _lblScore.score = score;
    }
}

-(void)setExp:(int)exp
{
    if(_exp != exp)
    {
        _exp = exp;
        _lblExp.score = exp;
        dataExp = exp;
    }
}

-(void)setKillerCount:(int)killerCount
{
    if(_killerCount != killerCount)
    {
        _killerCount = killerCount;
        [_lblKillerCount setString:[NSString stringWithFormat:@"%i", killerCount]];
        dataKillerCount = killerCount;
    }
}

-(void)setUperCount:(int)uperCount
{
    if(_uperCount != uperCount)
    {
        _uperCount = uperCount;
        [_lblUperCount setString:[NSString stringWithFormat:@"%i", uperCount]];
        dataUperCount = uperCount;
    }
}

-(void)setMaxLevel:(int)maxLevel
{
    if(maxLevel > _maxLevel)
    {
        _maxLevel = maxLevel;

        if([GameCenterManager sharedGameCenterManager].enabled && dataStorageManagerAchievement)
        {
            NSDictionary *goalList = [dataStorageManagerAchievement objectForKey:@"level"];
            NSArray *goalListKeys = [goalList allKeys];
            NSDictionary *goal;
            for(NSString *key in goalListKeys)
            {
                goal = [goalList objectForKey:key];
                int goalValue = [[goal objectForKey:@"goal"] intValue];
                if(_maxLevel >= goalValue)
                {
                    [[GameCenterManager sharedGameCenterManager] reportAchievementIdentifier:key percentComplete:100.f];
                }
                else
                {
                    [[GameCenterManager sharedGameCenterManager] reportAchievementIdentifier:key percentComplete:(CGFloat)(_maxLevel / goalValue)];
                }
            }
        }
    }
}

-(void)setGuideStep:(int)guideStep
{
    if(_guideStep != guideStep)
    {
        _guideStep = guideStep;
        dataStorageManagerGuideStep = guideStep;
        
        switch (_guideStep)
        {
            case 1:
            {
                
                nodeMessage.positionType = CCPositionTypeNormalized;
                nodeMessage.position = ccp(.5f, .5f);
                imgAction.visible = NO;
                spriteShining.visible = NO;
                spriteShining1.visible = NO;
                spriteBigShining.visible = NO;
                imgGuideMask.visible = YES;
                imgContinue.visible = YES;
                [lblGuideMessage setString:@"嗨！欢迎来到细菌博士，我的新朋友。\n我将为你讲解一下该做些什么。"];
            }
            break;
            case 2:
            {
                
                nodeMessage.positionType = CCPositionTypePoints;
                nodeMessage.position = ccp(160.f, 420.f);
                imgAction.visible = NO;
                spriteShining.visible = NO;
                spriteShining1.visible = NO;
                spriteBigShining.visible = YES;
                imgGuideMask.visible = YES;
                imgContinue.visible = YES;
                [lblGuideMessage setString:@"这个5x6的区域叫做培养皿\n点击每个格子就能放置一个细菌。"];
            }
            break;
            case 3:
            {
                
                nodeMessage.positionType = CCPositionTypePoints;
                nodeMessage.position = ccp(160.f, 50.f);
                imgAction.visible = NO;
                spriteShining.visible = YES;
                spriteShining1.visible = NO;
                spriteShining.position = ccp(100.f, 283.f);
                spriteBigShining.visible = NO;
                imgGuideMask.visible = NO;
                imgContinue.visible = NO;
                [lblGuideMessage setString:@"触摸这里放置你的第一个细菌吧。"];
            }
            break;
            case 4:
            {
                
                nodeMessage.positionType = CCPositionTypePoints;
                nodeMessage.position = ccp(160.f, 50.f);
                imgAction.visible = NO;
                spriteShining.visible = YES;
                spriteShining1.visible = NO;
                spriteShining.position = ccp(161.f, 283.f);
                spriteBigShining.visible = NO;
                imgGuideMask.visible = NO;
                imgContinue.visible = NO;
                [lblGuideMessage setString:@"再在旁边放置第二个细菌。"];
            }
            break;
            case 5:
            {
                
                nodeMessage.positionType = CCPositionTypePoints;
                nodeMessage.position = ccp(160.f, 50.f);
                imgAction.visible = NO;
                spriteShining.visible = YES;
                spriteShining1.visible = NO;
                spriteShining.position = ccp(220.f, 283.f);
                spriteBigShining.visible = NO;
                imgGuideMask.visible = NO;
                imgContinue.visible = NO;
                [lblGuideMessage setString:@"再在旁边放置第三个细菌。"];
            }
            break;
            case 6:
            {
                
                nodeMessage.positionType = CCPositionTypePoints;
                nodeMessage.position = ccp(160.f, 50.f);
                imgAction.visible = NO;
                spriteShining.visible = NO;
                spriteShining1.visible = NO;
                spriteBigShining.visible = NO;
                imgGuideMask.visible = NO;
                imgContinue.visible = NO;
                [lblGuideMessage setString:@"当有三个细菌在横竖斜任意方向上排\n成一条线时中间的细菌就会进化一级。\n点击继续。"];
            }
            break;
            case 7:
            {
                if(![self evolution])
                {
                    [self saveGame];
                }
                
                nodeMessage.positionType = CCPositionTypePoints;
                nodeMessage.position = ccp(160.f, 50.f);
                imgAction.visible = NO;
                spriteShining.visible = YES;
                spriteShining1.visible = NO;
                spriteShining.position = ccp(161.f, 283.f);
                spriteBigShining.visible = NO;
                imgGuideMask.visible = NO;
                imgContinue.visible = NO;
                [lblGuideMessage setString:@"瞧，这样就合成出了一个二级细菌了。"];
            }
            break;
            case 8:
            {
                
                nodeMessage.positionType = CCPositionTypePoints;
                nodeMessage.position = ccp(160.f, 50.f);
                imgAction.visible = NO;
                spriteShining.visible = YES;
                spriteShining1.visible = NO;
                spriteShining.position = ccp(100.f, 283.f);
                spriteBigShining.visible = NO;
                imgGuideMask.visible = NO;
                imgContinue.visible = NO;
                [lblGuideMessage setString:@"让我们再来放置一些细菌。"];
            }
            break;
            case 9:
            {
                
                nodeMessage.positionType = CCPositionTypePoints;
                nodeMessage.position = ccp(160.f, 50.f);
                imgAction.visible = NO;
                spriteShining.visible = YES;
                spriteShining1.visible = NO;
                spriteShining.position = ccp(100.f, 219.f);
                spriteBigShining.visible = NO;
                imgGuideMask.visible = NO;
                imgContinue.visible = NO;
                [lblGuideMessage setString:@"让我们再来放置一些细菌。"];
            }
            break;
            case 10:
            {
                
                nodeMessage.positionType = CCPositionTypePoints;
                nodeMessage.position = ccp(160.f, 50.f);
                imgAction.visible = NO;
                spriteShining.visible = YES;
                spriteShining1.visible = NO;
                spriteShining.position = ccp(100.f, 161.f);
                spriteBigShining.visible = NO;
                imgGuideMask.visible = NO;
                imgContinue.visible = NO;
                [lblGuideMessage setString:@"让我们再来放置一些细菌。"];
            }
            break;
            case 11:
            {
                
                nodeMessage.positionType = CCPositionTypePoints;
                nodeMessage.position = ccp(160.f, 50.f);
                imgAction.visible = NO;
                spriteShining.visible = YES;
                spriteShining1.visible = NO;
                spriteShining.position = ccp(100.f, 161.f);
                spriteBigShining.visible = NO;
                imgGuideMask.visible = NO;
                imgContinue.visible = NO;
                [lblGuideMessage setString:@"让我们再来放置一些细菌。"];
            }
            break;
            case 12:
            {
                
                nodeMessage.positionType = CCPositionTypePoints;
                nodeMessage.position = ccp(160.f, 50.f);
                imgAction.visible = NO;
                spriteShining.visible = YES;
                spriteShining1.visible = NO;
                spriteShining.position = ccp(161.f, 161.f);
                spriteBigShining.visible = NO;
                imgGuideMask.visible = NO;
                imgContinue.visible = NO;
                [lblGuideMessage setString:@"让我们再来放置一些细菌。"];
            }
            break;
            case 13:
            {
                [self putNewEnemy:2 andY:3 level:1];
                
                nodeMessage.positionType = CCPositionTypePoints;
                nodeMessage.position = ccp(160.f, 50.f);
                imgAction.visible = NO;
                spriteShining.visible = NO;
                spriteShining1.visible = NO;
                spriteBigShining.visible = NO;
                imgGuideMask.visible = NO;
                imgContinue.visible = NO;
                [lblGuideMessage setString:@"不好，这里产生了一只一级生物虫\n它会吞噬周围八个格子里等级小于等于\n它的细菌。"];
            }
            break;
            case 14:
            {
                [self checkResult];
                
                nodeMessage.positionType = CCPositionTypePoints;
                nodeMessage.position = ccp(160.f, 50.f);
                imgAction.visible = NO;
                spriteShining.visible = NO;
                spriteShining1.visible = NO;
                spriteBigShining.visible = NO;
                imgGuideMask.visible = NO;
                imgContinue.visible = NO;
                [lblGuideMessage setString:@"瞧，你刚刚放置的两个一级细菌被\n生物虫吞噬了！下一步，我将教你如何\n消灭生物虫。"];
            }
            break;
            case 15:
            {
                
                nodeMessage.positionType = CCPositionTypePoints;
                nodeMessage.position = ccp(160.f, 400.f);
                imgAction.visible = NO;
                spriteShining.visible = YES;
                spriteShining1.visible = NO;
                spriteShining.position = ccp(100.f, 102.f);
                spriteBigShining.visible = NO;
                imgGuideMask.visible = NO;
                imgContinue.visible = NO;
                [lblGuideMessage setString:@"现在在这里放置一个细菌。"];
            }
            break;
            case 16:
            {
                
                nodeMessage.positionType = CCPositionTypePoints;
                nodeMessage.position = ccp(160.f, 400.f);
                imgAction.visible = NO;
                spriteShining.visible = YES;
                spriteShining1.visible = NO;
                spriteShining.position = ccp(161.f, 102.f);
                spriteBigShining.visible = NO;
                imgGuideMask.visible = NO;
                imgContinue.visible = NO;
                [lblGuideMessage setString:@"再在这里放置一个细菌。"];
            }
            break;
            case 17:
            {
                
                nodeMessage.positionType = CCPositionTypePoints;
                nodeMessage.position = ccp(160.f, 400.f);
                imgAction.visible = NO;
                spriteShining.visible = YES;
                spriteShining1.visible = NO;
                spriteShining.position = ccp(221.f, 102.f);
                spriteBigShining.visible = NO;
                imgGuideMask.visible = NO;
                imgContinue.visible = NO;
                [lblGuideMessage setString:@"再在这里放置一个细菌。"];
            }
            break;
            case 18:
            {
                
                nodeMessage.positionType = CCPositionTypePoints;
                nodeMessage.position = ccp(160.f, 400.f);
                imgAction.visible = YES;
                imgAction.position = ccp(189.f, 129.f);
                spriteShining.visible = NO;
                spriteShining1.visible = NO;
                spriteBigShining.visible = NO;
                imgGuideMask.visible = NO;
                imgContinue.visible = NO;
                [lblGuideMessage setString:@"现在你只需要简单的拖动把这个细菌\n移动到上面去。"];
            }
            break;
            case 19:
            {
                
                nodeMessage.positionType = CCPositionTypePoints;
                nodeMessage.position = ccp(160.f, 50.f);
                imgAction.visible = NO;
                spriteShining.visible = YES;
                spriteShining1.visible = NO;
                spriteShining.position = ccp(282.f, 282.f);
                spriteBigShining.visible = NO;
                imgGuideMask.visible = NO;
                imgContinue.visible = NO;
                [lblGuideMessage setString:@"继续继续，我们还要放置三个细菌。"];
            }
            break;
            case 20:
            {
                
                nodeMessage.positionType = CCPositionTypePoints;
                nodeMessage.position = ccp(160.f, 50.f);
                imgAction.visible = NO;
                spriteShining.visible = YES;
                spriteShining1.visible = NO;
                spriteShining.position = ccp(282.f, 221.f);
                spriteBigShining.visible = NO;
                imgGuideMask.visible = NO;
                imgContinue.visible = NO;
                [lblGuideMessage setString:@"继续继续，我们还要放置三个细菌。"];
            }
            break;
            case 21:
            {
                
                nodeMessage.positionType = CCPositionTypePoints;
                nodeMessage.position = ccp(160.f, 50.f);
                imgAction.visible = NO;
                spriteShining.visible = YES;
                spriteShining1.visible = NO;
                spriteShining.position = ccp(282.f, 160.f);
                spriteBigShining.visible = NO;
                imgGuideMask.visible = NO;
                imgContinue.visible = NO;
                [lblGuideMessage setString:@"继续继续，我们还要放置三个细菌。"];
            }
            break;
            case 22:
            {
                
                nodeMessage.positionType = CCPositionTypePoints;
                nodeMessage.position = ccp(160.f, 400.f);
                imgAction.visible = YES;
                imgAction.rotation = -90.f;
                imgAction.position = ccp(250.f, 248.f);
                spriteShining.visible = NO;
                spriteShining1.visible = NO;
                spriteBigShining.visible = NO;
                imgGuideMask.visible = NO;
                imgContinue.visible = NO;
                [lblGuideMessage setString:@"拖动这个细菌移动到左边去。"];
            }
            break;
            case 23:
            {
                
                nodeMessage.positionType = CCPositionTypePoints;
                nodeMessage.position = ccp(160.f, 400.f);
                imgAction.visible = NO;
                spriteShining.visible = NO;
                spriteShining1.visible = NO;
                spriteBigShining.visible = NO;
                imgGuideMask.visible = NO;
                imgContinue.visible = NO;
                [lblGuideMessage setString:@"当一个生物虫四周被高于自身等级\n的细菌包围的时候，生物虫就会被\n消灭。"];
            }
            break;
            case 24:
            {
                
                nodeMessage.positionType = CCPositionTypePoints;
                nodeMessage.position = ccp(160.f, 400.f);
                imgAction.visible = NO;
                spriteShining.visible = NO;
                spriteShining1.visible = NO;
                spriteBigShining.visible = NO;
                imgGuideMask.visible = NO;
                imgContinue.visible = NO;
                [lblGuideMessage setString:@"干得漂亮，你消灭了一个生物虫，\n游戏中随着时间的推移会产生更多\n的生物虫，你需要用刚才的办法消\n灭他们。"];
            }
            break;
            case 25:
            {
                [self putNewEnemy:3 andY:4 level:1];
                
                nodeMessage.positionType = CCPositionTypePoints;
                nodeMessage.position = ccp(160.f, 400.f);
                imgAction.visible = NO;
                spriteShining.visible = NO;
                spriteShining1.visible = NO;
                spriteBigShining.visible = NO;
                imgGuideMask.visible = NO;
                imgContinue.visible = NO;
                [lblGuideMessage setString:@"这里又出现了一个生物虫，生物虫\n随着时间推移而进化，你必须时刻\n关注生物虫周围的低级细菌，尽快\n合成进化它们。"];
            }
            break;
            case 26:
            {
                Becterial *enemy = [_enemyList objectAtIndex:0];
                enemy.level++;
                [self checkResult];

                
                nodeMessage.positionType = CCPositionTypePoints;
                nodeMessage.position = ccp(160.f, 400.f);
                imgAction.visible = NO;
                spriteShining.visible = NO;
                spriteShining1.visible = NO;
                spriteBigShining.visible = NO;
                imgGuideMask.visible = NO;
                imgContinue.visible = NO;
                [lblGuideMessage setString:@"看见了吧，生物虫进化为二级，这\n将吞噬他周围所有等级小于等于二\n级的细菌。下面我教你怎么使用道\n具。"];
            }
            break;
            case 27:
            {
                Becterial *b;
                for(int i = 0; i < [_becterialList count]; i++)
                {
                    b = [_becterialList objectAtIndex:i];
                    if(b.type == 0)
                    {
                        [_container removeChild:b];
                        NSMutableArray *_tmp = [_becterialContainer objectAtIndex:b.positionX];
                        [_tmp replaceObjectAtIndex:b.positionY withObject:[NSNull null]];
                        [_becterialList removeObjectAtIndex:i];
                    }
                }
                [self generateBacterial:0 x:2 y:4 level:3];
                [self generateBacterial:0 x:3 y:3 level:3];
                [self generateBacterial:0 x:4 y:4 level:3];

                Becterial *enemy = [_enemyList objectAtIndex:0];
                CCProgressNode *cdNode = [enemy getProgressNode];
                cdNode.percentage = 90.f;

                
                nodeMessage.positionType = CCPositionTypePoints;
                nodeMessage.position = ccp(160.f, 50.f);
                imgAction.visible = NO;
                spriteShining.visible = NO;
                spriteShining1.visible = NO;
                spriteBigShining.visible = NO;
                imgGuideMask.visible = NO;
                imgContinue.visible = NO;
                [lblGuideMessage setString:@"为了方便讲解，我提前给你放置了\n三个三级细菌在生物虫周围。现在\n生物虫马上就要进化了，我们需要\n做点什么来阻止这三个细菌被吞噬。"];
            }
            break;
            case 28:
            {
                
                nodeMessage.positionType = CCPositionTypePoints;
                nodeMessage.position = ccp(160.f, 50.f);
                imgAction.visible = NO;
                spriteShining.visible = YES;
                spriteShining1.visible = NO;
                spriteShining.position = ccp(212.f, 413.f);
                spriteBigShining.visible = NO;
                imgGuideMask.visible = NO;
                imgContinue.visible = NO;
                [lblGuideMessage setString:@"看见这个了吗？这叫做抑制器，现\n在拖动它到生物虫上方，然后松开\n这会让生物虫进化到下一级的时间\n延长一分钟。"];
            }
            break;
            case 29:
            {
                
                nodeMessage.positionType = CCPositionTypePoints;
                nodeMessage.position = ccp(160.f, 50.f);
                imgAction.visible = NO;
                spriteShining.visible = YES;
                spriteShining1.visible = YES;
                spriteShining.position = ccp(144.f, 413.f);
                spriteShining1.position = ccp(159.f, 284.f);
                spriteBigShining.visible = NO;
                imgGuideMask.visible = NO;
                imgContinue.visible = NO;
                [lblGuideMessage setString:@"看见这个了吗？这叫做升级器，现\n在拖动它到一个细菌上方，然后松\n开，你将会让细菌直接升一级。"];
            }
            break;
            case 30:
            {
                
                nodeMessage.positionType = CCPositionTypePoints;
                nodeMessage.position = ccp(160.f, 50.f);
                imgAction.visible = NO;
                spriteShining.visible = YES;
                spriteShining1.visible = YES;
                spriteShining.position = ccp(144.f, 413.f);
                spriteShining1.position = ccp(218.f, 224.f);
                spriteBigShining.visible = NO;
                imgGuideMask.visible = NO;
                imgContinue.visible = NO;
                [lblGuideMessage setString:@"看见这个了吗？这叫做升级器，现\n在拖动它到一个细菌上方，然后松\n开，你将会让细菌直接升一级。"];
            }
            break;
            case 31:
            {
                
                nodeMessage.positionType = CCPositionTypePoints;
                nodeMessage.position = ccp(160.f, 50.f);
                imgAction.visible = NO;
                spriteShining.visible = YES;
                spriteShining1.visible = YES;
                spriteShining.position = ccp(144.f, 413.f);
                spriteShining1.position = ccp(278.f, 285.f);
                spriteBigShining.visible = NO;
                imgGuideMask.visible = NO;
                imgContinue.visible = NO;
                [lblGuideMessage setString:@"看见这个了吗？这叫做升级器，现\n在拖动它到一个细菌上方，然后松\n开，你将会让细菌直接升一级。"];
            }
            break;
            case 32:
            {
                
                nodeMessage.positionType = CCPositionTypePoints;
                nodeMessage.position = ccp(160.f, 50.f);
                imgAction.visible = NO;
                spriteShining.visible = NO;
                spriteShining1.visible = NO;
                spriteBigShining.visible = NO;
                imgGuideMask.visible = NO;
                imgContinue.visible = NO;
                [lblGuideMessage setString:@"Ok！这样就算这只生物虫再进化，\n也不怕细菌被吞噬了。"];
            }
            break;
            case 33:
            {
                Becterial *enemy = [_enemyList objectAtIndex:0];
                enemy.level++;
                
                nodeMessage.positionType = CCPositionTypePoints;
                nodeMessage.position = ccp(160.f, 50.f);
                imgAction.visible = NO;
                spriteShining.visible = NO;
                spriteShining1.visible = NO;
                spriteBigShining.visible = NO;
                imgGuideMask.visible = NO;
                imgContinue.visible = NO;
                [lblGuideMessage setString:@"看吧，目前来说这三个细菌还不会\n被吞噬吧，当然你要么想办法消灭\n这个生物虫，要么继续进化细菌。"];
            }
            break;
            case 34:
            {
                nodeMessage.positionType = CCPositionTypePoints;
                nodeMessage.position = ccp(160.f, 50.f);
                imgAction.visible = NO;
                spriteShining.visible = NO;
                spriteShining1.visible = NO;
                spriteBigShining.visible = NO;
                imgGuideMask.visible = NO;
                imgContinue.visible = NO;
                [lblGuideMessage setString:@"好了，这就是我要教给你的，下面\n就靠你自己的了！"];
            }
            break;
        }
    }
}

-(CCNode *)container
{
    return _container;
}

-(void)useKiller:(int)x andY:(int)y
{
    if([[_becterialContainer objectAtIndex:x] objectAtIndex:y] == [NSNull null])
    {
        return;
    }
    
    Becterial *b = [[_becterialContainer objectAtIndex:x] objectAtIndex:y];
    if(b.type == 1)
    {
        b.nextEvolutionCurrent = b.nextEvolutionCurrent  + 60.f;
        b.nextEvolution = b.nextEvolution  + 60.f;
        self.killerCount--;
        [self checkResult];
        [self saveGame];
        self.guideStep++;
    }
}

-(void)useUper:(int)x andY:(int)y
{
    if([[_becterialContainer objectAtIndex:x] objectAtIndex:y] == [NSNull null])
    {
        return;
    }
    
    Becterial *b = [[_becterialContainer objectAtIndex:x] objectAtIndex:y];
    if(b.type == 0)
    {
        b.level++;
        self.uperCount--;
        if(![self evolution])
        {
            [self checkResult];
            [self saveGame];
        }
        
        self.maxLevel = b.level;
        self.guideStep++;
    }
}

-(void)checkResult
{
    Becterial *enemy;
    Becterial *bacterial;
    NSMutableArray *tmp;
    NSMutableArray *list;

    //重置
    for (int i = 0; i < [_enemyContainer count]; i++)
    {
        NSMutableArray *_tmp = [_enemyContainer objectAtIndex:i];
        for (int j = 0; j < [_tmp count]; j++)
        {
            [_tmp replaceObjectAtIndex:j withObject:[NSNumber numberWithBool:YES]];
        }
    }
    for (int i = 0; i < [_enemyList count]; ++i)
    {
        enemy = (Becterial *)[_enemyList objectAtIndex:i];
        enemy.checked = NO;
    }
    
    list = [[NSMutableArray alloc] init];
    for (int i = 0; i < [_enemyList count]; ++i)
    {
        enemy = (Becterial *)[_enemyList objectAtIndex:i];

        //判断吞噬;
        int startX = fmin(fmax(enemy.positionX - 1, 0), 4);
        int endX = fmin(fmax(enemy.positionX + 1, 0), 4);
        int startY = fmin(fmax(enemy.positionY - 1, 0), 5);
        int endY = fmin(fmax(enemy.positionY + 1, 0), 5);

        for(int m = startX; m <= endX; m++)
        {
            tmp = [_becterialContainer objectAtIndex:m];
            for(int n = startY; n <= endY; n++)
            {
                if((m != enemy.positionX || n != enemy.positionY) &&
                   [tmp objectAtIndex:n] != [NSNull null])
                {
                    bacterial = (Becterial *)[tmp objectAtIndex:n];

                    //吞噬
                    if(enemy.level >= bacterial.level && bacterial.type == 0)
                    {
                        NSLog(@"吞噬");
                        [list addObject:bacterial];

                        // [tmp replaceObjectAtIndex:bacterial.positionY withObject:[NSNull null]];
                        // [_becterialList removeObjectIdenticalTo:bacterial];
                        // [_container removeChild:bacterial cleanup:YES];
                    }
                }
                [[_enemyContainer objectAtIndex:m] replaceObjectAtIndex:n withObject:[NSNumber numberWithBool:NO]];
            }
        }
        [self doEatEffect:list byEnemy:enemy];
        [list removeAllObjects];
    }
    
    for (int i = 0; i < [_enemyList count]; ++i)
    {
        enemy = (Becterial *)[_enemyList objectAtIndex:i];
        
        //判断是否被包围
        if(!enemy.checked)
        {
            list = [self isSurrounded:enemy];
            if([list count] == 0)
            {
                continue;
            }
            [self doTerminatedEffect:list];
            [list removeAllObjects];
        }
    }

    int availableBlock = 0;
    BOOL available;
    for (int i = 0; i < [_becterialContainer count]; ++i)
    {
        tmp = [_becterialContainer objectAtIndex:i];
        for(int j = 0; j < [tmp count]; ++j)
        {
            available = [[[_enemyContainer objectAtIndex:i] objectAtIndex:j] boolValue];
            if([tmp objectAtIndex:j] != [NSNull null])
            {
                bacterial = (Becterial *)[tmp objectAtIndex:j];
            }
            else if (available)
            {
                availableBlock++;
            }
        }
    }

    if(availableBlock == 0)
    {
        _isRunning = NO;
        ScoreNode *s = (ScoreNode *)[CCBReader load:@"Score"];
        s.score = _score;
        
        [self addChild:s];
        [[GameCenterManager sharedGameCenterManager] reportScore:_score];
    }
}

-(NSMutableArray *)isSurrounded:(Becterial *)enemy
{
    NSMutableArray *list = [[NSMutableArray alloc] init];
    NSMutableArray *listLeft, *listRight, *listTop, *listBottom;
    NSMutableArray *tmp;
    Becterial *bacterial;
    enemy.checked = YES;

    //判断是否被包围
    BOOL top = enemy.positionY == 5;
    BOOL left = enemy.positionX == 0;
    BOOL bottom = enemy.positionY == 0;
    BOOL right = enemy.positionX == 4;
    BOOL topIsEnemy = NO;
    BOOL bottomIsEnemy = NO;
    BOOL leftIsEnemy = NO;
    BOOL rightIsEnemy = NO;
    //上
    if(!top)
    {
        tmp = [_becterialContainer objectAtIndex:enemy.positionX];
        if([tmp objectAtIndex:enemy.positionY + 1] != [NSNull null])
        {
            bacterial = (Becterial *)[tmp objectAtIndex:enemy.positionY + 1];
            if(bacterial.type == 0)
            {
                if(bacterial.level > enemy.level)
                {
                    top = YES;
                }
            }
            else 
            {
                topIsEnemy = YES;
                if(!bacterial.checked)
                {
                    listTop = [self isSurrounded:bacterial];
                    if ([listTop count] > 0)
                    {
                        top = YES;
                    }
                }
                else
                {
                    top = YES;
                }
            }
        }
    }
    //下
    if(!bottom)
    {
        tmp = [_becterialContainer objectAtIndex:enemy.positionX];
        if([tmp objectAtIndex:enemy.positionY - 1] != [NSNull null])
        {
            bacterial = (Becterial *)[tmp objectAtIndex:enemy.positionY - 1];
            if(bacterial.type == 0)
            {
                if(bacterial.level > enemy.level)
                {
                    bottom = YES;
                }
            }
            else 
            {
                bottomIsEnemy = YES;
                if(!bacterial.checked)
                {
                    listBottom = [self isSurrounded:bacterial];
                    if ([listBottom count] > 0)
                    {
                        bottom = YES;
                    }
                }
                else
                {
                    bottom = YES;
                }
            }
        }
    }
    //左
    if(!left)
    {
        tmp = [_becterialContainer objectAtIndex:enemy.positionX - 1];
        if([tmp objectAtIndex:enemy.positionY] != [NSNull null])
        {
            bacterial = (Becterial *)[tmp objectAtIndex:enemy.positionY];
            if(bacterial.type == 0)
            {
                if(bacterial.level > enemy.level)
                {
                    left = YES;
                }
            }
            else 
            {
                leftIsEnemy = YES;
                if(!bacterial.checked)
                {
                    listLeft = [self isSurrounded:bacterial];
                    if ([listLeft count] > 0)
                    {
                        left = YES;
                    }
                }
                else
                {
                    left = YES;
                }
            }
        }
    }
    //右
    if(!right)
    {
        tmp = [_becterialContainer objectAtIndex:enemy.positionX + 1];
        if([tmp objectAtIndex:enemy.positionY] != [NSNull null])
        {
            bacterial = (Becterial *)[tmp objectAtIndex:enemy.positionY];
            if(bacterial.type == 0)
            {
                if(bacterial.level > enemy.level)
                {
                    right = YES;
                }
            }
            else 
            {
                rightIsEnemy = YES;
                if(!bacterial.checked)
                {
                    listRight = [self isSurrounded:bacterial];
                    if ([listRight count] > 0)
                    {
                        right = YES;
                    }
                }
                else
                {
                    right = YES;
                }
            }
        }
        else
        {
            [list removeAllObjects];
            return list;
        }
    }
    
    if(topIsEnemy && listTop)
    {
        if([listTop count] > 0)
        {
            for (Becterial *b in listTop)
            {
                [list addObject:b];
            }
            [listTop removeAllObjects];
            listTop = nil;
        }
        else
        {
            [list removeAllObjects];
            return list;
        }
    }
    
    if(bottomIsEnemy && listBottom)
    {
        if([listBottom count] > 0)
        {
            for (Becterial *b in listBottom)
            {
                [list addObject:b];
            }
            [listBottom removeAllObjects];
            listBottom = nil;
        }
        else
        {
            [list removeAllObjects];
            return list;
        }
    }
    
    if(leftIsEnemy && listLeft)
    {
        if([listLeft count] > 0)
        {
            for (Becterial *b in listLeft)
            {
                [list addObject:b];
            }
            [listLeft removeAllObjects];
            listLeft = nil;
        }
        else
        {
            [list removeAllObjects];
            return list;
        }
    }
    
    if(rightIsEnemy && listRight)
    {
        if([listRight count] > 0)
        {
            for (Becterial *b in listRight)
            {
                [list addObject:b];
            }
            [listRight removeAllObjects];
            listRight = nil;
        }
        else
        {
            [list removeAllObjects];
            return list;
        }
    }
    
    if(top && bottom && left && right)
    {
        [list addObject:enemy];
    }
    else
    {
        [list removeAllObjects];
    }

    return list;
}

-(void)doEatEffect:(NSMutableArray *)list byEnemy:(Becterial *)enemy
{
    Becterial *other;
    for(int m = 0; m < [list count]; m++)
    {
        other = [list objectAtIndex:m];
        [[_becterialContainer objectAtIndex:other.positionX] replaceObjectAtIndex:other.positionY withObject:[NSNull null]];
        [_becterialList removeObjectIdenticalTo:other];
        
        CGPoint p = [_container convertToNodeSpace:enemy.position];
        CCActionMoveTo *aMoveTo = [CCActionMoveTo actionWithDuration:.2f position:ccp(p.x, p.y)];
        CCActionRemove *aRemove = [CCActionRemove action];
        [other runAction:[CCActionSequence actionWithArray:@[aMoveTo, aRemove]]];
        [self saveGame];
    }
}

-(void)doTerminatedEffect:(NSMutableArray *)list
{
    Becterial *enemy;
    for(int m = 0; m < [list count]; m++)
    {
        enemy = [list objectAtIndex:m];

        [[_becterialContainer objectAtIndex:enemy.positionX] replaceObjectAtIndex:enemy.positionY withObject:[NSNull null]];
        [_becterialList removeObjectIdenticalTo:enemy];
        [_enemyList removeObjectIdenticalTo:enemy];
        
        //得金币
        self.exp = _exp + ENEMY_BASIC_EXP * pow(2, enemy.level - 1);
        
        CCActionScaleTo *aScaleTo = [CCActionScaleTo actionWithDuration:.3f scale:0.f];
        CCActionRemove *aRemove = [CCActionRemove action];
        [enemy runAction:[CCActionSequence actionWithArray:@[aScaleTo, aRemove]]];
        [self saveGame];
    }
}

-(void)saveGame
{
    NSString *path = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    NSString *file = [path stringByAppendingPathComponent:@"savegame"];
    NSData *becterials = [NSKeyedArchiver archivedDataWithRootObject:_becterialList];
    NSDictionary *data = [NSDictionary dictionaryWithObjectsAndKeys:
        [NSNumber numberWithFloat:_score], @"score",
        [NSNumber numberWithFloat:_maxLevel], @"maxLevel",
        [NSNumber numberWithInt:bacterialCount], @"bacterialCount",
        [NSNumber numberWithInt:enemyCount], @"enemyCount",
        [NSNumber numberWithFloat:enemyGenerateTime], @"enemyGenerateTime",
        [NSNumber numberWithFloat:runningTime], @"runningTime",
        becterials, @"bacterials", nil
    ];
    [data writeToFile:file atomically:NO];
    
    [[DataStorageManager sharedDataStorageManager] saveData];
}

-(BOOL)loadGame
{
    NSString *path = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    NSString *file = [path stringByAppendingPathComponent:@"savegame"];
    NSDictionary *data = [[NSDictionary alloc] initWithContentsOfFile:file];
    
    if(data == nil)
    {
        return NO;
    }
    
    self.exp = dataExp;
    self.stepCount = dataStepCount;
    self.killerCount = dataKillerCount;
    self.uperCount = dataUperCount;
    self.score = [[data objectForKey:@"score"] floatValue];
    _maxLevel = [[data objectForKey:@"maxLevel"] floatValue];
    bacterialCount = [[data objectForKey:@"bacterialCount"] intValue];
    enemyCount = [[data objectForKey:@"enemyCount"] intValue];
    _becterialList = [NSKeyedUnarchiver unarchiveObjectWithData:[data objectForKey:@"bacterials"]];
    enemyGenerateTime = [[data objectForKey:@"enemyGenerateTime"] floatValue];
    runningTime = [[data objectForKey:@"runningTime"] floatValue];
    if(_becterialList == nil)
    {
        _becterialList = [[NSMutableArray alloc] init];
    }
    if(_enemyList == nil)
    {
        _enemyList = [[NSMutableArray alloc] init];
    }
    for (Becterial *b in _becterialList)
    {
        if(b.type == 1)
        {
            [_enemyList addObject:b];
        }
    }

    return YES;
}

-(void)reset
{
    _isRunning = YES;
    runningTime = 0;
    enemyGenerateTime = 0;
    self.maxLevel = 0;
    self.score = 0;
    [_becterialList removeAllObjects];
    [_enemyList removeAllObjects];
    [_container removeAllChildren];
    [self saveGame];
    [self prepareStage];
}

-(ScoreScene *)showScoreScene
{
    ScoreScene *scoreScene;
    if(isR4)
    {
        scoreScene = (ScoreScene *)[CCBReader load:@"ScoreScene-r4"];
    }
    else
    {
        scoreScene = (ScoreScene *)[CCBReader load:@"ScoreScene"];
    }
    UIImage *screenshot = [[UMSocialScreenShoterCocos2d screenShoter] getScreenShot];
    [scoreScene setScreenshot:screenshot];
    [scoreScene setScore:_score];
    CCScene *scene = [CCScene new];
    [scene addChild:scoreScene];
    [[CCDirector sharedDirector] replaceScene:scene];

    return scoreScene;
}

@end
