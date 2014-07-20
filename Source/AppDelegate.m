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

#import <StoreKit/StoreKit.h>

@implementation AppController

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
    
    [MobClick startWithAppkey:@"53ca09da56240bbd9b011e55"];
    [UMSocialData setAppKey:@"53ca09da56240bbd9b011e55"];
    [UMSocialWechatHandler setWXAppId:@"wxfa1868e8028fdf80" url:@"http://b.profzone.net/services/share/wechat"];

    [YouMiConfig setShouldGetLocation:NO];
    [YouMiConfig launchWithAppID:@"5993d19fa9e134c3" appSecret:@"e620f97ee3da012d"];
    [YouMiPointsManager enable];
    [YouMiWall enable];

#ifdef DEBUG_MODE
   [MobClick setLogEnabled:YES];
#endif

    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didLoadVersionConfig:) name:@"requestVersionConfig" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didConnectFailed:) name:@"connectionError1009" object:nil];
    [[PZWebManager sharedPZWebManager] asyncGetRequest:@"http://b.profzone.net/configuration/version_config" withData:nil];
    
    return YES;
}

-(void)didConnectFailed:(NSNotification *)notification
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"connectionError1009" object:nil];
    //如果未连接互联网 就读取存档配置
    [[DataStorageManager sharedDataStorageManager] loadConfig];
    if(![DataStorageManager sharedDataStorageManager].config)
    {
        [DataStorageManager sharedDataStorageManager].config = [NSMutableDictionary new];
        
        //如果没有存档就读取内置配置
        //IAP配置
        NSString *file = [[NSBundle mainBundle] pathForResource:@"products" ofType:@"plist"];
        NSArray *result = [[NSArray alloc] initWithContentsOfFile:file];
        NSDictionary *productsResult = [NSDictionary dictionaryWithObjectsAndKeys:
                                        result, @"result",
                                        [NSDictionary new], @"version", nil];
        [[DataStorageManager sharedDataStorageManager].config setObject:productsResult forKey:@"products"];
        
        //Upgrade配置
        NSString *upgradeConstFilePath = [[NSBundle mainBundle] pathForResource:@"upgrade_const" ofType:@"plist"];
        NSDictionary *result1 = [[NSDictionary alloc] initWithContentsOfFile:upgradeConstFilePath];
        NSDictionary *upgradeResult = [NSDictionary dictionaryWithObjectsAndKeys:
                                        result1, @"result",
                                        [NSDictionary new], @"version", nil];
        [[DataStorageManager sharedDataStorageManager].config setObject:upgradeResult forKey:@"upgrade_const"];
    }
    //score board
    NSDictionary *scoreboardResult = [NSDictionary dictionaryWithObjectsAndKeys:
                                      [NSNumber numberWithInt:0], @"result",
                                      [NSDictionary new], @"version", nil];
    [[DataStorageManager sharedDataStorageManager].config setObject:scoreboardResult forKey:@"score_board"];
    
    //ad
    NSDictionary *adResult = [NSDictionary dictionaryWithObjectsAndKeys:
                                      [NSNumber numberWithInt:0], @"result",
                                      [NSDictionary new], @"version", nil];
    [[DataStorageManager sharedDataStorageManager].config setObject:adResult forKey:@"ad"];
    
    [[DataStorageManager sharedDataStorageManager] saveConfig];
}

