//
//  StoreScene.m
//  bacterial2
//
//  Created by 李翌文 on 14-7-24.
//  Copyright (c) 2014年 Apportable. All rights reserved.
//

#import "define.h"
#import "StoreScene.h"
#import "StoreItem.h"
#import "DataStorageManager.h"
#import "CashStoreManager.h"
#import "Reachability.h"

#define dataConfig [DataStorageManager sharedDataStorageManager].config
#define sharedCashStoreManager [CashStoreManager sharedCashStoreManager]

@implementation StoreScene
{
    CCNode *containerLoading;
    CCNode *containerMessage;
    CCButton *btnMessageMask;
    CCButton *btnLoadingMask;
    CCLabelTTF *lblMessage;
    CCLabelTTF *lblLoadingMessage;
    CCNode *containerItems;
    CCSprite *spriteLoading;
    
    BOOL isR4;
}

-(void)didLoadFromCCB
{
    isR4 = iPhone5;
    containerLoading.visible = NO;
    containerMessage.visible = NO;
    btnMessageMask.enabled = NO;
    btnLoadingMask.enabled = NO;
    
    CCAnimationManager *animate = spriteLoading.animationManager;
    [animate setCompletedAnimationCallbackBlock:^(id sender)
    {
        [sender runAnimationsForSequenceNamed:@"loading"];
    }];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"hideLoadingIcon" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(hideLoadingIcon:) name:@"hideLoadingIcon" object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"showLoadingIcon" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(showLoadingIcon:) name:@"showLoadingIcon" object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"showSuccessView" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(showSuccessView:) name:@"showSuccessView" object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"reloadCashStoreView" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reloadCashStoreView:) name:@"reloadCashStoreView" object:nil];
    
    CGFloat offsetY = 0.f;
    NSDictionary *config = dataConfig;
    NSDictionary *productsResult = [config objectForKey:@"products"];
    NSArray *products = [productsResult objectForKey:@"result"];
    if (!products)
    {
        //取默认plist
        NSString *file = [[NSBundle mainBundle] pathForResource:@"products" ofType:@"plist"];
        products = [[NSArray alloc] initWithContentsOfFile:file];
    }
    
    if(sharedCashStoreManager.products)
    {
        for (SKProduct *product in sharedCashStoreManager.products)
        {
            StoreItem *item = (StoreItem *)[CCBReader load:@"StoreItem"];
            item.identifier = product.productIdentifier;
            for (NSDictionary *p in products)
            {
                NSString *_id = [p objectForKey:@"productIdentifier"];
                if([product.productIdentifier isEqualToString: _id])
                {
                    NSDictionary *items = [p objectForKey:@"items"];
                    int count = [[items objectForKey:@"gold"] intValue];
                    [item setGoldCount:count];
                    NSNumber *number = [items objectForKey:@"step"];
                    if(number)
                    {
                        count = [number intValue];
                        [item setStepCount:count];
                        [item showGiveaway];
                    }
                    number = [items objectForKey:@"uper"];
                    if(number)
                    {
                        count = [number intValue];
                        [item setUperCount:count];
                    }
                    number = [items objectForKey:@"killer"];
                    if(number)
                    {
                        count = [number intValue];
                        [item setKillerCount:count];
                    }
                    break;
                }
            }
            
            NSNumberFormatter *numberFormatter = [[NSNumberFormatter alloc] init];
            [numberFormatter setFormatterBehavior:NSNumberFormatterBehavior10_4];
            [numberFormatter setNumberStyle:NSNumberFormatterCurrencyStyle];
            [numberFormatter setLocale:product.priceLocale];
            NSString *formattedPrice = [numberFormatter stringFromNumber:product.price];
            [item setPrice:formattedPrice];
            item.position = ccp(0.f, offsetY);
            [containerItems addChild:item];
            offsetY = offsetY - item.contentSize.height - 5.f;
        }
    }
    else
    {
        NSComparator sorter = ^NSComparisonResult(NSDictionary *item1, NSDictionary *item2)
        {
            int sort1 = [[item1 objectForKey:@"sort"] intValue];
            int sort2 = [[item2 objectForKey:@"sort"] intValue];
            if(sort1 > sort2)
            {
                return (NSComparisonResult)NSOrderedDescending;
            }
            else if(sort1 < sort2)
            {
                return (NSComparisonResult)NSOrderedAscending;
            }
            else
            {
                return (NSComparisonResult)NSOrderedSame;
            }
        };
        NSMutableArray *idArray = [NSMutableArray new];
        
        products = [products sortedArrayUsingComparator:sorter];
        Reachability *reach = [Reachability reachabilityForInternetConnection];
        NetworkStatus netStatus = [reach currentReachabilityStatus];
        if(netStatus != NotReachable)
        {
            for (NSDictionary *product in products)
            {
                NSString *_id = [product objectForKey:@"productIdentifier"];
                [idArray addObject:_id];
            }
            [sharedCashStoreManager validateProductIdentifiers:idArray];
            [lblLoadingMessage setString:@"加载商品列表"];
            containerLoading.visible = YES;
        }
        else
        {
            for (NSDictionary *product in products)
            {
                StoreItem *item = (StoreItem *)[CCBReader load:@"StoreItem"];
                item.identifier = [product objectForKey:@"productIdentifier"];
                
                NSDictionary *items = [product objectForKey:@"items"];
                int count = [[items objectForKey:@"gold"] intValue];
                [item setGoldCount:count];
                NSNumber *number = [items objectForKey:@"step"];
                if(number)
                {
                    count = [number intValue];
                    [item setStepCount:count];
                    [item showGiveaway];
                }
                number = [items objectForKey:@"uper"];
                if(number)
                {
                    count = [number intValue];
                    [item setUperCount:count];
                }
                number = [items objectForKey:@"killer"];
                if(number)
                {
                    count = [number intValue];
                    [item setKillerCount:count];
                }
                [item setPrice:[product objectForKey:@"price"]];
                item.position = ccp(0.f, offsetY);
                [containerItems addChild:item];
                offsetY = offsetY - item.contentSize.height - 5.f;
            }
        }
    }
}

