/*
 * SpriteBuilder: http://www.spritebuilder.org
 *
 * Copyright (c) 2012 Zynga Inc.
 * Copyright (c) 2013 Apportable Inc.
 *
 * Permission is hereby granted, free of charge, to any person obtaining a copy
 * of this software and associated documentation files (the "Software"), to deal
 * in the Software without restriction, including without limitation the rights
 * to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:
 *
 * The above copyright notice and this permission notice shall be included in
 * all copies or substantial portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
 * THE SOFTWARE.
 */

#import "cocos2d.h"
#import "define.h"

#import "MobClick.h"
#import "UMSocial.h"
#import "UMSocialWechatHandler.h"

#import "YouMiWall.h"
#import "YouMiPointsManager.h"

#import "AppDelegate.h"
#import "Becterial.h"
#import "CCBuilderReader.h"
#import "CashStorePaymentObserver.h"
#import "PZWebManager.h"
#import "CashStoreManager.h"
#import "DataStorageManager.h"
#import "GameCenterManager.h"
#import "MainScene.h"
#import "GuideScene.h"

#import <StoreKit/StoreKit.h>

#define dataStorageManager [DataStorageManager sharedDataStorageManager]
#define dataStorageManagerGuide [DataStorageManager sharedDataStorageManager].guide
#define dataStorageManagerGuideStep [DataStorageManager sharedDataStorageManager].guideStep

@implementation AppController
{
    int rewardGoldInScene;
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    // Configure Cocos2d with the options set in SpriteBuilder
    NSString* configPath = [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:@"Published-iOS"]; // TODO: add support for Published-Android support
    configPath = [configPath stringByAppendingPathComponent:@"configCocos2d.plist"];
    
    NSMutableDictionary* cocos2dSetup = [NSMutableDictionary dictionaryWithContentsOfFile:configPath];
    
    // Note: this needs to happen before configureCCFileUtils is called, because we need apportable to correctly setup the screen scale factor.
#ifdef APPORTABLE
    if([cocos2dSetup[CCSetupScreenMode] isEqual:CCScreenModeFixed])
        [UIScreen mainScreen].currentMode = [UIScreenMode emulatedMode:UIScreenAspectFitEmulationMode];
    else
        [UIScreen mainScreen].currentMode = [UIScreenMode emulatedMode:UIScreenScaledAspectFitEmulationMode];
#endif
    
    // Configure CCFileUtils to work with SpriteBuilder
    [CCBReader configureCCFileUtils];
    
    // Do any extra configuration of Cocos2d here (the example line changes the pixel format for faster rendering, but with less colors)
    //[cocos2dSetup setObject:kEAGLColorFormatRGB565 forKey:CCConfigPixelFormat];
    
    [self setupCocos2dWithOptions:cocos2dSetup];
    
    [[SKPaymentQueue defaultQueue] addTransactionObserver:[CashStorePaymentObserver sharedCashStorePaymentObserver]];
    
    [MobClick startWithAppkey:@"53d22a9c56240b9ab2080b1c"];
    [UMSocialData setAppKey:@"53d22a9c56240b9ab2080b1c"];
    [UMSocialWechatHandler setWXAppId:@"wxcb415985730902db" url:@"http://b2.profzone.net/services/share/wechat"];

    [YouMiConfig setShouldGetLocation:NO];
    [YouMiConfig launchWithAppID:@"4d8d51cf2afd8db6" appSecret:@"8bec478c6d3f2efc"];
    [YouMiPointsManager enable];

#ifdef DEBUG_MODE
    [MobClick setLogEnabled:YES];
#endif

    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didLoadVersionConfig:) name:@"requestVersionConfig" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didConnectFailed:) name:@"connectionError1009" object:nil];
    [[PZWebManager sharedPZWebManager] asyncGetRequest:@"http://b2.profzone.net/configuration/version_config" withData:nil];
    
    return YES;
}

