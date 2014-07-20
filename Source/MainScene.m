//
//  MainScene.m
//  PROJECTNAME
//
//  Created by Viktor on 10/10/13.
//  Copyright (c) 2013 Apportable. All rights reserved.
//

#import "MainScene.h"
#import "ScoreScene.h"
#import "Becterial.h"
#import "Guide.h"
#import "define.h"
#import "PZLabelScore.h"
#import "PZWebManager.h"
#import "CashStoreManager.h"
#import "DataStorageManager.h"
#import "GameCenterManager.h"

#define defaultStepCount 500
#define defualtAccelerateTime 600.f;
#define defaultAccelerateCostPerSecond 10.f;
#define accelerateIncreaseBiomassRate 1.f;
#define dataExp [DataStorageManager sharedDataStorageManager].exp
#define dataKillerCount [DataStorageManager sharedDataStorageManager].killerCount
#define dataStorageManagerAchievement [DataStorageManager sharedDataStorageManager].achievementConst
#define dataStorageManagerGuide [DataStorageManager sharedDataStorageManager].guide
#define dataStorageManagerGuideStep [DataStorageManager sharedDataStorageManager].guideStep

@implementation MainScene
{
    BOOL isR4;
    CCLabelTTF *_lblKillerCount;
    PZLabelScore *_lblExp;
    PZLabelScore *_lblStepCount;
    PZLabelScore *_lblScore;
    PZLabelScore *_lblBiomass;
    CCNode *_container;
    CCButton *btnBiomass;
    Guide *gLayer;
    NSMutableArray *_becterialContainer;
    NSMutableArray *_becterialList;
    int runningAction;
    CGFloat runningTime;
    
    int _lastX;
    int _lastY;
    Becterial *_lastBacterial;

    BOOL inAccelerated;
    CGFloat accelerationTime;
    int bacterialCount;
    int enemyCount;
    CGFloat bacterialBiomass;   //细菌需要消耗的生物质
    CGFloat enemyBiomass;       //入侵病毒产生的生物质
    CGFloat scoreOffset;        //分數增加量
    
    CCSprite *imgAccelerationBg;
    
    NSArray *guideEnemyPosition;
    NSArray *guideBacterialPosition;
    int guideEnemyPositionIndex;
    int guideBacterialPositionIndex;
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
    _lblExp = [PZLabelScore initWithScore:0 fileName:@"" itemWidth:14 itemHeight:22];
    if(isR4)
    {
        _lblExp.position = ccp(67.f, 543.5f);
    }
    else
    {
        _lblExp.position = ccp(67.f, 455.5f);
    }
    [self addChild:_lblExp];
    
    _lblStepCount = [PZLabelScore initWithScore:0 fileName:@"" itemWidth:14 itemHeight:22];
    if(isR4)
    {
        _lblStepCount.position = ccp(250.f, 543.5f);
    }
    else
    {
        _lblStepCount.position = ccp(250.f, 455.5f);
    }
    [self addChild:_lblStepCount];

    _lblScore = [PZLabelScore initWithScore:0 fileName:@"" itemWidth:14 itemHeight:22];
    if(isR4)
    {
        _lblScore.position = ccp(10.f, 403.f);
    }
    else
    {
        _lblScore.position = ccp(10.f, 390.f);
    }
    [self addChild:_lblScore];

    _lblBiomass = [PZLabelScore initWithScore:0 fileName:@"" itemWidth:14 itemHeight:22];
    if(isR4)
    {
        _lblBiomass.position = ccp(165.f, 403.f);
    }
    else
    {
        _lblBiomass.position = ccp(165.f, 390.f);
    }
    [self addChild:_lblBiomass];
    
    _maxLevel = 0;
    imgAccelerationBg.visible = NO;
    self.userInteractionEnabled = YES;
}

-(void)update10PerSecond:(CCTime)delta
{
    CGFloat biomassOffset = enemyBiomass - bacterialBiomass;
    self.biomass = fmax(_biomass + biomassOffset, 0);

    if(_biomass > 0)
    {
        self.score = _score + scoreOffset * delta;
    }
    if(inAccelerated)
    {
        if(accelerationTime > 0)
        {
            accelerationTime = accelerationTime - 10.f * delta;
        }
        else
        {
            imgAccelerationBg.visible = NO;
            inAccelerated = NO;
            [self checkResult];
        }
    }
    
    runningTime = runningTime + delta;
}

