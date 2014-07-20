//
//  CashStoreManager.h
//  bacterial
//
//  Created by 李翌文 on 14-6-23.
//  Copyright (c) 2014年 Apportable. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <StoreKit/StoreKit.h>

@interface CashStoreManager : NSObject
<SKProductsRequestDelegate>

@property(nonatomic, readonly) NSArray *products;
@property(nonatomic, readonly) NSArray *invalidProducts;

+(CashStoreManager *)sharedCashStoreManager;
-(void)validateProductIdentifiers:(NSArray *)productIdentifiers;
-(void)purchaseProduct:(NSString *)identifier;

@end
