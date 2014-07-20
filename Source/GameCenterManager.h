//
//  GameCenterManager.h
//  bacterial
//
//  Created by 李翌文 on 14-6-23.
//  Copyright (c) 2014年 Apportable. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <GameKit/GameKit.h>

@class GKLocalPlayer;

@interface GameCenterManager : NSObject
<GKGameCenterControllerDelegate>

@property (nonatomic) BOOL enabled;
@property (nonatomic, strong) GKLocalPlayer *localPlayer;
@property (nonatomic, strong) NSString *leaderboardIdentifier;

+ (GameCenterManager *) sharedGameCenterManager;
- (BOOL) isGameCenterAvailable;
- (void) authenticateLocalPlayer;
- (void) retrieveFriends;
- (void) loadPlayerData: (NSArray *) identifiers;
- (void) loadDefaultLeaderboard;
- (void) reportScore: (int64_t) score;
- (void) showLeaderboard;
- (void) reportAchievementIdentifier: (NSString*) identifier percentComplete: (float) percent;

@end