-(void)prepareStage
{
    int capacity = 5;
    _becterialContainer = [NSMutableArray arrayWithCapacity:capacity];
    for (int i = 0; i < capacity; i++)
    {
        NSMutableArray *_tmp = [NSMutableArray arrayWithCapacity:capacity];
        for (int j = 0; j < capacity; j++)
        {
            [_tmp addObject:[NSNull null]];
        }
        [_becterialContainer addObject:_tmp];
    }
    
    if (dataStorageManagerGuide)
    {
        int guideStep = dataStorageManagerGuideStep;
        guideStep = fmax(1, guideStep);
        
        if(isR4)
        {
            gLayer = (Guide *)[CCBReader load:@"Guide-r4"];
        }
        else
        {
            gLayer = (Guide *)[CCBReader load:@"Guide"];
        }
        gLayer.step = guideStep;
        [self addChild:gLayer];
        
        [[NSNotificationCenter defaultCenter] removeObserver:self name:@"guideClickBiomass" object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didReceiveGuideNotification:) name:@"guideClickBiomass" object:nil];
        [[NSNotificationCenter defaultCenter] removeObserver:self name:@"guideClickScore" object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didReceiveGuideNotification:) name:@"guideClickScore" object:nil];
        [[NSNotificationCenter defaultCenter] removeObserver:self name:@"guideClickEnemy" object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didReceiveGuideNotification:) name:@"guideClickEnemy" object:nil];
        [[NSNotificationCenter defaultCenter] removeObserver:self name:@"guideClickBacterial" object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didReceiveGuideNotification:) name:@"guideClickBacterial" object:nil];
        [[NSNotificationCenter defaultCenter] removeObserver:self name:@"guideClickBiomass2" object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didReceiveGuideNotification:) name:@"guideClickBiomass2" object:nil];
        [[NSNotificationCenter defaultCenter] removeObserver:self name:@"guideClickScore2" object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didReceiveGuideNotification:) name:@"guideClickScore2" object:nil];
        [[NSNotificationCenter defaultCenter] removeObserver:self name:@"guideClickEnemy2" object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didReceiveGuideNotification:) name:@"guideClickEnemy2" object:nil];
        [[NSNotificationCenter defaultCenter] removeObserver:self name:@"guideClickBacterial2" object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didReceiveGuideNotification:) name:@"guideClickBacterial2" object:nil];
        [[NSNotificationCenter defaultCenter] removeObserver:self name:@"guideTouchBacterial" object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didReceiveGuideNotification:) name:@"guideTouchBacterial" object:nil];
        [[NSNotificationCenter defaultCenter] removeObserver:self name:@"guideTouchBacterialEnd" object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didReceiveGuideNotification:) name:@"guideTouchBacterialEnd" object:nil];
        [[NSNotificationCenter defaultCenter] removeObserver:self name:@"guideFinish" object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didReceiveGuideNotification:) name:@"guideFinish" object:nil];
        
        guideEnemyPosition = [NSArray arrayWithObjects:
                              [NSValue valueWithCGPoint:ccp(0.f, 0.f)],
                              [NSValue valueWithCGPoint:ccp(1.f, 0.f)],
                              [NSValue valueWithCGPoint:ccp(3.f, 0.f)], nil];
        guideEnemyPositionIndex = 0;
        
        guideBacterialPosition = [NSArray arrayWithObjects:
                              [NSValue valueWithCGPoint:ccp(4.f, 4.f)],
                              [NSValue valueWithCGPoint:ccp(3.f, 4.f)],
                              [NSValue valueWithCGPoint:ccp(1.f, 4.f)], nil];
        guideBacterialPositionIndex = 0;
    }
    
    if([self loadGame])
    {
        for (int i = 0; i < [_becterialList count]; i++)
        {
            Becterial *b = [_becterialList objectAtIndex:i];
            b.anchorPoint = ccp(0.f, 0.f);
            NSMutableArray *tmp = [_becterialContainer objectAtIndex:b.positionX];
            [tmp replaceObjectAtIndex:b.positionY withObject:b];
            b.position = ccp(b.positionX * 60.5f, b.positionY * 60.5f);
            [_container addChild:b];
        }
        if(inAccelerated)
        {
            imgAccelerationBg.visible = YES;
        }
        [self checkResult];
    }
    else
    {
        inAccelerated = NO;
        accelerationTime = defualtAccelerateTime;
        _becterialList = [[NSMutableArray alloc] init];
        self.stepCount = defaultStepCount;
        self.exp = 0;
        self.killerCount = 10;
        _maxLevel = 0;
    }
}

