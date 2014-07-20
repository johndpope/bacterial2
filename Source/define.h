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
#define BACTERIAL_BIOMASS 0.2f
#define BACTERIAL_SCORE 1.7f
#define ENEMY_BIOMASS 0.25f

#define NEW_BACTERIAL_COST 10
#define NEW_ENEMY_COST 20

#endif
