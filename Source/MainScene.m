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
#define accelerateIncreaseBiomassRate 1.f;
#define dataExp [DataStorageManager sharedDataStorageManager].exp
#define dataStepCount [DataStorageManager sharedDataStorageManager].stepCount
#define dataKillerCount [DataStorageManager sharedDataStorageManager].killerCount
#define dataUperCount [DataStorageManager sharedDataStorageManager].uperCount
#define dataStorageManagerAchievement [DataStorageManager sharedDataStorageManager].achievementConst
#define dataStorageManagerGuide [DataStorageManager sharedDataStorageManager].guide
#define dataStorageManagerGuideStep [DataStorageManager sharedDataStorageManager].guideStep

NSArray *checkRevolutionPosition = nil;

@implementation MainScene
{
    BOOL isR4;
    CCLabelTTF *_lblKillerCount;
    CCLabelTTF *_lblUperCount;
    PZLabelScore *_lblExp; //金币
    PZLabelScore *_lblStepCount; //步数
    PZLabelScore *_lblScore; //分数
    CCNode *_container;
    Guide *gLayer;
    NSMutableArray *_becterialContainer;
    NSMutableArray *_becterialList;
    NSMutableArray *_enemyList;
    NSMutableArray *_enemyContainer;
    int runningAction;
    CGFloat runningTime;
    
    int _lastX;
    int _lastY;
    Becterial *_lastBacterial;

    int bacterialCount;
    int enemyCount;
    
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

    _lblScore = [PZLabelScore initWithScore:0 fileName:@"" itemWidth:14 itemHeight:22];
    if(isR4)
    {
        _lblScore.position = ccp(167.f, 510.f);
    }
    else
    {
        _lblScore.position = ccp(216.f, 456.f);
    }
    [self addChild:_lblScore];

    _lblExp = [PZLabelScore initWithScore:0 fileName:@"" itemWidth:14 itemHeight:22];
    if(isR4)
    {
        _lblExp.position = ccp(10.f, 510.f);
    }
    else
    {
        _lblExp.position = ccp(58.f, 456.f);
    }
    [self addChild:_lblExp];
    
    _lblStepCount = [PZLabelScore initWithScore:0 fileName:@"" itemWidth:14 itemHeight:22];
    if(isR4)
    {
        _lblStepCount.position = ccp(10.f, 416.f);
    }
    else
    {
        _lblStepCount.position = ccp(10.f, 390.f);
    }
    [self addChild:_lblStepCount];
    
    _maxLevel = 0;
    self.userInteractionEnabled = YES;
    
    checkRevolutionPosition = [NSArray arrayWithObjects:
                               [NSValue valueWithCGPoint:ccp(-1.f,0.f)],
                               [NSValue valueWithCGPoint:ccp(0.f,1.f)],
                               [NSValue valueWithCGPoint:ccp(-1.f,1.f)],
                               [NSValue valueWithCGPoint:ccp(1.f,1.f)], nil];
}

-(void)update:(CCTime)delta
{
    runningTime = runningTime + delta;
    if(runningTime >= 60.f)
    {
        //产生新的生物虫
        [self putNewEnemy];
        runningTime = 0.f;
    }
}

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
    /*
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
     */
    
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
        [self checkResult];
    }
    else
    {
        _becterialList = [[NSMutableArray alloc] init];
        _enemyList = [[NSMutableArray alloc] init];
        self.stepCount = defaultStepCount;
        self.exp = 0;
        self.killerCount = 0;
        self.uperCount = 0;
        _maxLevel = 0;
    }
}

-(void)didReceiveGuideNotification:(NSNotification *) notification
{
    if([notification.name isEqualToString:@"guideClickBiomass"])
    {
        gLayer.step++;
    }
    else if([notification.name isEqualToString:@"guideClickScore"])
    {
        gLayer.step++;
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
        
    }
    else if([notification.name isEqualToString:@"guideClickScore2"])
    {
        
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
        if(_lastBacterial && abs(position.x - _lastX) > 1 && _lastBacterial.type == 0)
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
    
    if (x > 4 || y > 5 || x < 0 || y < 0)
    {
        return;
    }
    NSLog(@"block touched");
    [self putNewBacterial:x andY:y];
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
                self.score = _score + 5 * pow(4, becterial.level - 1);
                self.maxLevel = becterial.level;
                if (gLayer)
                {
                    [[NSNotificationCenter defaultCenter] postNotificationName:@"guideRevolutionDone" object:nil];
                }
                
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
        if(![self evolution])
        {
            [self saveGame];
        }
        
        if(gLayer && guideBacterialPositionIndex < 2)
        {
            guideBacterialPositionIndex++;
        }

        [self checkResult];
    }
}

-(void)putNewEnemy
{
    if([self generateBacterial:1])
    {
        if(![self evolution])
        {
            [self saveGame];
        }

        [self checkResult];
    }
}

-(void)putNewEnemy:(int)x andY:(int)y
{
    if([self generateBacterial:1 x:x y:y])
    {
        if(![self evolution])
        {
            [self saveGame];
        }
        
        if(gLayer && guideEnemyPositionIndex < 2)
        {
            guideEnemyPositionIndex++;
        }

        [self checkResult];
    }
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
        b.nextEvolution = b.nextEvolution  + 60.f;
        self.killerCount--;
        [self checkResult];
        [self saveGame];
    }
}

