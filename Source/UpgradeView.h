//
//  UpgradeView.h
//  bacterial
//
//  Created by 李翌文 on 14-7-6.
//  Copyright (c) 2014年 Apportable. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UpgradeView : UIView

@property (nonatomic, retain) IBOutlet UIScrollView *scroller;
@property (nonatomic, retain) IBOutlet UILabel *lblMessage;
@property (nonatomic, retain) IBOutlet UIView *messageView;

-(IBAction)closeView:(id)sender;
-(IBAction)closeMessage:(id)sender;

@end