-(void)didReceiveGuideNotification:(NSNotification *) notification
{
    if([notification.name isEqualToString:@"guideClickBiomass"])
    {
        [self btnGenerateBiomass];
        if (_biomass >= 50 && gLayer)
        {
            gLayer.step++;
        }
    }
    else if([notification.name isEqualToString:@"guideClickScore"])
    {
        [self btnGenerateScore];
        if (_score >= 30 && gLayer)
        {
            gLayer.step++;
        }
    }
    else if([notification.name isEqualToString:@"guideClickEnemy"])
    {
        CGPoint p = [[guideEnemyPosition objectAtIndex:guideEnemyPositionIndex] CGPointValue];
        [self putNewEnemy:p.x andY:p.y];
        if(enemyCount >= 1 && gLayer)
        {
            gLayer.step++;
        }
    }
    else if([notification.name isEqualToString:@"guideClickBacterial"])
    {
        CGPoint p = [[guideBacterialPosition objectAtIndex:guideBacterialPositionIndex] CGPointValue];
        [self putNewBacterial:p.x andY:p.y];
        if(bacterialCount >= 1 && gLayer)
        {
            gLayer.step++;
        }
    }
    else if([notification.name isEqualToString:@"guideClickBiomass2"])
    {
        [self btnGenerateBiomass];
    }
    else if([notification.name isEqualToString:@"guideClickScore2"])
    {
        [self btnGenerateScore];
    }
    else if([notification.name isEqualToString:@"guideClickEnemy2"])
    {
        CGPoint p = [[guideEnemyPosition objectAtIndex:guideEnemyPositionIndex] CGPointValue];
        [self putNewEnemy:p.x andY:p.y];
        if(enemyCount >= 3 && gLayer)
        {
            gLayer.step++;
        }
    }
    else if([notification.name isEqualToString:@"guideClickBacterial2"])
    {
        CGPoint p = [[guideBacterialPosition objectAtIndex:guideBacterialPositionIndex] CGPointValue];
        [self putNewBacterial:p.x andY:p.y];
        if(bacterialCount >= 3 && gLayer)
        {
            gLayer.step++;
        }
    }
    else if([notification.name isEqualToString:@"guideTouchBacterial"])
    {
        UITouch *touch = (UITouch *)notification.object;
        CGPoint position = touch.locationInWorld;
        position = [[self container] convertToNodeSpace:position];
        
        int x = position.x / 60.5f;
        int y = position.y / 60.5f;
        
        if (x > 4 || y > 4 || x < 0 || y < 0)
        {
            return;
        }
        
        _lastX = position.x;
        _lastY = position.y;
        
        NSMutableArray *tmp = [_becterialContainer objectAtIndex:x];
        if([tmp objectAtIndex:y] != [NSNull null])
        {
            _lastBacterial = [tmp objectAtIndex:y];
        }
    }
    else if([notification.name isEqualToString:@"guideTouchBacterialEnd"])
    {
        UITouch *touch = (UITouch *)notification.object;
        CGPoint position = touch.locationInWorld;
        if(_lastBacterial && abs(position.x - _lastX) > 1 && _lastBacterial.type == 0 && _biomass > 0)
        {
            if(abs(position.x - _lastX) > abs(position.y - _lastY))
            {
                if(position.x < _lastX)
                {
                    if(_lastBacterial.positionX > 0)
                    {
                        [self moveBecterial:_lastBacterial x:_lastBacterial.positionX - 1 y:_lastBacterial.positionY];
                    }
                }
                else
                {
                    if(_lastBacterial.positionX < 4)
                    {
                        [self moveBecterial:_lastBacterial x:_lastBacterial.positionX + 1 y:_lastBacterial.positionY];
                    }
                }
            }
            else
            {
                if(position.y < _lastY)
                {
                    if(_lastBacterial.positionY > 0)
                    {
                        [self moveBecterial:_lastBacterial x:_lastBacterial.positionX y:_lastBacterial.positionY - 1];
                    }
                }
                else
                {
                    if(_lastBacterial.positionY < 4)
                    {
                        [self moveBecterial:_lastBacterial x:_lastBacterial.positionX y:_lastBacterial.positionY + 1];
                    }
                }
            }
        }
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
        [self removeChild:gLayer cleanup:YES];
        gLayer = nil;
        [self reset];
    }
}

