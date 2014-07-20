//
//  UpgradeItemView.h
//  bacterial
//
//  Created by 李翌文 on 14-7-6.
//  Copyright (c) 2014年 Apportable. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UpgradeItemView : UIView

@property (nonatomic, retain) NSString *upgradeId;
@property (nonatomic, retain) IBOutlet UILabel *lblName;
@property (nonatomic, retain) IBOutlet UILabel *lblComment;
@property (nonatomic, retain) IBOutlet UILabel *lblNextComment;
@property (nonatomic, retain) IBOutlet UILabel *lblNextCost;
@property (nonatomic, retain) IBOutlet UILabel *lblNextRate;
@property (nonatomic, retain) IBOutlet UIButton *btnUpgrade;
@property (nonatomic, retain) IBOutlet UIImageView *imgStatus;
@property (nonatomic, retain) IBOutlet UIImageView *imgLevel;

-(IBAction)btnUpgradeTouch:(id)sender;
-(void)updateItemViewByUpgradeId:(NSString *)upgradeId level:(int)level;

@end