-(void)didLoadVersionConfig:(NSNotification *)notification
{
    NSDictionary *data = [notification object];
    NSDictionary *result = [data objectForKey:@"result"];

    [[DataStorageManager sharedDataStorageManager] loadConfig];
    if(![DataStorageManager sharedDataStorageManager].config)
    {
        [DataStorageManager sharedDataStorageManager].config = [NSMutableDictionary new];
        [[DataStorageManager sharedDataStorageManager] saveConfig];

        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didReceiveFromServer:) name:@"requestGlobalConfig" object:nil];
        [[PZWebManager sharedPZWebManager] asyncGetRequest:@"http://b.profzone.net/configuration/global_config" withData:nil];
    }
    else
    {
        //循环检查各个配置的version与获得的是否相同
        NSArray *keys = [[DataStorageManager sharedDataStorageManager].config allKeys];
        for(NSString *key in keys)
        {
            NSDictionary *config = [[DataStorageManager sharedDataStorageManager].config objectForKey:key];
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
            NSMutableDictionary *config = [[DataStorageManager sharedDataStorageManager].config objectForKey:@"products"];
            if(config)
            {
                [config setObject:version forKey:@"version"];
            }
            else
            {
                config = [NSMutableDictionary new];
                [config setObject:version forKey:@"version"];
                [[DataStorageManager sharedDataStorageManager].config setObject:config forKey:@"products"];
            }
            [config setObject:productArray forKey:@"result"];
            
            [[CashStoreManager sharedCashStoreManager] validateProductIdentifiers:productArray];

            //upgrade
            NSDictionary *upgradeData = [data objectForKey:@"upgrade_const"];
            NSDictionary *upgrade = [upgradeData objectForKey:@"result"];
            version = [upgradeData objectForKey:@"version"];
            config = [[DataStorageManager sharedDataStorageManager].config objectForKey:@"upgrade_const"];
            if(config)
            {
                [config setObject:version forKey:@"version"];
            }
            else
            {
                config = [NSMutableDictionary new];
                [config setObject:version forKey:@"version"];
                [[DataStorageManager sharedDataStorageManager].config setObject:config forKey:@"upgrade_const"];
            }
            [config setObject:upgrade forKey:@"result"];

            //score board
            NSDictionary *scoreboardResult = [data objectForKey:@"score_board"];
            int scoreboard = [[scoreboardResult objectForKey:@"result"] intValue];
            version = [scoreboardResult objectForKey:@"version"];
            config = [[DataStorageManager sharedDataStorageManager].config objectForKey:@"score_board"];
            if(config)
            {
                [config setObject:version forKey:@"version"];
            }
            else
            {
                config = [NSMutableDictionary new];
                [config setObject:version forKey:@"version"];
                [[DataStorageManager sharedDataStorageManager].config setObject:config forKey:@"score_board"];
            }
            [config setObject:[NSNumber numberWithInt:scoreboard] forKey:@"result"];
            
            //ad
            NSDictionary *adResult = [data objectForKey:@"ad"];
            int ad = [[adResult objectForKey:@"result"] intValue];
            version = [adResult objectForKey:@"version"];
            config = [[DataStorageManager sharedDataStorageManager].config objectForKey:@"ad"];
            if(config)
            {
                [config setObject:version forKey:@"version"];
            }
            else
            {
                config = [NSMutableDictionary new];
                [config setObject:version forKey:@"version"];
                [[DataStorageManager sharedDataStorageManager].config setObject:config forKey:@"ad"];
            }
            [config setObject:[NSNumber numberWithInt:ad] forKey:@"result"];
        }
        else if([command isEqualToString:@"requestProductIds"])
        {
            NSDictionary *products = [data objectForKey:@"products"];
            NSArray *productArray = [products objectForKey:@"result"];
            NSString *version = [products objectForKey:@"version"];
            NSMutableDictionary *config = [[DataStorageManager sharedDataStorageManager].config objectForKey:@"products"];
            if(config)
            {
                [config setObject:version forKey:@"version"];
            }
            else
            {
                config = [NSMutableDictionary new];
                [config setObject:version forKey:@"version"];
                [[DataStorageManager sharedDataStorageManager].config setObject:config forKey:@"products"];
            }
            [config setObject:productArray forKey:@"result"];
            
            [[CashStoreManager sharedCashStoreManager] validateProductIdentifiers:productArray];
        }
        else if([command isEqualToString:@"requestUpgradeConst"])
        {
            NSDictionary *upgradeData = [data objectForKey:@"upgrade_const"];
            NSDictionary *upgrade = [upgradeData objectForKey:@"result"];
            NSDictionary *version = [upgradeData objectForKey:@"version"];
            NSMutableDictionary *config = [[DataStorageManager sharedDataStorageManager].config objectForKey:@"upgrade_const"];
            if(config)
            {
                [config setObject:version forKey:@"version"];
            }
            else
            {
                config = [NSMutableDictionary new];
                [config setObject:version forKey:@"version"];
                [[DataStorageManager sharedDataStorageManager].config setObject:config forKey:@"upgrade_const"];
            }
            [config setObject:upgrade forKey:@"result"];
        }
        else if([command isEqualToString:@"requestScoreBoard"])
        {
            NSDictionary *scoreboardResult = [data objectForKey:@"score_board"];
            int scoreboard = [[scoreboardResult objectForKey:@"result"] intValue];
            NSDictionary *version = [scoreboardResult objectForKey:@"version"];
            NSMutableDictionary *config = [[DataStorageManager sharedDataStorageManager].config objectForKey:@"score_board"];
            if(config)
            {
                [config setObject:version forKey:@"version"];
            }
            else
            {
                config = [NSMutableDictionary new];
                [config setObject:version forKey:@"version"];
                [[DataStorageManager sharedDataStorageManager].config setObject:config forKey:@"score_board"];
            }
            [config setObject:[NSNumber numberWithInt:scoreboard] forKey:@"result"];
        }
        else if([command isEqualToString:@"requestAd"])
        {
            NSDictionary *adResult = [data objectForKey:@"ad"];
            int ad = [[adResult objectForKey:@"result"] intValue];
            NSDictionary *version = [adResult objectForKey:@"version"];
            NSMutableDictionary *config = [[DataStorageManager sharedDataStorageManager].config objectForKey:@"ad"];
            if(config)
            {
                [config setObject:version forKey:@"version"];
            }
            else
            {
                config = [NSMutableDictionary new];
                [config setObject:version forKey:@"version"];
                [[DataStorageManager sharedDataStorageManager].config setObject:config forKey:@"ad"];
            }
            [config setObject:[NSNumber numberWithInt:ad] forKey:@"result"];
        }

        [[DataStorageManager sharedDataStorageManager] saveConfig];
    }
}