-(void)reloadCashStoreView:(NSNotification *)notification
{
    
    CGFloat offsetY = 0.f;
    NSDictionary *config = dataConfig;
    NSDictionary *productsResult = [config objectForKey:@"products"];
    NSArray *products = [productsResult objectForKey:@"result"];
    if (!products)
    {
        //取默认plist
        NSString *file = [[NSBundle mainBundle] pathForResource:@"products" ofType:@"plist"];
        products = [[NSArray alloc] initWithContentsOfFile:file];
    }
    
    if(sharedCashStoreManager.products)
    {
        for (SKProduct *product in sharedCashStoreManager.products)
        {
            StoreItem *item = (StoreItem *)[CCBReader load:@"StoreItem"];
            item.identifier = product.productIdentifier;
            for (NSDictionary *p in products)
            {
                NSString *_id = [p objectForKey:@"productIdentifier"];
                if([product.productIdentifier isEqualToString: _id])
                {
                    NSDictionary *items = [p objectForKey:@"items"];
                    int count = [[items objectForKey:@"gold"] intValue];
                    [item setGoldCount:count];
                    NSNumber *number = [items objectForKey:@"step"];
                    if(number)
                    {
                        count = [number intValue];
                        [item setStepCount:count];
                        [item showGiveaway];
                    }
                    number = [items objectForKey:@"uper"];
                    if(number)
                    {
                        count = [number intValue];
                        [item setUperCount:count];
                    }
                    number = [items objectForKey:@"killer"];
                    if(number)
                    {
                        count = [number intValue];
                        [item setKillerCount:count];
                    }
                    break;
                }
            }
            
            NSNumberFormatter *numberFormatter = [[NSNumberFormatter alloc] init];
            [numberFormatter setFormatterBehavior:NSNumberFormatterBehavior10_4];
            [numberFormatter setNumberStyle:NSNumberFormatterCurrencyStyle];
            [numberFormatter setLocale:product.priceLocale];
            NSString *formattedPrice = [numberFormatter stringFromNumber:product.price];
            [item setPrice:formattedPrice];
            item.position = ccp(0.f, offsetY);
            [containerItems addChild:item];
            offsetY = offsetY - item.contentSize.height - 5.f;
        }
    }
}

-(void)showLoadingIcon:(NSNotification *)notification
{
    [lblLoadingMessage setString:@"正在获取..."];
    containerLoading.visible = YES;
}

-(void)hideLoadingIcon:(NSNotification *)notification
{
    containerLoading.visible = NO;
}

-(void)showSuccessView:(NSNotification *)notification
{
    NSString *content = (NSString *)[notification object];
    [lblMessage setString:content];
    containerMessage.visible = YES;
}

-(void)onEnter
{
    [super onEnter];
}

-(void)btnCloseTouch
{
    CCScene *s;
    if(isR4)
    {
        s = [CCBReader loadAsScene:@"VirtualStore-r4"];
    }
    else
    {
        s = [CCBReader loadAsScene:@"VirtualStore"];
    }
    
    [[CCDirector sharedDirector] replaceScene:s];
}

-(void)btnConfirmTouch
{
    containerMessage.visible = NO;
}

@end