-(void)didConnectFailed:(NSNotification *)notification
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"connectionError1009" object:nil];
    //如果未连接互联网 就读取存档配置
    [dataStorageManager loadConfig];
    if(!dataStorageManager.config)
    {
        dataStorageManager.config = [NSMutableDictionary new];
        
        //如果没有存档就读取内置配置
        //IAP配置
        NSString *file = [[NSBundle mainBundle] pathForResource:@"products" ofType:@"plist"];
        NSArray *result = [[NSArray alloc] initWithContentsOfFile:file];
        NSDictionary *productsResult = [NSDictionary dictionaryWithObjectsAndKeys:
                                        result, @"result",
                                        [NSDictionary new], @"version", nil];
        [dataStorageManager.config setObject:productsResult forKey:@"products"];
        //商店配置
        file = [[NSBundle mainBundle] pathForResource:@"virtual_const" ofType:@"plist"];
        result = [[NSArray alloc] initWithContentsOfFile:file];
        NSDictionary *virtualResult = [NSDictionary dictionaryWithObjectsAndKeys:
                                        result, @"result",
                                        [NSDictionary new], @"version", nil];
        [dataStorageManager.config setObject:virtualResult forKey:@"virtual_const"];
    }
    //score board
    NSDictionary *scoreboardResult = [NSDictionary dictionaryWithObjectsAndKeys:
                                      [NSNumber numberWithInt:0], @"result",
                                      [NSDictionary new], @"version", nil];
    [dataStorageManager.config setObject:scoreboardResult forKey:@"score_board"];
    
    //ad
    NSDictionary *adResult = [NSDictionary dictionaryWithObjectsAndKeys:
                                      [NSNumber numberWithInt:1], @"result",
                                      [NSDictionary new], @"version", nil];
    [dataStorageManager.config setObject:adResult forKey:@"ad"];
    
    //share reward
    NSDictionary *rewardResult = [NSDictionary dictionaryWithObjectsAndKeys:
                              [NSNumber numberWithInt:0], @"result",
                              [NSDictionary new], @"version", nil];
    [dataStorageManager.config setObject:rewardResult forKey:@"share_reward"];
    
    //activity
    NSDictionary *activityResult = [NSDictionary dictionaryWithObjectsAndKeys:
                                  [NSNumber numberWithInt:0], @"result",
                                  [NSDictionary new], @"version", nil];
    [dataStorageManager.config setObject:activityResult forKey:@"activity"];
    
    //time
    if(![dataStorageManager.config objectForKey:@"timestamp"])
    {
        [dataStorageManager.config setObject:[NSNumber numberWithInt:0] forKey:@"timestamp"];
    }

    [dataStorageManager saveConfig];
}

-(void)didLoadVersionConfig:(NSNotification *)notification
{
    NSDictionary *data = [notification object];
    NSDictionary *result = [data objectForKey:@"result"];
    NSNumber *number = [data objectForKey:@"timestamp"];

    [dataStorageManager loadConfig];
    if(!dataStorageManager.config)
    {
        dataStorageManager.config = [NSMutableDictionary new];
        if(!dataStorageManagerGuide)
        {
            [dataStorageManager.config setObject:number forKey:@"timestamp"];
            [dataStorageManager saveConfig];
        }

        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didReceiveFromServer:) name:@"requestGlobalConfig" object:nil];
        [[PZWebManager sharedPZWebManager] asyncGetRequest:@"http://b2.profzone.net/configuration/global_config" withData:nil];
    }
    else
    {

        if(!dataStorageManagerGuide)
        {
            //检查timestamp
            int timestamp = [number intValue];
            NSNumber *lastNumber = [dataStorageManager.config objectForKey:@"timestamp"];
            int lastTimestamp = [lastNumber intValue];
            if(lastTimestamp > 0 && timestamp > lastTimestamp)
            {
                //增加金币奖励
                int minutesOffset = (timestamp - lastTimestamp) / 60;
                if(minutesOffset > 0)
                {
                    int rewardGold = fmin(minutesOffset * REWARDGOLE_PER_MINUTES, 600);
                    rewardGoldInScene = rewardGold;
                    dataStorageManager.exp = dataStorageManager.exp + rewardGold;
                    [dataStorageManager saveData];
                    
                    [[NSNotificationCenter defaultCenter] postNotificationName:@"showRewardGold" object:[NSNumber numberWithInt:rewardGoldInScene]];
                }
            }
            [dataStorageManager.config setObject:number forKey:@"timestamp"];
            [dataStorageManager saveConfig];
        }
        //循环检查各个配置的version与获得的是否相同
        NSArray *keys = [dataStorageManager.config allKeys];
        for(NSString *key in keys)
        {
            if(![key isEqualToString:@"timestamp"])
            {
                NSDictionary *config = [dataStorageManager.config objectForKey:key];
                if(config)
                {
                    NSDictionary *versionResult = [config objectForKey:@"version"];
                    NSString *version = [versionResult objectForKey:@"version"];
                    NSDictionary *target = [result objectForKey:key];
                    if(target)
                    {
                        NSString *targetVersion = [target objectForKey:@"version"];
                        if(![version isEqualToString:targetVersion])
                        {
                            NSString *url = [target objectForKey:@"url"];
                            NSString *command = [target objectForKey:@"command"];

                            [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didReceiveFromServer:) name:command object:nil];
                            [[PZWebManager sharedPZWebManager] asyncGetRequest:url withData:nil];
                        }
                    }
                }
            }
        }
    }
}