-(void)onEnter
{
    [super onEnter];

    [self prepareStage];
    [self schedule:@selector(update10PerSecond:) interval:.1f];
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

-(BOOL)generateBacterial:(int)type
{
    if(type == 0 || type == 1)
    {
        NSMutableArray *list = [[NSMutableArray alloc] init];
        for (int i = 0; i < [_becterialContainer count]; i++)
        {
            NSMutableArray *tmp = [_becterialContainer objectAtIndex:i];
            for (int j = 0; j < [tmp count]; j++)
            {
                if([tmp objectAtIndex:j] == [NSNull null])
                {
                    CGPoint p = ccp(i, j);
                    [list addObject:[NSValue valueWithCGPoint:p]];
                }
            }
        }
        
    
        long count = [list count];
        if(count > 0)
        {
            CGPoint position = [[list objectAtIndex:(arc4random() % count)] CGPointValue];
            return [self generateBacterial:type x:position.x y:position.y];
        }
    }
    return NO;
}

-(BOOL)generateBacterial:(int)type x:(int)x y:(int)y
{
    if(type == 0 || type == 1)
    {
        NSMutableArray *tmp = [_becterialContainer objectAtIndex:x];
        if([tmp objectAtIndex:y] == [NSNull null])
        {
            Becterial *b = [[Becterial alloc] init];
            b.positionX = x;
            b.positionY = y;
            b.anchorPoint = ccp(0.f, 0.f);
            b.type = type;
            b.level = 1;
            b.position = ccp(x * 60.5f, y * 60.5f);
            [_container addChild:b];
            self.maxLevel = 1;
            
            NSMutableArray *_tmp = [_becterialContainer objectAtIndex:x];
            [_tmp replaceObjectAtIndex:y withObject:b];
            [_becterialList addObject:b];
            
            return YES;
        }
    }
    return NO;
}

-(void)moveBecterial:(Becterial *)becterial x:(int)x y:(int)y
{
    NSMutableArray *tmp = [_becterialContainer objectAtIndex:x];
    if([tmp objectAtIndex:y] == [NSNull null] && self.stepCount > 0)
    {
        [tmp replaceObjectAtIndex:y withObject:becterial];
        tmp = [_becterialContainer objectAtIndex:becterial.positionX];
        [tmp replaceObjectAtIndex:becterial.positionY withObject:[NSNull null]];
        becterial.positionX = x;
        becterial.positionY = y;
//        [self generateBacterial:1];
        
        CCActionMoveTo *aMoveTo = [CCActionMoveTo actionWithDuration:.2f position:ccp(x * 60.5f, y * 60.5f)];
        CCActionCallBlock *aCallBlock = [CCActionCallBlock actionWithBlock:^(void)
        {
            runningAction--;
            if(runningAction == 0)
            {
                if(![self evolution])
                {
                    [self saveGame];
                    [self checkResult];
                }
            }
        }];
        self.stepCount--;
        [becterial runAction:[CCActionSequence actionWithArray:@[aMoveTo, aCallBlock]]];
        runningAction++;
    }
}

-(BOOL)isEvolution:(Becterial *)becterial
{
    if (becterial.level > 0)
    {
        int startX = fmin(fmax(becterial.positionX - 1, 0), 4);
        int endX = fmin(fmax(becterial.positionX + 1, 0), 4);
        int startY = fmin(fmax(becterial.positionY - 1, 0), 4);
        int endY = fmin(fmax(becterial.positionY + 1, 0), 4);
        Becterial *other;
        NSMutableArray *list = [[NSMutableArray alloc] init];
        int count = 0;
        BOOL isEnemy = NO;
        
        for(int i = startX; i <= endX; i++)
        {
            for(int j = startY; j <= endY; j++)
            {
                if((i != becterial.positionX || j != becterial.positionY) &&
                   [[_becterialContainer objectAtIndex:i] objectAtIndex:j] != [NSNull null])
                {
                    other = [[_becterialContainer objectAtIndex:i] objectAtIndex:j];
                    if(other.level == becterial.level)
                    {
                        if(other.type == 1)
                        {
                            isEnemy = YES;
                        }
                        count++;
                        [list addObject:other];
                    }
                }
            }
        }
        
        if(count >= 2)
        {
            BOOL isCallback = NO;
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
                        if(isEnemy && becterial.type == 0)
                        {
                            NSMutableArray *tmp = [_becterialContainer objectAtIndex:becterial.positionX];
                            [tmp replaceObjectAtIndex:becterial.positionY withObject:[NSNull null]];
                            [_becterialList removeObjectIdenticalTo:becterial];
                            [_container removeChild:becterial cleanup:YES];
                        }
                        else
                        {
                            becterial.level++;
                            self.exp = _exp + becterial.level;
                            self.maxLevel = becterial.level;
                            if (gLayer)
                            {
                                [[NSNotificationCenter defaultCenter] postNotificationName:@"guideRevolutionDone" object:nil];
                            }
                        }
                        runningAction--;
                        if(runningAction == 0)
                        {
                            //进化动画结束
                            //分裂
                            CGFloat rate = [Becterial getUpgradeSplit];
                            if(rate > 0)
                            {
                                rate = rate * 100;
                                if(arc4random() % 100 <= rate)
                                {
                                    if (becterial.type == 0)
                                    {
                                        [self putNewBacterialNoCost];
                                    }
                                    else
                                    {
                                        [self putNewEnemyNoCost];
                                    }
                                }
                            }

                            //养精蓄锐
                            rate = [Becterial getUpgradeStepIncRate];
                            if(rate > 0)
                            {
                                rate = rate * 100;
                                if(arc4random() % 100 <= rate)
                                {
                                    int stepInc = [Becterial getUpgradeStepInc];
                                    self.stepCount = _stepCount + stepInc;
                                }
                            }

                            //终极进化
                            rate = [Becterial getUpgradeAutoRevolution];
                            if(rate > 0)
                            {
                                rate = rate * 100;
                                if(arc4random() % 100 <= rate)
                                {
                                    becterial.level++;
                                    self.exp = _exp + becterial.level;
                                    self.maxLevel = becterial.level;
                                }
                            }

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

            return YES;
        }
    }
    return NO;
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

-(void)btnGenerateScore
{
    if (_biomass > 0)
    {
        self.biomass = _biomass - 5;
        self.score = _score + 10;
        
        [self saveGame];
    }
}

-(void)btnGenerateBiomass
{
    self.biomass = _biomass + 5;
    [self saveGame];
}

-(void)putNewBacterial
{
    if(_score >= NEW_BACTERIAL_COST && _biomass > 0 && [self generateBacterial:0])
    {
        self.score = _score - NEW_BACTERIAL_COST * (1 - [Becterial getUpgradeScoreCostDec]);
        
        if(![self evolution])
        {
            [self saveGame];
        }
    }
    
    [self checkResult];
}

-(void)putNewBacterialNoCost
{
    if([self generateBacterial:0])
    {
        if(![self evolution])
        {
            [self saveGame];
        }
    }
    
    [self checkResult];
}

-(void)putNewBacterial:(int)x andY:(int)y
{
    if(_score >= NEW_BACTERIAL_COST && _biomass > 0 && [self generateBacterial:0 x:x y:y])
    {
        self.score = _score - NEW_BACTERIAL_COST * (1 - [Becterial getUpgradeScoreCostDec]);
        
        if(![self evolution])
        {
            [self saveGame];
        }
        
        if(guideBacterialPositionIndex < 2)
        {
            guideBacterialPositionIndex++;
        }
    }
    
    [self checkResult];
}

-(void)putNewEnemy
{
    if(_score >= NEW_ENEMY_COST && [self generateBacterial:1])
    {
        self.score = _score - NEW_ENEMY_COST * (1 - [Becterial getUpgradeScoreCostDec]);

        if(![self evolution])
        {
            [self saveGame];
        }
    }
    
    [self checkResult];
}

-(void)putNewEnemyNoCost
{
    if([self generateBacterial:1])
    {
        if(![self evolution])
        {
            [self saveGame];
        }
    }
    
    [self checkResult];
}

-(void)putNewEnemy:(int)x andY:(int)y
{
    if(_score >= NEW_ENEMY_COST && [self generateBacterial:1 x:x y:y])
    {
        self.score = _score - NEW_ENEMY_COST * (1 - [Becterial getUpgradeScoreCostDec]);
        
        if(![self evolution])
        {
            [self saveGame];
        }
        
        if(guideEnemyPositionIndex < 2)
        {
            guideEnemyPositionIndex++;
        }
    }
    
    [self checkResult];
}

-(void)menu
{
    [self showScoreScene];
}

-(void)setStepCount:(int)stepCount
{
    if(_stepCount != stepCount)
    {
        _stepCount = stepCount;
        _lblStepCount.score = stepCount;
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

-(void)setBiomass:(CGFloat)biomass
{
    if(_biomass != biomass)
    {
        _biomass = biomass;
        _lblBiomass.score = biomass;
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

-(CCNode *)container
{
    return _container;
}

-(void)useKiller:(int)x andY:(int)y
{
    // if([[_becterialContainer objectAtIndex:x] objectAtIndex:y] == [NSNull null])
    // {
    //     return;
    // }
    
    // Becterial *b = [[_becterialContainer objectAtIndex:x] objectAtIndex:y];
    // if(b.type == 1)
    // {
    //     NSMutableArray *tmp = [_becterialContainer objectAtIndex:x];
    //     [tmp replaceObjectAtIndex:y withObject:[NSNull null]];
    //     [_becterialList removeObjectIdenticalTo:b];
    //     [_container removeChild:b];
    //     self.killerCount--;
    //     [self checkResult];
    //     [self saveGame];
    // }
    imgAccelerationBg.visible = YES;
    inAccelerated = YES;
    accelerationTime = defualtAccelerateTime;
    self.killerCount--;
    [self checkResult];
    [self saveGame];
}

-(void)checkResult
{
    if(self.stepCount == 0)
    {
        ScoreScene *score = [self showScoreScene];
        [score setOver:YES];
        return;
    }

    NSMutableArray *list = [[NSMutableArray alloc] init];
    int bCount = 0;
    int eCount = 0;
    CGFloat bBiomass = 0.f;
    CGFloat eBiomass = 0.f;
    CGFloat bScore = 0.f;
    for (int i = 0; i < [_becterialContainer count]; i++)
    {
        NSMutableArray *tmp = [_becterialContainer objectAtIndex:i];
        for (int j = 0; j < [tmp count]; j++)
        {
            if([tmp objectAtIndex:j] == [NSNull null])
            {
                CGPoint p = ccp(i, j);
                [list addObject:[NSValue valueWithCGPoint:p]];
            }
            else
            {
                Becterial *b = (Becterial *)[tmp objectAtIndex:j];
                if(b.type == 0)
                {
                    bCount++;
                    bBiomass = bBiomass + BACTERIAL_BIOMASS * b.level;
                    bScore = bScore + BACTERIAL_SCORE * (b.level * b.level);
                }
                else if(b.type == 1)
                {
                    eCount++;
                    eBiomass = eBiomass + ENEMY_BIOMASS * b.level;
                }
            }
        }
    }

    bacterialCount = bCount;
    enemyCount = eCount;
    bacterialBiomass = bBiomass * (1 - [Becterial getUpgradeBiomassDec]);
    enemyBiomass = eBiomass * (1 + [Becterial getUpgradeBiomassInc]);

    CGFloat scoreIncreaseRate = 1 + [Becterial getUpgradeScoreInc];
    if(inAccelerated)
    {
        scoreIncreaseRate = scoreIncreaseRate + accelerateIncreaseBiomassRate;
    }
    scoreOffset = bScore * scoreIncreaseRate;
    
    long count = [list count];
    if(count == 0)
    {
        ScoreScene *score = [self showScoreScene];
        [score setOver:YES];
    }
}

-(void)saveGame
{
    NSString *path = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    NSString *file = [path stringByAppendingPathComponent:@"savegame"];
    NSData *becterials = [NSKeyedArchiver archivedDataWithRootObject:_becterialList];
    NSDictionary *data = [NSDictionary dictionaryWithObjectsAndKeys:
        [NSNumber numberWithInt:_stepCount], @"stepCount",
        [NSNumber numberWithFloat:_score], @"score",
        [NSNumber numberWithFloat:_biomass], @"biomass",
        [NSNumber numberWithFloat:_maxLevel], @"maxLevel",
        [NSNumber numberWithInt:bacterialCount], @"bacterialCount",
        [NSNumber numberWithInt:enemyCount], @"enemyCount",
        [NSNumber numberWithFloat:bacterialBiomass], @"bacterialBiomass",
[NSNumber numberWithFloat:enemyBiomass], @"enemyBiomass",
        [NSNumber numberWithFloat:scoreOffset], @"scoreOffset",
        [NSNumber numberWithFloat:runningTime], @"runningTime",
        [NSNumber numberWithBool:inAccelerated], @"inAccelerated",
        [NSNumber numberWithInt:accelerationTime], @"accelerationTime",
        [NSNumber numberWithInt:guideEnemyPositionIndex], @"guideEnemyPositionIndex",
        [NSNumber numberWithInt:guideBacterialPositionIndex], @"guideBacterialPositionIndex",
                          
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
    self.stepCount = [[data objectForKey:@"stepCount"] intValue];
    self.score = [[data objectForKey:@"score"] floatValue];
    self.biomass = [[data objectForKey:@"biomass"] floatValue];
    _maxLevel = [[data objectForKey:@"maxLevel"] floatValue];
    self.killerCount = dataKillerCount;
    bacterialCount = [[data objectForKey:@"bacterialCount"] intValue];
    enemyCount = [[data objectForKey:@"enemyCount"] intValue];
    bacterialBiomass = [[data objectForKey:@"bacterialBiomass"] floatValue];
    enemyBiomass = [[data objectForKey:@"enemyBiomass"] floatValue];
    scoreOffset = [[data objectForKey:@"scoreOffset"] floatValue];
    _becterialList = [NSKeyedUnarchiver unarchiveObjectWithData:[data objectForKey:@"bacterials"]];
    runningTime = [[data objectForKey:@"runningTime"] floatValue];
    inAccelerated = [[data objectForKey:@"inAccelerated"] boolValue];
    accelerationTime = [[data objectForKey:@"accelerationTime"] intValue];
    guideEnemyPositionIndex = [[data objectForKey:@"guideEnemyPositionIndex"] intValue];
    guideBacterialPositionIndex = [[data objectForKey:@"guideBacterialPositionIndex"] intValue];
    if(_becterialList == nil)
    {
        _becterialList = [[NSMutableArray alloc] init];
    }

    return YES;
}

-(void)reset
{
    inAccelerated = NO;
    accelerationTime = defualtAccelerateTime;
    runningTime = 0;
    self.maxLevel = 0;
    self.stepCount = defaultStepCount;
    self.score = 0;
    self.biomass = 0;
    [_becterialList removeAllObjects];
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
    [scoreScene setScore:_score];
    [scoreScene setTime:runningTime];
    [scoreScene setExp:[DataStorageManager sharedDataStorageManager].exp];
    CGFloat rate = _score / runningTime;
    [scoreScene setRate:rate];
    CCScene *scene = [CCScene new];
    [scene addChild:scoreScene];
    [[CCDirector sharedDirector] replaceScene:scene];

    return scoreScene;
}

@end
