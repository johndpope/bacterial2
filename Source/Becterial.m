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
}

-(id)init
{
    self = [super init];
    if(self)
    {
        lv = [CCSprite spriteWithImageNamed:@"number_small/lv.png"];
        lv.anchorPoint = ccp(0.f, 0.f);
        lv.position = ccp(0.f, 0.f);
        [self addChild:lv];
        
        lblLevel = [PZLabelScore initWithScore:0 fileName:@"number_small/" itemWidth:8 itemHeight:10];
        lblLevel.anchorPoint = ccp(0.f, 0.f);
        lblLevel.position = ccp(15.f, 0.f);
        [self addChild:lblLevel];
        
        self.nextEvolution = ENEMY_EVOLUTION_BASIC_TIME;
        self.userInteractionEnabled = YES;
    }
    return self;
}

-(void)onEnter
{
    [super onEnter];

    mainScene = (MainScene *)self.parent.parent;

    CCActionScaleTo *aScaleTo = [CCActionScaleTo actionWithDuration:.3f scale:1.f];
    [self runAction:aScaleTo];
}

-(void)update:(CCTime)delta
{
    if(_type == 1)
    {
        if(_nextEvolution > 0)
        {
            self.nextEvolution = _nextEvolution - delta;
        }
        else
        {
            //进化
            self.level++;
            [mainScene checkResult];
        }
    }
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
		_level = level;
        if(_type == 0)
        {
            self.spriteFrame = [CCSpriteFrame frameWithImageNamed:[NSString stringWithFormat:@"resources/%i%i.png", _type, level]];
        }
        else
        {
            self.opacity = 1.f - (MAXLEVEL - level) / (CGFloat)MAXLEVEL;
        }
        [lblLevel setScore:level];

        if(level <= 9)
        {
            self.nextEvolution = ENEMY_EVOLUTION_BASIC_TIME + (level - 1) * 5;
        }
        else
        {
            self.nextEvolution = ENEMY_EVOLUTION_MAX_TIME;
        }
	}
}

-(void)setType:(int)type
{
    _type = type;
    if(type == 1)
    {
        self.spriteFrame = [CCSpriteFrame frameWithImageNamed:@"enemy/enemy1.png"];
    }
    else
    {
        lv.visible = NO;
        lblLevel.visible = NO;
    }
}

-(Becterial *)clone
{
    Becterial *b = (Becterial *)[CCBReader load:@"Becterial"];
    b.level = self.level;
    b.type = self.type;
    b.positionX = self.positionX;
    b.positionY = self.positionY;
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
    [aCoder encodeFloat:_nextEvolution forKey:@"nextEvolution"];
}

//反序列化
-(id)initWithCoder:(NSCoder *)aDecoder
{
    if(self = [super init])
    {
        lv = [CCSprite spriteWithImageNamed:@"number_small/lv.png"];
        lv.anchorPoint = ccp(0.f, 0.f);
        lv.position = ccp(0.f, 0.f);
        [self addChild:lv];
        
        lblLevel = [PZLabelScore initWithScore:0 fileName:@"number_small/" itemWidth:14 itemHeight:22];
        lblLevel.anchorPoint = ccp(0.f, 0.f);
        lblLevel.position = ccp(15.f, 0.f);
        [self addChild:lblLevel];
        
        self.nextEvolution = 60.f;
        self.userInteractionEnabled = YES;
        
        self.type = [aDecoder decodeIntForKey:@"type"];
        self.level = [aDecoder decodeIntForKey:@"level"];
        self.positionX = [aDecoder decodeIntForKey:@"positionX"];
        self.positionY = [aDecoder decodeIntForKey:@"positionY"];
        self.nextEvolution = [aDecoder decodeFloatForKey:@"nextEvolution"];
    }

    return self;
}

@end
