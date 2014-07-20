//
//  DataStorageManager.h
//  bacterial
//
//  Created by 李翌文 on 14-7-4.
//  Copyright (c) 2014年 Apportable. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DataStorageManager : NSObject

@property (nonatomic) int killerCount;
@property (nonatomic) int exp;
@property (nonatomic) BOOL guide;
@property (nonatomic) int guideStep;
@property (nonatomic, strong) NSMutableDictionary *upgradeData;
@property (nonatomic, strong) NSDictionary *upgradeConst;
@property (nonatomic, strong) NSDictionary *achievementConst;
@property (nonatomic, strong) NSMutableDictionary *config;

+(DataStorageManager *)sharedDataStorageManager;
-(void)saveData;
-(BOOL)loadData;
-(void)saveConfig;
-(void)loadConfig;

@end
