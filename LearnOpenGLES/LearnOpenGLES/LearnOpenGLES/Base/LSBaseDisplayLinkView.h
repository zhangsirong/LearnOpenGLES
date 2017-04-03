//
//  LSBaseDisplayLinkView.h
//  LearnOpenGLES
//
//  Created by zsr on 2017/3/26.
//  Copyright © 2017年 Lpzsrong Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <GLKit/GLKMath.h>

extern const GLKVector3 cubePositions[];

/**
 *需要定时器的继承这个类
 */
@interface LSBaseDisplayLinkView : UIView

@property (nonatomic,strong) CADisplayLink *displayLink;

- (void)invalidate;
- (void)render:(CADisplayLink *)displayLink;

@end
