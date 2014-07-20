//
//  Becterial.h
//  becterial
//
//  Created by 李翌文 on 14-6-23.
//  Copyright (c) 2014年 Apportable. All rights reserved.
//

#import "CCSprite.h"

@interface Becterial : CCSprite<NSCoding>

@property (nonatomic) BOOL newBecterial;
@property (nonatomic) int level;
@property (nonatomic) int type;
@property (nonatomic) int positionX;
@property (nonatomic) int positionY;

+(CGFloat)getUpgradeScoreInc;
+(CGFloat)getUpgradeBiomassDec;
+(CGFloat)getUpgradeBiomassInc;
+(CGFloat)getUpgradeSplit;
+(CGFloat)getUpgradeScoreCostDec;
+(int)getUpgradeStepInc;
+(CGFloat)getUpgradeStepIncRate;
+(CGFloat)getUpgradeAutoRevolution;
+(void)setUpgradeScoreInc:(CGFloat)value;
+(void)setUpgradeBiomassDec:(CGFloat)value;
+(void)setUpgradeBiomassInc:(CGFloat)value;
+(void)setUpgradeSplit:(CGFloat)value;
+(void)setUpgradeScoreCostDec:(CGFloat)value;
+(void)setUpgradeStepInc:(int)value;
+(void)setUpgradeStepIncRate:(CGFloat)value;
+(void)setUpgradeAutoRevolution:(CGFloat)value;
-(Becterial *)clone;

@end
