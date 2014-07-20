//
//  Guide.m
//  bacterial
//
//  Created by 李翌文 on 14-7-13.
//  Copyright (c) 2014年 Apportable. All rights reserved.
//

#import "define.h"
#import "Guide.h"
#import "DataStorageManager.h"

@implementation Guide
{
    BOOL isR4;
    CCNode *container;
    CCSprite *btnContinue;
    CCSprite *imgStep;
    CCSprite *arrow;
    CCSprite *mask;
}

-(void)didLoadFromCCB
{
    self.userInteractionEnabled = YES;
    isR4 = iPhone5;
    arrow = [CCSprite node];
    [self addChild:arrow];
    arrow.spriteFrame = [CCSpriteFrame frameWithImageNamed:@"resources/guide_arrow.png"];
    arrow.visible = NO;
    container.cascadeOpacityEnabled = YES;
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"guideRevolutionDone" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didBacterialRevolution) name:@"guideRevolutionDone" object:nil];
}

-(void)didBacterialRevolution
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"guideRevolutionDone" object:nil];
    self.step++;
}

-(void)touchBegan:(UITouch *)touch withEvent:(UIEvent *)event
{
    if (_step == 1)
    {
        //进入第二步，介绍不同的细菌
        self.step++;
    }
    else if (_step == 2)
    {
        //进入第三步，首先生成生物质
        self.step++;
    }
    else if (_step == 3)
    {
        //准备进入第四步，判断是否点击了生成生物质的按钮
        CGPoint position = touch.locationInWorld;
        if(isR4)
        {
            if (position.x > 160 && position.x < 310 &&
                position.y > 422 && position.y < 452)
            {
                [[NSNotificationCenter defaultCenter] postNotificationName:@"guideClickBiomass" object:nil];
            }
        }
        else
        {
            if (position.x > 160 && position.x < 310 &&
                position.y > 410 && position.y < 440)
            {
                [[NSNotificationCenter defaultCenter] postNotificationName:@"guideClickBiomass" object:nil];
            }
        }
    }
    else if (_step == 4)
    {
        //准备进入第五步，判断是否点击了生成生物酶的按钮
        CGPoint position = touch.locationInWorld;
        if(isR4)
        {
            if (position.x > 10 && position.x < 290 &&
                position.y > 422 && position.y < 452)
            {
                [[NSNotificationCenter defaultCenter] postNotificationName:@"guideClickScore" object:nil];
            }
        }
        else
        {
            if (position.x > 10 && position.x < 290 &&
                position.y > 410 && position.y < 440)
            {
                [[NSNotificationCenter defaultCenter] postNotificationName:@"guideClickScore" object:nil];
            }
        }
    }
    else if (_step == 5)
    {
        //准备进入第六步，判断是否点击了放置红色细菌的按钮
        CGPoint position = touch.locationInWorld;
        if(isR4)
        {
            if (position.x > 88 && position.x < 149 &&
                position.y > 326 && position.y < 387)
            {
                [[NSNotificationCenter defaultCenter] postNotificationName:@"guideClickEnemy" object:nil];
            }
        }
        else
        {
            if (position.x > 88 && position.x < 149 &&
                position.y > 319 && position.y < 380)
            {
                [[NSNotificationCenter defaultCenter] postNotificationName:@"guideClickEnemy" object:nil];
            }
        }
    }
    else if (_step == 6)
    {
        //准备进入第七步，判断是否点击了放置褐色细菌的按钮
        CGPoint position = touch.locationInWorld;
        if(isR4)
        {
            if (position.x > 6 && position.x < 67 &&
                position.y > 326 && position.y < 387)
            {
                [[NSNotificationCenter defaultCenter] postNotificationName:@"guideClickBacterial" object:nil];
            }
        }
        else
        {
            if (position.x > 6 && position.x < 67 &&
                position.y > 319 && position.y < 380)
            {
                [[NSNotificationCenter defaultCenter] postNotificationName:@"guideClickBacterial" object:nil];
            }
        }
    }
    else if (_step == 7)
    {
        self.step++;
    }
    else if (_step == 8)
    {
        //准备进入第八步，判断是否点击了生成生物质的按钮/生成生物酶的按钮/放置红色细菌的按钮
        CGPoint position = touch.locationInWorld;
        if (isR4)
        {
            if (position.x > 160 && position.x < 310 &&
                position.y > 422 && position.y < 452)
            {
                [[NSNotificationCenter defaultCenter] postNotificationName:@"guideClickBiomass2" object:nil];
            }
            else if (position.x > 10 && position.x < 290 &&
                     position.y > 422 && position.y < 452)
            {
                [[NSNotificationCenter defaultCenter] postNotificationName:@"guideClickScore2" object:nil];
            }
            else if (position.x > 88 && position.x < 149 &&
                     position.y > 326 && position.y < 387)
            {
                [[NSNotificationCenter defaultCenter] postNotificationName:@"guideClickEnemy2" object:nil];
            }
        }
        else
        {
            if (position.x > 160 && position.x < 310 &&
                position.y > 410 && position.y < 440)
            {
                [[NSNotificationCenter defaultCenter] postNotificationName:@"guideClickBiomass2" object:nil];
            }
            else if (position.x > 10 && position.x < 290 &&
                position.y > 410 && position.y < 440)
            {
                [[NSNotificationCenter defaultCenter] postNotificationName:@"guideClickScore2" object:nil];
            }
            else if (position.x > 88 && position.x < 149 &&
                     position.y > 319 && position.y < 380)
            {
                [[NSNotificationCenter defaultCenter] postNotificationName:@"guideClickEnemy2" object:nil];
            }
        }
    }
    else if (_step == 9)
    {
        //准备进入第九步，判断是否点击了生成生物质的按钮/生成生物酶的按钮/放置红色细菌的按钮/放置褐色细菌的按钮
        CGPoint position = touch.locationInWorld;
        if(isR4)
        {
            if (position.x > 160 && position.x < 310 &&
                position.y > 422 && position.y < 452)
            {
                [[NSNotificationCenter defaultCenter] postNotificationName:@"guideClickBiomass2" object:nil];
            }
            else if (position.x > 10 && position.x < 290 &&
                     position.y > 422 && position.y < 452)
            {
                [[NSNotificationCenter defaultCenter] postNotificationName:@"guideClickScore2" object:nil];
            }
            else if (position.x > 6 && position.x < 67 &&
                     position.y > 326 && position.y < 387)
            {
                [[NSNotificationCenter defaultCenter] postNotificationName:@"guideClickBacterial2" object:nil];
            }
        }
        else
        {
            if (position.x > 160 && position.x < 310 &&
                position.y > 410 && position.y < 440)
            {
                [[NSNotificationCenter defaultCenter] postNotificationName:@"guideClickBiomass2" object:nil];
            }
            else if (position.x > 10 && position.x < 290 &&
                position.y > 410 && position.y < 440)
            {
                [[NSNotificationCenter defaultCenter] postNotificationName:@"guideClickScore2" object:nil];
            }
            else if (position.x > 6 && position.x < 67 &&
                     position.y > 319 && position.y < 380)
            {
                [[NSNotificationCenter defaultCenter] postNotificationName:@"guideClickBacterial2" object:nil];
            }
        }
    }
    else if (_step == 10)
    {
        [[NSNotificationCenter defaultCenter] postNotificationName:@"guideTouchBacterial" object:touch];
    }
    else if (_step == 11)
    {
        self.step++;
    }
    else if (_step == 12)
    {
        self.step++;
    }
    else if (_step == 13)
    {
        self.step++;
    }
    else if (_step == 14)
    {
        self.step++;
    }
    else if (_step == 15)
    {
        self.step++;
    }
    else if (_step == 16)
    {
        self.step++;
    }
    else if (_step == 17)
    {
        [DataStorageManager sharedDataStorageManager].guide = NO;
        [[NSNotificationCenter defaultCenter] postNotificationName:@"guideFinish" object:nil];
    }
    [DataStorageManager sharedDataStorageManager].guideStep = _step;
    [[DataStorageManager sharedDataStorageManager] saveData];
}

