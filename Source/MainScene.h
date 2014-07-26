//
//  MainScene.h
//  PROJECTNAME
//
//  Created by Viktor on 10/10/13.
//  Copyright (c) 2013 Apportable. All rights reserved.
//

#import "CCNode.h"
#import "ScoreScene.h"
#import "Becterial.h"

@interface MainScene : CCNode

@property (nonatomic) BOOL isRunning;
@property (nonatomic) CGFloat score; //分数
@property (nonatomic) int stepCount; //步数
@property (nonatomic) int exp; //金币
@property (nonatomic) int killerCount;
@property (nonatomic) int uperCount;
@property (nonatomic) int maxLevel;

-(void)moveBecterial:(Becterial *)becterial x:(int)x y:(int)y;
-(CCNode *)container;
-(void)useKiller:(int)x andY:(int)y;
-(void)useUper:(int)x andY:(int)y;
-(void)saveGame;
-(BOOL)loadGame;
-(void)checkResult;
-(void)reset;
-(ScoreScene *)showScoreScene;

@end
