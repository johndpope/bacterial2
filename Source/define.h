//
//  define.h
//  becterial
//
//  Created by 李翌文 on 14-6-24.
//  Copyright (c) 2014年 Apportable. All rights reserved.
//

#ifndef becterial_define_h
#define becterial_define_h

#define iPhone5 ([UIScreen instancesRespondToSelector:@selector(currentMode)] ? CGSizeEqualToSize(CGSizeMake(640, 1136), [[UIScreen mainScreen] currentMode].size) : NO)
//#define DEBUG_MODE

#define BECTERIAL_MESSAGE @"Becterial.BecterialTouched"

#endif
