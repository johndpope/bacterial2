//
//  CashStoreView.m
//  bacterial
//
//  Created by 李翌文 on 14-7-1.
//  Copyright (c) 2014年 Apportable. All rights reserved.
//

#import "CashStoreView.h"
#import "CashStoreItemView.h"
#import "CashStoreManager.h"
#import <StoreKit/StoreKit.h>

#define sharedCashStoreManager [CashStoreManager sharedCashStoreManager]

@implementation CashStoreView

-(id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if(self)
    {
        [[NSNotificationCenter defaultCenter] removeObserver:self name:@"hideLoadingIcon" object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(hideLoadingIcon:) name:@"hideLoadingIcon" object:nil];
        [[NSNotificationCenter defaultCenter] removeObserver:self name:@"showSuccessView" object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(showSuccessView:) name:@"showSuccessView" object:nil];
        [[NSNotificationCenter defaultCenter] removeObserver:self name:@"reloadCashStoreView" object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reloadCashStoreView:) name:@"reloadCashStoreView" object:nil];
    }
    return self;
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

-(IBAction)closeView:(id)sender
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"hideLoadingIcon" object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"showSuccessView" object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"reloadCashStoreView" object:nil];
    [self removeFromSuperview];
}

-(IBAction)closeSuccessView:(id)sender
{
    self.successView.hidden = YES;
}

-(void)reloadCashStoreView:(NSNotification *)notification
{
    
    CGFloat offsetY = 0.f;
    CGFloat contentSizeWidth = 0.f;
    CGFloat contentSizeHeight = 0.f;
    if(sharedCashStoreManager.products)
    {
        for (SKProduct *product in sharedCashStoreManager.products)
        {
            NSArray *xibArray = [[NSBundle mainBundle] loadNibNamed:@"CashStoreItemView" owner:nil options:nil];
            CashStoreItemView *item = [xibArray objectAtIndex:0];
            item.identifier = product.productIdentifier;
            [item.itemName setText:product.localizedTitle];
            [item.itemComment setText:product.localizedDescription];
            
            NSNumberFormatter *numberFormatter = [[NSNumberFormatter alloc] init];
            [numberFormatter setFormatterBehavior:NSNumberFormatterBehavior10_4];
            [numberFormatter setNumberStyle:NSNumberFormatterCurrencyStyle];
            [numberFormatter setLocale:product.priceLocale];
            NSString *formattedPrice = [numberFormatter stringFromNumber:product.price];
            
            [item.itemCash setText:formattedPrice];
            [_scroller addSubview:item];
            item.backgroundColor = nil;
            item.frame = CGRectMake(0.f, offsetY, item.frame.size.width, item.frame.size.height);
            offsetY = offsetY + item.frame.size.height;
            contentSizeHeight = contentSizeHeight + item.frame.size.height;
            contentSizeWidth = item.frame.size.width;
        }
    }
    _scroller.contentSize = CGSizeMake(contentSizeWidth, contentSizeHeight);
}

-(void)hideLoadingIcon:(NSNotification *)notification
{
    self.loadingView.hidden = YES;
}

-(void)showSuccessView:(NSNotification *)notification
{
    NSString *content = (NSString *)[notification object];
    self.successView.hidden = NO;
    [self.lblMessage setText:content];
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
