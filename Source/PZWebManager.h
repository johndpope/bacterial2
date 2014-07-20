//
//  PZWebManager.h
//  bacterial
//
//  Created by 李翌文 on 14-7-2.
//  Copyright (c) 2014年 Apportable. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface PZWebManager : NSObject
<NSURLConnectionDelegate>

+(PZWebManager *)sharedPZWebManager;
-(NSURLConnection *)asyncGetRequest:(NSString *)url withData:(NSDictionary *)data;
-(NSURLConnection *)asyncPostRequest:(NSString *)url withData:(NSDictionary *)data;

@end