-(void)didReceiveFromServer:(NSNotification *)notification
{
    NSDictionary *data = [notification object];
    NSString *command = [data objectForKey:@"command"];
    if(command)
    {
        if([command isEqualToString:@"requestGlobalConfig"])
        {
            //products
            NSDictionary *products = [data objectForKey:@"products"];
            NSArray *productArray = [products objectForKey:@"result"];
            NSString *version = [products objectForKey:@"version"];
            NSMutableDictionary *config = [dataStorageManager.config objectForKey:@"products"];
            if(config)
            {
                [config setObject:version forKey:@"version"];
            }
            else
            {
                config = [NSMutableDictionary new];
                [config setObject:version forKey:@"version"];
                [dataStorageManager.config setObject:config forKey:@"products"];
            }
            [config setObject:productArray forKey:@"result"];
            
            //virtual
            NSDictionary *virtualResult = [data objectForKey:@"virtual_const"];
            NSDictionary *virtual = [virtualResult objectForKey:@"result"];
            version = [virtualResult objectForKey:@"version"];
            config = [dataStorageManager.config objectForKey:@"virtual_const"];
            if(config)
            {
                [config setObject:version forKey:@"version"];
            }
            else
            {
                config = [NSMutableDictionary new];
                [config setObject:version forKey:@"version"];
                [dataStorageManager.config setObject:config forKey:@"virtual_const"];
            }
            [config setObject:virtual forKey:@"result"];

            //score board
            NSDictionary *scoreboardResult = [data objectForKey:@"score_board"];
            int scoreboard = [[scoreboardResult objectForKey:@"result"] intValue];
            version = [scoreboardResult objectForKey:@"version"];
            config = [dataStorageManager.config objectForKey:@"score_board"];
            if(config)
            {
                [config setObject:version forKey:@"version"];
            }
            else
            {
                config = [NSMutableDictionary new];
                [config setObject:version forKey:@"version"];
                [dataStorageManager.config setObject:config forKey:@"score_board"];
            }
            [config setObject:[NSNumber numberWithInt:scoreboard] forKey:@"result"];
            
            //ad
            NSDictionary *adResult = [data objectForKey:@"ad"];
            int ad = [[adResult objectForKey:@"result"] intValue];
            version = [adResult objectForKey:@"version"];
            config = [dataStorageManager.config objectForKey:@"ad"];
            if(config)
            {
                [config setObject:version forKey:@"version"];
            }
            else
            {
                config = [NSMutableDictionary new];
                [config setObject:version forKey:@"version"];
                [dataStorageManager.config setObject:config forKey:@"ad"];
            }
            [config setObject:[NSNumber numberWithInt:ad] forKey:@"result"];
            
            //share reward
            NSDictionary *rewardResult = [data objectForKey:@"share_reward"];
            int reward = [[rewardResult objectForKey:@"result"] intValue];
            version = [rewardResult objectForKey:@"version"];
            config = [dataStorageManager.config objectForKey:@"share_reward"];
            if(config)
            {
                [config setObject:version forKey:@"version"];
            }
            else
            {
                config = [NSMutableDictionary new];
                [config setObject:version forKey:@"version"];
                [dataStorageManager.config setObject:config forKey:@"share_reward"];
            }
            [config setObject:[NSNumber numberWithInt:reward] forKey:@"result"];
            
            //activity
            NSDictionary *activityResult = [data objectForKey:@"activity"];
            int activity = [[activityResult objectForKey:@"result"] intValue];
            version = [activityResult objectForKey:@"version"];
            config = [dataStorageManager.config objectForKey:@"activity"];
            if(config)
            {
                [config setObject:version forKey:@"version"];
            }
            else
            {
                config = [NSMutableDictionary new];
                [config setObject:version forKey:@"version"];
                [dataStorageManager.config setObject:config forKey:@"activity"];
            }
            [config setObject:[NSNumber numberWithInt:activity] forKey:@"result"];
        }
        else if([command isEqualToString:@"requestProductIds"])
        {
            NSDictionary *products = [data objectForKey:@"products"];
            NSArray *productArray = [products objectForKey:@"result"];
            NSString *version = [products objectForKey:@"version"];
            NSMutableDictionary *config = [dataStorageManager.config objectForKey:@"products"];
            if(config)
            {
                [config setObject:version forKey:@"version"];
            }
            else
            {
                config = [NSMutableDictionary new];
                [config setObject:version forKey:@"version"];
                [dataStorageManager.config setObject:config forKey:@"products"];
            }
            [config setObject:productArray forKey:@"result"];
        }
        else if([command isEqualToString:@"requestVirtualConst"])
        {
            NSDictionary *virtualResult = [data objectForKey:@"virtual_const"];
            NSDictionary *virtual = [virtualResult objectForKey:@"result"];
            NSDictionary *version = [virtualResult objectForKey:@"version"];
            NSMutableDictionary *config = [dataStorageManager.config objectForKey:@"virtual_const"];
            if(config)
            {
                [config setObject:version forKey:@"version"];
            }
            else
            {
                config = [NSMutableDictionary new];
                [config setObject:version forKey:@"version"];
                [dataStorageManager.config setObject:config forKey:@"virtual_const"];
            }
            [config setObject:virtual forKey:@"result"];
        }
        else if([command isEqualToString:@"requestScoreBoard"])
        {
            NSDictionary *scoreboardResult = [data objectForKey:@"score_board"];
            int scoreboard = [[scoreboardResult objectForKey:@"result"] intValue];
            NSDictionary *version = [scoreboardResult objectForKey:@"version"];
            NSMutableDictionary *config = [dataStorageManager.config objectForKey:@"score_board"];
            if(config)
            {
                [config setObject:version forKey:@"version"];
            }
            else
            {
                config = [NSMutableDictionary new];
                [config setObject:version forKey:@"version"];
                [dataStorageManager.config setObject:config forKey:@"score_board"];
            }
            [config setObject:[NSNumber numberWithInt:scoreboard] forKey:@"result"];
        }
        else if([command isEqualToString:@"requestAd"])
        {
            NSDictionary *adResult = [data objectForKey:@"ad"];
            int ad = [[adResult objectForKey:@"result"] intValue];
            NSDictionary *version = [adResult objectForKey:@"version"];
            NSMutableDictionary *config = [dataStorageManager.config objectForKey:@"ad"];
            if(config)
            {
                [config setObject:version forKey:@"version"];
            }
            else
            {
                config = [NSMutableDictionary new];
                [config setObject:version forKey:@"version"];
                [dataStorageManager.config setObject:config forKey:@"ad"];
            }
            [config setObject:[NSNumber numberWithInt:ad] forKey:@"result"];
        }
        else if([command isEqualToString:@"requestShareReward"])
        {
            NSDictionary *rewardResult = [data objectForKey:@"share_reward"];
            int reward = [[rewardResult objectForKey:@"result"] intValue];
            NSDictionary *version = [rewardResult objectForKey:@"version"];
            NSMutableDictionary *config = [dataStorageManager.config objectForKey:@"share_reward"];
            if(config)
            {
                [config setObject:version forKey:@"version"];
            }
            else
            {
                config = [NSMutableDictionary new];
                [config setObject:version forKey:@"version"];
                [dataStorageManager.config setObject:config forKey:@"share_reward"];
            }
            [config setObject:[NSNumber numberWithInt:reward] forKey:@"result"];
        }
        else if([command isEqualToString:@"requestActivity"])
        {
            NSDictionary *activityResult = [data objectForKey:@"activity"];
            int activity = [[activityResult objectForKey:@"result"] intValue];
            NSDictionary *version = [activityResult objectForKey:@"version"];
            NSMutableDictionary *config = [dataStorageManager.config objectForKey:@"activity"];
            if(config)
            {
                [config setObject:version forKey:@"version"];
            }
            else
            {
                config = [NSMutableDictionary new];
                [config setObject:version forKey:@"version"];
                [dataStorageManager.config setObject:config forKey:@"activity"];
            }
            [config setObject:[NSNumber numberWithInt:activity] forKey:@"result"];
        }

        [dataStorageManager saveConfig];
    }
}

