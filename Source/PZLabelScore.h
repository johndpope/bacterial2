//
//  PZLabelScore.h
//  becterial
//
//  Created by 李翌文 on 14-6-28.
//  Copyright (c) 2014年 Apportable. All rights reserved.
//

#import "CCNode.h"

@interface PZLabelScore : CCNode

@property (nonatomic) int padding;
@property (nonatomic) int score;
@property (nonatomic) int itemWidth;
@property (nonatomic) int itemHeight;
@property (nonatomic, strong) NSString *fileName;

+(id)initWithScore:(int)score fileName:(NSString *)fileName itemWidth:(int)itemWidth itemHeight:(int)itemHeight;

@end
