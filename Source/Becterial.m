//
//  Becterial.m
//  becterial
//
//  Created by 李翌文 on 14-6-23.
//  Copyright (c) 2014年 Apportable. All rights reserved.
//

#import "Becterial.h"
#import "MainScene.h"
#import "PZLabelScore.h"
#import "define.h"

@implementation Becterial
{
    CGFloat _lastX;
    CGFloat _lastY;
    CCSprite *lv;
    PZLabelScore *lblLevel;
    MainScene *mainScene;
    CCProgressNode *cdNode;
    BOOL _isNew;
}

-(id)init
{
    self = [super init];
    if(self)
    {
        self.nextEvolution = ENEMY_EVOLUTION_BASIC_TIME;
        self.nextEvolutionCurrent = ENEMY_EVOLUTION_BASIC_TIME;
        self.userInteractionEnabled = YES;
        self.scale = 0.f;
        _isNew = YES;
    }
    return self;
}

-(void)onEnter
{
    [super onEnter];

    mainScene = (MainScene *)self.parent.parent;

    CCActionScaleTo *aScaleTo = [CCActionScaleTo actionWithDuration:.2f scale:1.f];
    [self runAction:aScaleTo];
    _isNew = NO;
}

-(void)update:(CCTime)delta
{
    if(mainScene.isRunning && _type == 1)
    {
        if(_nextEvolutionCurrent > 0)
        {
            self.nextEvolutionCurrent = _nextEvolutionCurrent - delta;
            cdNode.percentage = (_nextEvolutionCurrent / _nextEvolution) * 100.f;
        }
        else
        {
            //进化
            self.level++;
            [mainScene checkResult];
        }
    }
}

-(CCProgressNode *)getProgressNode
{
    return cdNode;
}

-(void)touchBegan:(UITouch *)touch withEvent:(UIEvent *)event
{
    if(_type == 0)
    {
        CGPoint position = [touch locationInNode:self.parent];
        _lastX = position.x;
        _lastY = position.y;
    }
}

-(void)touchEnded:(UITouch *)touch withEvent:(UIEvent *)event
{
    CGPoint position = [touch locationInNode:self.parent];
    if(abs(position.x - _lastX) > 1 && _type == 0)
    {
        if(abs(position.x - _lastX) > abs(position.y - _lastY))
        {
            if(position.x < _lastX)
            {
                if(_positionX > 0)
                {
                    [mainScene moveBecterial:self x:_positionX - 1 y:_positionY];
                }
            }
            else
            {
                if(_positionX < 4)
                {
                    [mainScene moveBecterial:self x:_positionX + 1 y:_positionY];
                }
            }
        }
        else
        {
            if(position.y < _lastY)
            {
                if(_positionY > 0)
                {
                    [mainScene moveBecterial:self x:_positionX y:_positionY - 1];
                }
            }
            else
            {
                if(_positionY < 5)
                {
                    [mainScene moveBecterial:self x:_positionX y:_positionY + 1];
                }
            }
        }
    }
}

-(void)setLevel:(int)level
{
	if(_level != level && level <= MAXLEVEL)
	{
        if(_level > 0)
        {
            CCSprite *up = (CCSprite *)[CCBReader load:@"Up"];
            up.anchorPoint = ccp(0.f, 0.f);
            up.position = ccp(0.f, 0.f);
            [up.animationManager setCompletedAnimationCallbackBlock:^(id sender)
            {
                [up removeFromParentAndCleanup:YES];
            }];
            [self addChild:up];
        }
        
		_level = level;
        if(_type == 0)
        {
            self.spriteFrame = [CCSpriteFrame frameWithImageNamed:[NSString stringWithFormat:@"resources/%i%i.png", _type, level]];
        }
        else if(!_isNew)
        {
            CCActionScaleTo *aScaleTo1 = [CCActionScaleTo actionWithDuration:.2f scale:0.8f];
            CCActionScaleTo *aScaleTo2 = [CCActionScaleTo actionWithDuration:.1f scale:1.1f];
            CCActionScaleTo *aScaleTo3 = [CCActionScaleTo actionWithDuration:.1f scale:1.f];
            [self runAction:[CCActionSequence actionWithArray:@[aScaleTo1, aScaleTo2, aScaleTo3]]];
        }
        [lblLevel setScore:level];

        if(level <= 9)
        {
            self.nextEvolutionCurrent = ENEMY_EVOLUTION_BASIC_TIME + (level - 1) * 5;
            self.nextEvolution = _nextEvolutionCurrent;
        }
        else
        {
            self.nextEvolutionCurrent = ENEMY_EVOLUTION_MAX_TIME;
            self.nextEvolution = _nextEvolutionCurrent;
        }
	}
}

-(void)setType:(int)type
{
    _type = type;
    if(type == 1)
    {
        self.spriteFrame = [CCSpriteFrame frameWithImageNamed:@"enemy/enemy0.png"];
        
        lv = [CCSprite spriteWithImageNamed:@"number_small/lv.png"];
        lv.anchorPoint = ccp(0.f, 0.f);
        lv.position = ccp(0.f, 0.f);
        [self addChild:lv];
        
        lblLevel = [PZLabelScore initWithScore:0 fileName:@"number_small/" itemWidth:8 itemHeight:10];
        lblLevel.anchorPoint = ccp(0.f, 0.f);
        lblLevel.position = ccp(15.f, 0.f);
        [self addChild:lblLevel];
        
        CCSprite *s = [CCSprite spriteWithImageNamed:@"resources/bacterial_cd.png"];
        cdNode = [CCProgressNode progressWithSprite:s];
        cdNode.type = CCProgressNodeTypeRadial;
        cdNode.anchorPoint = ccp(0.f, 0.f);
        cdNode.position = ccp(0.f, 0.f);
        cdNode.percentage = 0.f;
        [self addChild:cdNode];
    }
}

//序列化
-(void)encodeWithCoder:(NSCoder *)aCoder
{
    [aCoder encodeInt:_level forKey:@"level"];
    [aCoder encodeInt:_type forKey:@"type"];
    [aCoder encodeInt:_positionX forKey:@"positionX"];
    [aCoder encodeInt:_positionY forKey:@"positionY"];
    [aCoder encodeFloat:_nextEvolution forKey:@"nextEvolution"];
    [aCoder encodeFloat:_nextEvolutionCurrent forKey:@"nextEvolutionCurrent"];
}

//反序列化
-(id)initWithCoder:(NSCoder *)aDecoder
{
    if(self = [super init])
    {
        self.userInteractionEnabled = YES;
        self.type = [aDecoder decodeIntForKey:@"type"];
        self.level = [aDecoder decodeIntForKey:@"level"];
        self.positionX = [aDecoder decodeIntForKey:@"positionX"];
        self.positionY = [aDecoder decodeIntForKey:@"positionY"];
        self.nextEvolution = [aDecoder decodeFloatForKey:@"nextEvolution"];
        self.nextEvolutionCurrent = [aDecoder decodeFloatForKey:@"nextEvolutionCurrent"];
    }

    return self;
}

@end
