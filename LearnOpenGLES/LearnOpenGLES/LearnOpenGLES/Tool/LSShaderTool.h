//
//  LSShaderTool.h
//  LearnOpenGLES
//
//  Created by zsr on 2017/3/25.
//  Copyright © 2017年 Lpzsrong Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#include <OpenGLES/ES3/gl.h>

@interface LSShaderTool : NSObject
/**
 *创建一个着色器程序
 */
+ (GLuint)getShaderWithVertexShaderFile:(NSString *)vShaderFile fragmentShaderFile:(NSString *)fShaderFile;

@end
