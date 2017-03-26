//
//  LSBaseDisplayLinkView.m
//  LearnOpenGLES
//
//  Created by zsr on 2017/3/26.
//  Copyright © 2017年 Lpzsrong Inc. All rights reserved.
//

#import "LSBaseDisplayLinkView.h"

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
