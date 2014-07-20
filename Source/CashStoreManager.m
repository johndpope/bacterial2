//
//  CashStoreManager.m
//  bacterial
//
//  Created by 李翌文 on 14-7-2.
//  Copyright (c) 2014年 Apportable. All rights reserved.
//

#import <StoreKit/StoreKit.h>
#import "CashStoreManager.h"
#import "DataStorageManager.h"

#define dataStorageManagerConfig [DataStorageManager sharedDataStorageManager].config

@implementation CashStoreManager

static CashStoreManager *_instance = nil;

+(CashStoreManager *)sharedCashStoreManager
{
	if(!_instance)
	{
		_instance = [[CashStoreManager alloc] init];
	}

	return _instance;
}

-(void)validateProductIdentifiers:(NSArray *)productIdentifiers
{
	SKProductsRequest *productsRequest = [[SKProductsRequest alloc]
	initWithProductIdentifiers:[NSSet setWithArray:productIdentifiers]];
	productsRequest.delegate = self;
	[productsRequest start];
}

-(void)purchaseProduct:(NSString *)identifier
{
    SKProduct *product;
    for (product in _products)
    {
        if([product.productIdentifier isEqualToString:identifier])
        {
            break;
        }
    }
    
    if(product)
    {
        SKPayment *payment = [SKPayment paymentWithProduct:product];
        [[SKPaymentQueue defaultQueue] addPayment:payment];
    }
}

-(void)productsRequest:(SKProductsRequest *)request didReceiveResponse:(SKProductsResponse *)response
{
	_products = response.products;
    _invalidProducts = response.invalidProductIdentifiers;
    
    if(dataStorageManagerConfig)
    {
        NSDictionary *productData = [dataStorageManagerConfig objectForKey:@"products"];
        NSArray *products = [productData objectForKey:@"result"];
        if(products)
        {
            NSComparator sorter = ^NSComparisonResult(SKProduct *p1, SKProduct *p2)
            {
                NSString *identifier1 = p1.productIdentifier;
                NSString *identifier2 = p2.productIdentifier;
                NSDictionary *product1;
                NSDictionary *product2;
                for (NSDictionary *p in products)
                {
                    if([identifier1 isEqualToString:[p objectForKey:@"productIdentifier"]])
                    {
                        product1 = p;
                    }
                    else if([identifier2 isEqualToString:[p objectForKey:@"productIdentifier"]])
                    {
                        product2 = p;
                    }
                    if(product1 && product2)
                    {
                        break;
                    }
                }
                if(product1 && product2)
                {
                    int sort1 = [[product1 objectForKey:@"sort"] intValue];
                    int sort2 = [[product2 objectForKey:@"sort"] intValue];
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
                }
                
                return (NSComparisonResult)NSOrderedSame;
            };
            
            _products = [_products sortedArrayUsingComparator:sorter];
        }
    }
    
    [[NSNotificationCenter defaultCenter] postNotificationName:@"hideLoadingIcon" object:nil];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"reloadCashStoreView" object:nil];
}

@end