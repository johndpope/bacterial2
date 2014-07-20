//
//  CashStoreView.h
//  bacterial
//
//  Created by 李翌文 on 14-7-1.
//  Copyright (c) 2014年 Apportable. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CashStoreView : UIView

@property (nonatomic, strong) IBOutlet UIButton *btnClose;
@property (nonatomic, strong) IBOutlet UIScrollView *scroller;
@property (nonatomic, strong) IBOutlet UIView *loadingView;
@property (nonatomic, strong) IBOutlet UIView *successView;
@property (nonatomic, strong) IBOutlet UILabel *lblMessage;

-(IBAction)closeView:(id)sender;
-(IBAction)closeSuccessView:(id)sender;
-(void)reloadCashStoreView:(NSNotification *)notification;
-(void)hideLoadingIcon:(NSNotification *)notification;
-(void)showSuccessView:(NSNotification *)notification;

@end
