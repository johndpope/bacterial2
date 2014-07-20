//
//  ScoreScene.h
//  bacterial
//
//  Created by 李翌文 on 14-6-30.
//  Copyright (c) 2014年 Apportable. All rights reserved.
//

#import "CCNode.h"

@interface ScoreScene : CCNode

-(void)setOver:(BOOL)over;
-(void)setScore:(int)score;
-(void)setRate:(CGFloat)rate;
-(void)setExp:(int)exp;
-(void)setTime:(int)Time;

@end
