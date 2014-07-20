//
//  CashStoreItemView.m
//  bacterial
//
//  Created by 李翌文 on 14-7-1.
//  Copyright (c) 2014年 Apportable. All rights reserved.
//

#import "CashStoreItemView.h"
#import "CashStoreManager.h"
#import "CashStoreView.h"
#import "Reachability.h"

@implementation CashStoreItemView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

-(IBAction)btnBuyTouched:(id)sender
{
	Reachability *reach = [Reachability reachabilityForInternetConnection];     
    NetworkStatus netStatus = [reach currentReachabilityStatus];
    CashStoreView *v = (CashStoreView *)self.superview.superview;
	v.loadingView.hidden = NO;
    if(netStatus != NotReachable)
    {
	    [[CashStoreManager sharedCashStoreManager] purchaseProduct:_identifier];
	}
	else
	{
		v.loadingView.hidden = YES;
        [[NSNotificationCenter defaultCenter] postNotificationName:@"showSuccessView" object:@"似乎没有网络连接哦"];
	}
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

@end