- (CCScene*) startScene
{
    [[DataStorageManager sharedDataStorageManager] loadData];
    NSDictionary *upgradeConst = [DataStorageManager sharedDataStorageManager].upgradeConst;
    NSMutableDictionary *upgradeData = [DataStorageManager sharedDataStorageManager].upgradeData;
    NSArray *keys = [upgradeData allKeys];
    for(NSString *key in keys)
    {
        int index = [[upgradeData objectForKey:key] intValue];
        NSDictionary *item = [upgradeConst objectForKey:key];
        if(item)
        {
            NSArray *levels = [item objectForKey:@"levels"];
            NSDictionary *level = [levels objectAtIndex:index-1];
            NSDictionary *additional = [level objectForKey:@"additional"];
            NSArray *adds = [additional allKeys];
            for(NSString *add in adds)
            {
                if([add isEqualToString:@"upgradeScoreInc"])
                {
                    [Becterial setUpgradeScoreInc:[[additional objectForKey:add] floatValue]];
                }
                else if([add isEqualToString:@"upgradeBiomassDec"])
                {
                    [Becterial setUpgradeBiomassDec:[[additional objectForKey:add] floatValue]];
                }
                else if([add isEqualToString:@"upgradeBiomassInc"])
                {
                    [Becterial setUpgradeBiomassInc:[[additional objectForKey:add] floatValue]];
                }
                else if([add isEqualToString:@"upgradeSplit"])
                {
                    [Becterial setUpgradeSplit:[[additional objectForKey:add] floatValue]];
                }
                else if([add isEqualToString:@"upgradeScoreCostDec"])
                {
                    [Becterial setUpgradeScoreCostDec:[[additional objectForKey:add] floatValue]];
                }
                else if([add isEqualToString:@"upgradeAutoRevolution"])
                {
                    [Becterial setUpgradeAutoRevolution:[[additional objectForKey:add] floatValue]];
                }
                else if([add isEqualToString:@"upgradeStepInc"])
                {
                    [Becterial setUpgradeStepInc:[[additional objectForKey:add] intValue]];
                }
                else if([add isEqualToString:@"upgradeStepIncRate"])
                {
                    [Becterial setUpgradeStepIncRate:[[additional objectForKey:add] floatValue]];
                }
            }
        }
    }

    //加载资源
    [[CCSpriteFrameCache sharedSpriteFrameCache] addSpriteFramesWithFile:@"number.plist"];

    [[GameCenterManager sharedGameCenterManager] authenticateLocalPlayer];

    #ifdef DEBUG_MODE
    [[CCDirector sharedDirector] setDisplayStats:YES];
    #endif

    if(iPhone5)
    {
        return [CCBReader loadAsScene:@"MainScene-r4"];
    }
    else
    {
        return [CCBReader loadAsScene:@"MainScene"];
    }
}

@end