-(void)useUper:(int)x andY:(int)y
{
    if([[_becterialContainer objectAtIndex:x] objectAtIndex:y] == [NSNull null])
    {
        return;
    }
    
    Becterial *b = [[_becterialContainer objectAtIndex:x] objectAtIndex:y];
    if(b.type == 1)
    {
        self.uperCount--;
        [self checkResult];
        [self saveGame];
    }
}

-(void)checkResult
{
    Becterial *enemy;
    Becterial *bacterial;
    NSMutableArray *tmp;

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
                        [tmp replaceObjectAtIndex:bacterial.positionY withObject:[NSNull null]];
                        [_becterialList removeObjectIdenticalTo:bacterial];
                        [_container removeChild:bacterial cleanup:YES];
                    }
                }
                [[_enemyContainer objectAtIndex:m] replaceObjectAtIndex:n withObject:[NSNumber numberWithBool:NO]];
            }
        }

        //判断是否被包围
        BOOL top = enemy.positionY == 5;
        BOOL left = enemy.positionX == 0;
        BOOL bottom = enemy.positionY == 0;
        BOOL right = enemy.positionX == 4;
        //上
        if(enemy.positionY < 5)
        {
            tmp = [_becterialContainer objectAtIndex:enemy.positionX];
            if([tmp objectAtIndex:enemy.positionY + 1] != [NSNull null])
            {
                bacterial = (Becterial *)[tmp objectAtIndex:enemy.positionY + 1];

                if(bacterial.level > enemy.level)
                {
                    top = YES;
                }
            }
        }
        //下
        if(enemy.positionY > 0)
        {
            tmp = [_becterialContainer objectAtIndex:enemy.positionX];
            if([tmp objectAtIndex:enemy.positionY - 1] != [NSNull null])
            {
                bacterial = (Becterial *)[tmp objectAtIndex:enemy.positionY - 1];

                if(bacterial.level > enemy.level)
                {
                    bottom = YES;
                }
            }
        }
        //左
        if(enemy.positionX > 0)
        {
            tmp = [_becterialContainer objectAtIndex:enemy.positionX - 1];
            if([tmp objectAtIndex:enemy.positionY] != [NSNull null])
            {
                bacterial = (Becterial *)[tmp objectAtIndex:enemy.positionY];

                if(bacterial.level > enemy.level)
                {
                    left = YES;
                }
            }
        }
        //右
        if(enemy.positionX < 4)
        {
            tmp = [_becterialContainer objectAtIndex:enemy.positionX + 1];
            if([tmp objectAtIndex:enemy.positionY] != [NSNull null])
            {
                bacterial = (Becterial *)[tmp objectAtIndex:enemy.positionY];

                if(bacterial.level > enemy.level)
                {
                    right = YES;
                }
            }
        }
        if(top && bottom && left && right)
        {
            NSLog(@"被消灭");
            tmp = [_becterialContainer objectAtIndex:enemy.positionX];
            [tmp replaceObjectAtIndex:enemy.positionY withObject:[NSNull null]];
            [_becterialList removeObjectIdenticalTo:enemy];
            [_enemyList removeObjectIdenticalTo:enemy];
            
            [_container removeChild:enemy cleanup:YES];
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
        ScoreScene *score = [self showScoreScene];
        [score setOver:YES];
    }
}

-(void)saveGame
{
    NSString *path = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    NSString *file = [path stringByAppendingPathComponent:@"savegame"];
    NSData *becterials = [NSKeyedArchiver archivedDataWithRootObject:_becterialList];
    NSData *enemies = [NSKeyedArchiver archivedDataWithRootObject:_enemyList];
    NSDictionary *data = [NSDictionary dictionaryWithObjectsAndKeys:
        [NSNumber numberWithFloat:_score], @"score",
        [NSNumber numberWithFloat:_maxLevel], @"maxLevel",
        [NSNumber numberWithInt:bacterialCount], @"bacterialCount",
        [NSNumber numberWithInt:enemyCount], @"enemyCount",
        [NSNumber numberWithFloat:runningTime], @"runningTime",
        [NSNumber numberWithInt:guideEnemyPositionIndex], @"guideEnemyPositionIndex",
        [NSNumber numberWithInt:guideBacterialPositionIndex], @"guideBacterialPositionIndex",
        becterials, @"bacterials",
        enemies, @"enemies", nil
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
    _enemyList = [NSKeyedUnarchiver unarchiveObjectWithData:[data objectForKey:@"enemies"]];
    runningTime = [[data objectForKey:@"runningTime"] floatValue];
    guideEnemyPositionIndex = [[data objectForKey:@"guideEnemyPositionIndex"] intValue];
    guideBacterialPositionIndex = [[data objectForKey:@"guideBacterialPositionIndex"] intValue];
    if(_becterialList == nil)
    {
        _becterialList = [[NSMutableArray alloc] init];
    }
    if(_enemyList == nil)
    {
        _enemyList = [[NSMutableArray alloc] init];
    }

    return YES;
}

-(void)reset
{
    runningTime = 0;
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
