//
//  Becterial.m
//  becterial
//
//  Created by 李翌文 on 14-6-23.
//  Copyright (c) 2014年 Apportable. All rights reserved.
//

#import "Becterial.h"
#import "MainScene.h"

@implementation Becterial
{
    CGFloat _lastX;
    CGFloat _lastY;
    MainScene *mainScene;
}

static CGFloat upgradeScoreInc = 0.f;
static CGFloat upgradeBiomassDec = 0.f;
static CGFloat upgradeBiomassInc = 0.f;
static CGFloat upgradeSplit = 0.f;
static CGFloat upgradeScoreCostDec = 0.f;
static int upgradeStepInc = 0;
static CGFloat upgradeStepIncRate = 0.f;
static CGFloat upgradeAutoRevolution = 0.f;

+(CGFloat)getUpgradeScoreInc
{
    return upgradeScoreInc;
}

+(void)setUpgradeScoreInc:(CGFloat)value
{
    upgradeScoreInc = value;
}

+(CGFloat)getUpgradeBiomassDec
{
    return upgradeBiomassDec;
}

+(CGFloat)getUpgradeBiomassInc
{
    return upgradeBiomassInc;
}

+(CGFloat)getUpgradeSplit
{
    return upgradeSplit;
}

+(CGFloat)getUpgradeScoreCostDec
{
    return upgradeScoreCostDec;
}

+(int)getUpgradeStepInc
{
    return upgradeStepInc;
}

+(CGFloat)getUpgradeStepIncRate
{
    return upgradeStepIncRate;
}

+(CGFloat)getUpgradeAutoRevolution
{
    return upgradeAutoRevolution;
}

+(void)setUpgradeBiomassDec:(CGFloat)value
{
    upgradeBiomassDec = value;
}

+(void)setUpgradeBiomassInc:(CGFloat)value
{
    upgradeBiomassInc = value;
}

+(void)setUpgradeSplit:(CGFloat)value
{
    upgradeSplit = value;
}

+(void)setUpgradeScoreCostDec:(CGFloat)value
{
    upgradeScoreCostDec = value;
}

+(void)setUpgradeStepInc:(int)value
{
    upgradeStepInc = value;
}

+(void)setUpgradeStepIncRate:(CGFloat)value
{
    upgradeStepIncRate = value;
}

+(void)setUpgradeAutoRevolution:(CGFloat)value
{
    upgradeAutoRevolution = value;
}

-(id)init
{
    self = [super init];
    if(self)
    {
        self.newBecterial = YES;
    }
    return self;
}

-(void)onEnter
{
    [super onEnter];

    mainScene = (MainScene *)self.parent.parent;
    self.userInteractionEnabled = YES;
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
    if(abs(position.x - _lastX) > 1 && _type == 0 && mainScene.biomass > 0)
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
                if(_positionY < 4)
                {
                    [mainScene moveBecterial:self x:_positionX y:_positionY + 1];
                }
            }
        }
    }
}

-(void)setLevel:(int)level
{
	if(_level != level)
	{
		_level = level;
        self.spriteFrame = [CCSpriteFrame frameWithImageNamed:[NSString stringWithFormat:@"resources/%i%i.png", _type, level]];
	}
}

-(Becterial *)clone
{
    Becterial *b = (Becterial *)[CCBReader load:@"Becterial"];
    b.level = self.level;
    b.type = self.type;
    b.positionX = self.positionX;
    b.positionY = self.positionY;
    b.newBecterial = NO;
    b.position = ccp(self.position.x, self.position.y);
    b.anchorPoint = ccp(0.f, 0.f);
    
    return b;
}

//序列化
-(void)encodeWithCoder:(NSCoder *)aCoder
{
    [aCoder encodeInt:_level forKey:@"level"];
    [aCoder encodeInt:_type forKey:@"type"];
    [aCoder encodeInt:_positionX forKey:@"positionX"];
    [aCoder encodeInt:_positionY forKey:@"positionY"];
}

//反序列化
-(id)initWithCoder:(NSCoder *)aDecoder
{
    if(self = [super init])
    {
        self.type = [aDecoder decodeIntForKey:@"type"];
        self.level = [aDecoder decodeIntForKey:@"level"];
        self.positionX = [aDecoder decodeIntForKey:@"positionX"];
        self.positionY = [aDecoder decodeIntForKey:@"positionY"];
        self.newBecterial = NO;
    }

    return self;
}

@end
