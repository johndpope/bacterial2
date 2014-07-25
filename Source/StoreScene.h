//
//  StoreScene.h
//  bacterial2
//
//  Created by 李翌文 on 14-7-24.
//  Copyright (c) 2014年 Apportable. All rights reserved.
//

#import "CCNode.h"

@interface StoreScene : CCNode

-(void)showLoadingIcon:(NSNotification *)notification;
-(void)hideLoadingIcon:(NSNotification *)notification;
-(void)showSuccessView:(NSNotification *)notification;

@end
