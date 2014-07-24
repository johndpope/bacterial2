//
//  StoreItem.h
//  bacterial2
//
//  Created by 李翌文 on 14-7-24.
//  Copyright (c) 2014年 Apportable. All rights reserved.
//

#import "CCNode.h"

@interface StoreItem : CCNode

@property (nonatomic, strong) NSString *identifier;

-(void)showGiveaway;
-(void)setGoldCount:(int)count;
-(void)setStepCount:(int)count;
-(void)setUperCount:(int)count;
-(void)setKillerCount:(int)count;
-(void)setPrice:(NSString *)price;

@end