-(void)touchEnded:(UITouch *)touch withEvent:(UIEvent *)event
{
    if(_step == 10)
    {
        [[NSNotificationCenter defaultCenter] postNotificationName:@"guideTouchBacterialEnd" object:touch];
    }
}

-(void)setStep:(int)step
{
    step = fmax(1, step);
    _step = step;
    
    imgStep.spriteFrame = [CCSpriteFrame frameWithImageNamed:[NSString stringWithFormat:@"resources/guide_step%i.png", _step]];
    if (_step == 2)
    {
        container.position = ccp(13.f, 103.f);
    }
    else if(_step == 3)
    {
        btnContinue.visible = NO;
        arrow.visible = YES;
        if(isR4)
        {
            arrow.position = ccp(240.f, 423.f);
        }
        else
        {
            arrow.position = ccp(240.f, 410.f);
        }
        container.position = ccp(13.f, 103.f);
        mask.visible = NO;
    }
    else if(_step == 4)
    {
        btnContinue.visible = NO;
        arrow.visible = YES;
        if(isR4)
        {
            arrow.position = ccp(80.f, 423.f);
        }
        else
        {
            arrow.position = ccp(80.f, 410.f);
        }
        container.position = ccp(13.f, 103.f);
        mask.visible = NO;
    }
    else if(_step == 5)
    {
        //干得好，下面我们首先要放置红色的产生生物质的细菌，这会消耗20单位的生物酶
        btnContinue.visible = NO;
        arrow.spriteFrame = [CCSpriteFrame frameWithImageNamed:@"resources/guide_circle.png"];
        container.opacity = 0.6f;
        arrow.visible = YES;
        if(isR4)
        {
            arrow.position = ccp(118.f, 360.f);
        }
        else
        {
            arrow.position = ccp(118.f, 347.f);
        }
        container.position = ccp(13.f, 103.f);
        mask.visible = NO;
    }
    else if(_step == 6)
    {
        //下面我们来放置褐色的产生生物酶的细菌，这会消耗10单位的生物酶
        btnContinue.visible = NO;
        arrow.spriteFrame = [CCSpriteFrame frameWithImageNamed:@"resources/guide_circle.png"];
        container.opacity = 0.6f;
        arrow.visible = YES;
        if(isR4)
        {
            arrow.position = ccp(41.f, 360.f);
        }
        else
        {
            arrow.position = ccp(41.f, 347.f);
        }
        container.position = ccp(13.f, 103.f);
        mask.visible = NO;
    }
    else if(_step == 7)
    {
        btnContinue.visible = YES;
        arrow.visible = NO;
        container.position = ccp(13.f, 103.f);
        container.opacity = 1.f;
        mask.visible = YES;
    }
    else if(_step == 8)
    {
        //Cool 下面让我们来做更多的事情，首先再放置两个更多的红色细菌，如果生物酶不够那就想想我们第一步做了什么
        btnContinue.visible = NO;
        arrow.visible = NO;
        container.position = ccp(13.f, 103.f);
        container.opacity = 0.6f;
        mask.visible = NO;
    }
    else if(_step == 9)
    {
        //好了吧？再放置两个更多的褐色细菌，如果生物酶不够那就想想我们第一步做了什么
        btnContinue.visible = NO;
        arrow.visible = NO;
        container.position = ccp(13.f, 103.f);
        container.opacity = 0.6f;
        mask.visible = NO;
    }
    else if(_step == 10)
    {
        //好了？唔，看来你并不需要我的帮助，好了，下面用你灵巧的手指移动褐色细菌，让任意细菌周围存在2个或以上的相同等级细菌，像那样
        btnContinue.visible = NO;
        arrow.visible = NO;
        if(isR4)
        {
            container.position = ccp(13.f, 363.f);
        }
        else
        {
            container.position = ccp(13.f, 293.f);
        }
        container.opacity = .8f;
        mask.visible = NO;
    }
    else if(_step == 11)
    {
        //看见了吗？只要任意细菌周围存在2个或以上相同等级的细菌，他就会进化，这包括褐色和红色的细菌
        btnContinue.visible = YES;
        arrow.visible = NO;
        mask.visible = YES;
        container.position = ccp(13.f, 103.f);
    }
    else if(_step == 12)
    {
        //这里有个关键问题，红色细菌会攻击褐色细菌，当被进化的目标是褐色细菌，如果周围存在红色细菌，那么进化后细菌会被消灭
        btnContinue.visible = YES;
        arrow.visible = NO;
        mask.visible = YES;
        container.position = ccp(13.f, 103.f);
    }
    else if(_step == 13)
    {
        //当被进化的目标是红色细菌，只要周围存在2个以上相同等级(不论颜色)的细菌，他就会进化
        btnContinue.visible = YES;
        arrow.visible = NO;
        mask.visible = YES;
        container.position = ccp(13.f, 103.f);
    }
    else if(_step == 14)
    {
        //明白了吧？褐色与红色的细菌彼此对立又缺一不可。还有一点，红色细菌是无法移动的！
        btnContinue.visible = YES;
        arrow.visible = NO;
        mask.visible = YES;
        container.position = ccp(13.f, 103.f);
    }
    else if(_step == 15)
    {
        //你需要合理移动褐色细菌，来进化更多高等级的褐色细菌，以提高生物酶的生产效率，这个才是你的终极目标！
        arrow.visible = NO;
        btnContinue.visible = YES;
        mask.visible = YES;
        container.position = ccp(13.f, 103.f);
    }
    else if(_step == 16)
    {
        //最后一件事，看见这个瓶子了吗？这是激素，拖动这个到下面的方格子中会在1分钟之内提升100%生物酶的生产效率！
        arrow.spriteFrame = [CCSpriteFrame frameWithImageNamed:@"resources/guide_circle.png"];
        arrow.visible = YES;
        btnContinue.visible = YES;
        mask.visible = YES;
        if(isR4)
        {
            arrow.position = ccp(200.f, 360.f);
        }
        else
        {
            arrow.position = ccp(200.f, 347.f);
        }
        container.position = ccp(13.f, 103.f);
    }
    else if(_step == 17)
    {
        //好了，就到这儿，我先把你的试验结果清理掉，你可以自己重新开始了，祝你好运！
        arrow.visible = NO;
        btnContinue.visible = YES;
        mask.visible = YES;
        container.position = ccp(13.f, 103.f);
    }
}

@end
