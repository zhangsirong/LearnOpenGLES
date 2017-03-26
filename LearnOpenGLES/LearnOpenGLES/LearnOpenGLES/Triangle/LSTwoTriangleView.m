//
//  LSTwoTriangleView.m
//  LearnOpenGLES
//
//  Created by zsr on 2017/3/25.
//  Copyright © 2017年 Lpzsrong Inc. All rights reserved.
//

#import "LSTwoTriangleView.h"
#import <QuartzCore/QuartzCore.h>
#import <OpenGLES/ES3/gl.h>
#import <OpenGLES/ES3/glext.h>
#import "LSShaderTool.h"

@interface LSTwoTriangleView ()
{
    CAEAGLLayer *_eaglLayer;
    EAGLContext *_context;
    GLuint _colorRenderBuffer;
}

@end

@implementation LSTwoTriangleView

+ (Class)layerClass
{
    return [CAEAGLLayer class];
}

- (instancetype)initWithFrame:(CGRect)frame
{
    if(self = [super initWithFrame:frame]){
        _eaglLayer = (CAEAGLLayer *) self.layer;
        _eaglLayer.opaque = YES;
        
        _context = [[EAGLContext alloc] initWithAPI:kEAGLRenderingAPIOpenGLES3];//只有ES3才支持顶点数组对象VAO
        [EAGLContext setCurrentContext:_context];
        
        //渲染缓冲
        glGenRenderbuffers(1, &_colorRenderBuffer);
        glBindRenderbuffer(GL_RENDERBUFFER, _colorRenderBuffer);
        [_context renderbufferStorage:GL_RENDERBUFFER fromDrawable:_eaglLayer];
        
        //帧缓冲，包含了渲染缓冲，还有其他缓冲，如深度、模版
        GLuint framebuffer;
        glGenFramebuffers(1, &framebuffer);
        glBindFramebuffer(GL_FRAMEBUFFER, framebuffer);
        glFramebufferRenderbuffer(GL_FRAMEBUFFER, GL_COLOR_ATTACHMENT0, GL_RENDERBUFFER, _colorRenderBuffer);
        
        //顶点数组
        GLfloat firstTriangle[] = {
            -0.9f, -0.5f, 0.0f,
            -0.0f, -0.5f, 0.0f,
            -0.45f, 0.5f, 0.0f,
        };
        GLfloat secondTriangle[] = {
            0.0f, -0.5f, 0.0f,
            0.9f, -0.5f, 0.0f,
            0.45f, 0.5f, 0.0f
        };
        
        //顶点缓冲 ES3才有VAO
        GLuint VBOs[2];
        GLuint VAOs[2];
        glGenVertexArrays(2, VAOs);
        glGenBuffers(2, VBOs);

        //第一个三角形
        glBindVertexArray(VAOs[0]);
        glBindBuffer(GL_ARRAY_BUFFER, VBOs[0]);
        glBufferData(GL_ARRAY_BUFFER, sizeof(firstTriangle), firstTriangle, GL_STATIC_DRAW);
        glVertexAttribPointer(0, 3, GL_FLOAT, GL_FALSE, 3 * sizeof(GLfloat), (GLvoid*)0);
        glEnableVertexAttribArray(0);
        glBindVertexArray(0);
        
        //第二个三角形
        glBindVertexArray(VAOs[1]);
        glBindBuffer(GL_ARRAY_BUFFER, VBOs[1]);
        glBufferData(GL_ARRAY_BUFFER, sizeof(secondTriangle), secondTriangle, GL_STATIC_DRAW);
        glVertexAttribPointer(0, 3, GL_FLOAT, GL_FALSE, 0, (GLvoid*)0);
        glEnableVertexAttribArray(0);
        glBindVertexArray(0);
        
        //着色器程序
        GLuint shaderProgram1 = [LSShaderTool getShaderWithVertexShaderFile:@"Triangle" fragmentShaderFile:@"Triangle"];
        GLuint shaderProgram2 = [LSShaderTool getShaderWithVertexShaderFile:@"Triangle" fragmentShaderFile:@"Triangle2"];
        
        glClearColor(0, 104.0/255.0, 55.0/255.0, 1.0);
        glClear(GL_COLOR_BUFFER_BIT);
        glViewport(0, 0, self.frame.size.width, self.frame.size.height);

        //画第一个三角形
        glUseProgram(shaderProgram1);
        glBindVertexArray(VAOs[0]);
        glDrawArrays(GL_LINE_LOOP, 0, 3);//线框模式
//        glDrawArrays(GL_TRIANGLES, 0, 3);
        
        //画第二个三角形
        glUseProgram(shaderProgram2);
        glBindVertexArray(VAOs[1]);
        glDrawArrays(GL_TRIANGLES, 0, 3);
        
        glBindVertexArray(0);

        [_context presentRenderbuffer:GL_RENDERBUFFER];
    }
    return self;
}

@end
