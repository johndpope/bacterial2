//
//  Becterial.h
//  becterial
//
//  Created by 李翌文 on 14-6-23.
//  Copyright (c) 2014年 Apportable. All rights reserved.
//

#import "CCSprite.h"

@interface Becterial : CCSprite<NSCoding>

@property (nonatomic) int level;
@property (nonatomic) int type;
@property (nonatomic) int positionX;
@property (nonatomic) int positionY;
@property (nonatomic) CGFloat nextEvolution;
@property (nonatomic) CGFloat nextEvolutionCurrent;
@property (nonatomic) BOOL checked; //用于检查生物虫是否已判定被包围

-(CCProgressNode *)getProgressNode;

@end
