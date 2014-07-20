//
//  CashStorePaymentObserver.m
//  bacterial
//
//  Created by 李翌文 on 14-7-3.
//  Copyright (c) 2014年 Apportable. All rights reserved.
//

#import "CashStorePaymentObserver.h"
#import "PZWebManager.h"
#import "MobClickGameAnalytics.h"
#import "DataStorageManager.h"
#import "CashStoreViewController.h"

@implementation CashStorePaymentObserver
{
    NSArray *_transactions;
}

static CashStorePaymentObserver *_sharedCashStorePaymentObserver = nil;

+(CashStorePaymentObserver *)sharedCashStorePaymentObserver
{
    if(!_sharedCashStorePaymentObserver)
    {
        _sharedCashStorePaymentObserver = [[CashStorePaymentObserver alloc] init];
    }
    return _sharedCashStorePaymentObserver;
}

-(void)didReceiveFromServer:(NSNotification *)notification
{
    NSDictionary *data = [notification object];
    int code = [[data objectForKey:@"code"] intValue];
    if(code == 1001)
    {
        NSString *identifier = [data objectForKey:@"identifier"];
        NSArray *items = [data objectForKey:@"items"];
        [self deliverProduct:items withIdentifier:identifier];
    }
    else
    {
        [[NSNotificationCenter defaultCenter] postNotificationName:@"hideLoadingIcon" object:nil];
        NSString *message;
        if(code == 1403)
        {
            message = @"交易凭证验证失败";
        }
        else if(code == 1404)
        {
            message = @"道具编号未找到";
        }
        else
        {
            message = @"缺少交易的必要参数";
        }
        [[NSNotificationCenter defaultCenter] postNotificationName:@"showSuccessView" object:message];
    }
}

-(void)deliverProduct:(NSArray *)items withIdentifier:(NSString *)identifier
{
    int exp = [DataStorageManager sharedDataStorageManager].exp;
    for(NSDictionary *item in items)
    {
        NSString *name = [item objectForKey:@"name"];
        int count = [[item objectForKey:@"count"] intValue];
        if([name isEqualToString:@"exp"])
        {
            exp = exp + count;
        }
    }
    
    [DataStorageManager sharedDataStorageManager].exp = exp;
    [[DataStorageManager sharedDataStorageManager] saveData];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"reloadExp" object:nil];
    [self deliverComplete:identifier withItem:items];
}

-(void)deliverComplete:(NSString *)identifier withItem:(NSArray *)items;
{
    [[NSNotificationCenter defaultCenter] postNotificationName:@"hideLoadingIcon" object:nil];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"showSuccessView" object:@"购买成功"];
    //find transaction with identifier
    if(_transactions)
    {
        for (SKPaymentTransaction *transaction in _transactions)
        {
            if ([identifier isEqualToString:transaction.payment.productIdentifier])
            {
                [[SKPaymentQueue defaultQueue] finishTransaction:transaction];
                NSArray *tmp = [identifier componentsSeparatedByString:@"."];
                NSString *itemId;
                if([tmp count] > 1)
                {
                    itemId = [tmp objectAtIndex: [tmp count] - 1];
                }
                else
                {
                    itemId = identifier;
                }
                int cash = [[itemId substringFromIndex:6] intValue];
                
                for(NSDictionary *item in items)
                {
                    NSString *name = [item objectForKey:@"name"];
                    int count = [[item objectForKey:@"count"] intValue];
                    if([name isEqualToString:@"exp"])
                    {
                        [MobClickGameAnalytics pay:cash source:1 coin:count];
                    }
                }
                break;
            }
        }
    }
}

-(void)paymentQueue:(SKPaymentQueue *)queue updatedTransactions:(NSArray *)transactions
{
    _transactions = transactions;
    for (SKPaymentTransaction *transaction in transactions)
    {
        switch (transaction.transactionState)
        {
            case SKPaymentTransactionStatePurchased:
            {
                NSString *receipt = [self encode:(uint8_t *)transaction.transactionReceipt.bytes
                                          length:transaction.transactionReceipt.length];
                [[NSNotificationCenter defaultCenter] removeObserver:self name:@"checkReceipt" object:nil];
                [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didReceiveFromServer:) name:@"checkReceipt" object:nil];
                NSDictionary *data = [NSDictionary dictionaryWithObjectsAndKeys:
                                      transaction.payment.productIdentifier, @"identifier",
                                      receipt, @"receipt", nil];
                [[PZWebManager sharedPZWebManager] asyncPostRequest:@"http://b.profzone.net/order/check_receipt" withData:data];
                break;
            }
            case SKPaymentTransactionStateFailed:
            {
                [[NSNotificationCenter defaultCenter] postNotificationName:@"showSuccessView" object:transaction.error.localizedDescription];
                [[SKPaymentQueue defaultQueue] finishTransaction:transaction];
                [[NSNotificationCenter defaultCenter] postNotificationName:@"hideLoadingIcon" object:nil];
                break;
            }
            case SKPaymentTransactionStateRestored:
            {
                NSLog(@"restored");
                NSString *receipt = [self encode:(uint8_t *)transaction.transactionReceipt.bytes
                                          length:transaction.transactionReceipt.length];
                [[NSNotificationCenter defaultCenter] removeObserver:self name:@"checkReceipt" object:nil];
                [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didReceiveFromServer:) name:@"checkReceipt" object:nil];
                NSDictionary *data = [NSDictionary dictionaryWithObjectsAndKeys:
                                      transaction.payment.productIdentifier, @"identifier",
                                      receipt, @"receipt", nil];
                [[PZWebManager sharedPZWebManager] asyncPostRequest:@"http://b.profzone.net/order/check_receipt" withData:data];
                [[NSNotificationCenter defaultCenter] postNotificationName:@"hideLoadingIcon" object:nil];
                break;
            }
            default:
                break;
        }
    }
}

-(void)paymentQueue:(SKPaymentQueue *)queue removedTransactions:(NSArray *)transactions
{
    NSLog(@"transaction removed!");
}

-(void)paymentQueue:(SKPaymentQueue *)queue restoreCompletedTransactionsFailedWithError:(NSError *)error
{
    NSLog(@"restoreCompletedTransactionsFailedWithError: %@", error.localizedDescription);
}

-(void)paymentQueue:(SKPaymentQueue *)queue updatedDownloads:(NSArray *)downloads
{
    NSLog(@"updatedDownloads: %@", downloads);
}

-(void)paymentQueueRestoreCompletedTransactionsFinished:(SKPaymentQueue *)queue
{
    NSLog(@"paymentQueueRestoreCompletedTransactionsFinished");
}

-(NSString *)encode:(const uint8_t *)input length:(NSInteger)length
{
    static char table[] = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/=";
    
    NSMutableData *data = [NSMutableData dataWithLength:((length + 2) / 3) * 4];
    uint8_t *output = (uint8_t *)data.mutableBytes;
    
    for (NSInteger i = 0; i < length; i += 3) {
        NSInteger value = 0;
        for (NSInteger j = i; j < (i + 3); j++) {
            value <<= 8;
            
            if (j < length) {
                value |= (0xFF & input[j]);
            }
        }
        
        NSInteger index = (i / 3) * 4;
        output[index + 0] =                    table[(value >> 18) & 0x3F];
        output[index + 1] =                    table[(value >> 12) & 0x3F];
        output[index + 2] = (i + 1) < length ? table[(value >> 6)  & 0x3F] : '=';
        output[index + 3] = (i + 2) < length ? table[(value >> 0)  & 0x3F] : '=';
    }
    
    return [[NSString alloc] initWithData:data encoding:NSASCIIStringEncoding];
}

@end
