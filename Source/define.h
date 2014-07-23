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

#define MAXLEVEL 21
#define BACTERIAL_BASIC_SCORE 5
#define ENEMY_BASIC_EXP 20
#define ENEMY_EVOLUTION_BASIC_TIME 20.f
#define ENEMY_EVOLUTION_MAX_TIME 60.f
#define BECTERIAL_MESSAGE @"Becterial.BecterialTouched"

#endif