- (CCScene*) startScene
{
    [dataStorageManager loadData];

    //加载资源
    [[CCSpriteFrameCache sharedSpriteFrameCache] addSpriteFramesWithFile:@"number.plist"];
    [[CCSpriteFrameCache sharedSpriteFrameCache] addSpriteFramesWithFile:@"number_small.plist"];
    [[CCSpriteFrameCache sharedSpriteFrameCache] addSpriteFramesWithFile:@"enemy.plist"];

    [[GameCenterManager sharedGameCenterManager] authenticateLocalPlayer];

    #ifdef DEBUG_MODE
    [[CCDirector sharedDirector] setDisplayStats:YES];
    #endif
    
    CCScene *scene = [CCScene node];
    if (dataStorageManagerGuide)
    {
        int guideStep = dataStorageManagerGuideStep;
        guideStep = fmax(1, guideStep);
        
        GuideScene *guide;
        if(iPhone5)
        {
            guide = (GuideScene *)[CCBReader load:@"GuideScene-r4"];
        }
        else
        {
            guide = (GuideScene *)[CCBReader load:@"GuideScene"];
        }
        guide.guideStep = guideStep;
        [scene addChild:guide];
    }
    else
    {
        MainScene *mainScene;
        if(iPhone5)
        {
            mainScene = (MainScene *)[CCBReader load:@"MainScene-r4"];
        }
        else
        {
            mainScene = (MainScene *)[CCBReader load:@"MainScene"];
        }
        [scene addChild:mainScene];
        if(rewardGoldInScene > 0)
        {
            [mainScene showRewardGold:rewardGoldInScene];
        }
    }
    return scene;
}

@end
