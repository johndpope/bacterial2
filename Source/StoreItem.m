//
//  StoreItem.m
//  bacterial2
//
//  Created by 李翌文 on 14-7-24.
//  Copyright (c) 2014年 Apportable. All rights reserved.
//

#import "StoreItem.h"
#import "Reachability.h"
#import "StoreScene.h"
#import "CashStoreManager.h"

@implementation StoreItem
{
    CCLabelTTF *lblGoldCount;
    CCNode *containerGiveaway;
    CCLabelTTF *lblStepCount;
    CCLabelTTF *lblUperCount;
    CCLabelTTF *lblKillerCount;
    CCLabelTTF *lblPrice;
}

-(void)didLoadFromCCB
{
    containerGiveaway.visible = NO;
}

-(void)btnBuy
{
	Reachability *reach = [Reachability reachabilityForInternetConnection];
    NetworkStatus netStatus = [reach currentReachabilityStatus];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"showLoadingIcon" object:nil];
    if(netStatus != NotReachable)
    {
	    [[CashStoreManager sharedCashStoreManager] purchaseProduct:_identifier];
	}
	else
	{
        [[NSNotificationCenter defaultCenter] postNotificationName:@"hideLoadingIcon" object:nil];
        [[NSNotificationCenter defaultCenter] postNotificationName:@"showSuccessView" object:@"似乎没有网络连接哦"];
	}
}

-(void)showGiveaway
{
    containerGiveaway.visible = YES;
}

-(void)setGoldCount:(int)count
{
    [lblGoldCount setString:[NSString stringWithFormat:@"x%i", count]];
}

-(void)setStepCount:(int)count
{
    [lblStepCount setString:[NSString stringWithFormat:@"x%i", count]];
}

-(void)setUperCount:(int)count
{
    [lblUperCount setString:[NSString stringWithFormat:@"x%i", count]];
}

-(void)setKillerCount:(int)count
{
    [lblKillerCount setString:[NSString stringWithFormat:@"x%i", count]];
}

-(void)setPrice:(NSString *)price
{
    [lblPrice setString:price];
}

@end
