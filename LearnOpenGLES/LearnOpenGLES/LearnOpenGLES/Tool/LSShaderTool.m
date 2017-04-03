//
//  LSShaderTool.m
//  LearnOpenGLES
//
//  Created by zsr on 2017/3/25.
//  Copyright © 2017年 Lpzsrong Inc. All rights reserved.
//

#import "LSShaderTool.h"

@implementation LSShaderTool

+ (GLuint)getShaderWithVertexShaderFile:(NSString *)vShaderFile fragmentShaderFile:(NSString *)fShaderFile
{
    GLuint vertexShader = [self compileShader:vShaderFile withType:GL_VERTEX_SHADER];
    GLuint fragmentShader = [self compileShader:fShaderFile withType:GL_FRAGMENT_SHADER];
    
    GLuint programHandle = glCreateProgram();
    glAttachShader(programHandle, vertexShader);
    glAttachShader(programHandle, fragmentShader);
    
    glLinkProgram(programHandle);
    GLint linkSuccess;
    glGetProgramiv(programHandle, GL_LINK_STATUS, &linkSuccess);
    if(linkSuccess == GL_FALSE){
        GLchar message[256];
        glGetProgramInfoLog(programHandle, sizeof(message), 0, &message[0]);
        NSLog(@"Error at linking program message:%s", message);
        
    }
    glDeleteShader(vertexShader);
    glDeleteShader(fragmentShader);
    
    return programHandle;
}

+ (GLuint)compileShader:(NSString *)shaderName withType:(GLenum)shaderType
{
    NSString* type;
    if (shaderType == GL_VERTEX_SHADER) {
        type = @"vsh";
    }else{
        type = @"fsh";
    }
    NSString* shaderPath = [[NSBundle mainBundle] pathForResource:shaderName ofType:type];
    NSError* error;
    NSString* shaderString = [NSString stringWithContentsOfFile:shaderPath encoding:NSUTF8StringEncoding error:&error];
    if (!shaderString) {
        NSLog(@"Error loading shader: %@", error.localizedDescription);
    }
    
    const char * shaderStringUTF8 = [shaderString UTF8String];
//    int shaderStringLength = (int)[shaderString length];
    
    GLuint shaderHandle = glCreateShader(shaderType);
    glShaderSource(shaderHandle, 1, &shaderStringUTF8, NULL);//传NULL 为了GLSL添加中文注释
    glCompileShader(shaderHandle);
    GLint compileSuccess;
    glGetShaderiv(shaderHandle, GL_COMPILE_STATUS, &compileSuccess);
    if (compileSuccess == GL_FALSE) {
        GLchar message[256];
        glGetShaderInfoLog(shaderHandle, sizeof(message), 0, &message[0]);
        NSLog(@"Error at linking program message:%s", message);
    }
    return shaderHandle;
}
@end
