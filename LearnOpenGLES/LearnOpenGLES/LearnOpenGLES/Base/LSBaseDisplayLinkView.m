//
//  LSBaseDisplayLinkView.m
//  LearnOpenGLES
//
//  Created by zsr on 2017/3/26.
//  Copyright © 2017年 Lpzsrong Inc. All rights reserved.
//

#import "LSBaseDisplayLinkView.h"

const GLKVector3 cubePositions[] = {
    { 0.0f,  0.0f,  0.0  },
    { 2.0f,  5.0f, -15.0 },
    {-1.5f, -2.2f, -2.5  },
    {-3.8f, -2.0f, -12.3 },
    { 2.4f, -0.4f, -3.5  },
    {-1.7f,  3.0f, -7.5  },
    { 1.3f, -2.0f, -2.5  },
    { 1.5f,  2.0f, -2.5  },
    { 1.5f,  0.2f, -1.5  },
    {-1.3f,  1.0f, -1.5f }
};


@implementation LSBaseDisplayLinkView

+ (Class)layerClass
{
    return [CAEAGLLayer class];
}

- (instancetype)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        //运行循环
        self.displayLink = [CADisplayLink displayLinkWithTarget:self selector:@selector(render:)];
        [self.displayLink addToRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
    }
    return self;
}

- (void)render:(CADisplayLink *)displayLink
{
    
}

- (void)invalidate
{
    [self.displayLink invalidate];
}


@end
