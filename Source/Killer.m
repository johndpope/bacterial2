//
//  Killer.m
//  becterial
//
//  Created by 李翌文 on 14-6-29.
//  Copyright (c) 2014年 Apportable. All rights reserved.
//

#import "Killer.h"
#import "MainScene.h"

@implementation Killer
{
    CCSprite *_target;
}

-(void)touchBegan:(UITouch *)touch withEvent:(UIEvent *)event
{
    MainScene *scene = (MainScene *)[self parent];
    if(scene.killerCount > 0)
    {
        CGPoint position = [touch locationInNode:self.parent];
        CGPoint anchor = [touch locationInNode:self];
        _target = [CCSprite spriteWithImageNamed:@"resources/killer_normal.png"];
        _target.anchorPoint = ccp(anchor.x / self.contentSize.width, anchor.y / self.contentSize.height);
        _target.position = position;
        [self.parent addChild:_target];
    }
}

-(void)touchMoved:(UITouch *)touch withEvent:(UIEvent *)event
{
    MainScene *scene = (MainScene *)[self parent];
    if(scene.killerCount > 0 && _target)
    {
        CGPoint position = [touch locationInNode:self.parent];
        _target.position = position;
    }
}

-(void)touchEnded:(UITouch *)touch withEvent:(UIEvent *)event
{
    MainScene *scene = (MainScene *)[self parent];
    if(scene.killerCount > 0 && _target)
    {
        [self.parent removeChild:_target];
        
        CGPoint position = [touch locationInWorld];
        position = [[scene container] convertToNodeSpace:position];
        
        int x = position.x / 60.5f;
        int y = position.y / 60.5f;
        
        if (x > 4 || y > 4 || x < 0 || y < 0)
        {
            return;
        }
        
        [scene useKiller:x andY:y];
    }
}

@end
