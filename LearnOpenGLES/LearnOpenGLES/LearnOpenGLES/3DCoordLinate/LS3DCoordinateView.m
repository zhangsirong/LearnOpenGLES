//
//  LS3DCoordinateView.m
//  LearnOpenGLES
//
//  Created by zsr on 2017/3/26.
//  Copyright © 2017年 Lpzsrong Inc. All rights reserved.
//

#import "LS3DCoordinateView.h"
#import <QuartzCore/QuartzCore.h>
#import <OpenGLES/ES2/gl.h>
#import <OpenGLES/ES2/glext.h>
#import "LSShaderTool.h"
#import <GLKit/GLKMath.h>

@interface LS3DCoordinateView ()
{
    CAEAGLLayer *_eaglLayer;
    EAGLContext *_context;
    GLuint _colorRenderBuffer;
    
    GLuint _shaderProgram;
}

@end

@implementation LS3DCoordinateView

+ (Class)layerClass
{
    return [CAEAGLLayer class];
}

- (instancetype)initWithFrame:(CGRect)frame
{
    if(self = [super initWithFrame:frame]){
        _eaglLayer = (CAEAGLLayer *) self.layer;
        _eaglLayer.opaque = YES;
        
        _context = [[EAGLContext alloc] initWithAPI:kEAGLRenderingAPIOpenGLES2];
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
        GLfloat vertices[] = {
            //     ---- 位置 ----       ---- 颜色 ----     - 纹理坐标 -
            0.5f,  0.5f, 0.0f,   1.0f, 0.0f, 0.0f,   1.0f, 1.0f,   // 右上
            0.5f, -0.5f, 0.0f,   0.0f, 1.0f, 0.0f,   1.0f, 0.0f,   // 右下
            -0.5f, -0.5f, 0.0f,   0.0f, 0.0f, 1.0f,   0.0f, 0.0f,   // 左下
            -0.5f,  0.5f, 0.0f,   1.0f, 1.0f, 0.0f,   0.0f, 1.0f    // 左上
        };
        
        GLuint indices[] = { // 注意索引从0开始!
            0, 1, 3, // 第一个三角形
            1, 2, 3  // 第二个三角形
        };
        
        //顶点缓冲
        GLuint vertexBuffer;
        glGenBuffers(1, &vertexBuffer);
        glBindBuffer(GL_ARRAY_BUFFER, vertexBuffer);
        glBufferData(GL_ARRAY_BUFFER, sizeof(vertices), vertices, GL_STATIC_DRAW);
        
        //索引
        GLuint EBO;
        glGenBuffers(1, &EBO);
        glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, EBO);
        glBufferData(GL_ELEMENT_ARRAY_BUFFER, sizeof(indices), indices, GL_STATIC_DRAW);
        
        
        
        
        //着色器程序
        _shaderProgram = [LSShaderTool getShaderWithVertexShaderFile:@"3DCoordinate" fragmentShaderFile:@"3DCoordinate"];
        
        //以左下角为原点
        glViewport(0, (self.bounds.size.height - self.bounds.size.width) * 0.5, self.bounds.size.width, self.bounds.size.width);
        
        glUseProgram(_shaderProgram);
        
        // 位置属性
        GLuint positionSlot = glGetAttribLocation(_shaderProgram, [@"position" UTF8String]);
        glVertexAttribPointer(positionSlot, 3, GL_FLOAT, GL_FALSE, 8 * sizeof(GLfloat), (GLvoid*)0);
        glEnableVertexAttribArray(positionSlot);
        
        // 颜色属性
        GLuint colorSlot = glGetAttribLocation(_shaderProgram, [@"sourceColor" UTF8String]);
        glVertexAttribPointer(colorSlot, 3, GL_FLOAT, GL_FALSE, 8 * sizeof(GLfloat), (GLvoid*)(3 * sizeof(GLfloat)));
        glEnableVertexAttribArray(colorSlot);
        
        // 纹理坐标属性
        GLuint texSlot = glGetAttribLocation(_shaderProgram, [@"texCoord" UTF8String]);
        glVertexAttribPointer(texSlot, 2, GL_FLOAT, GL_FALSE, 8 * sizeof(GLfloat), (GLvoid*)(6 * sizeof(GLfloat)));
        glEnableVertexAttribArray(texSlot);
        
        // 加载纹理第一个纹理
        CGImageRef spriteImage = [UIImage imageNamed:@"container.jpg"].CGImage;
        size_t width = CGImageGetWidth(spriteImage);
        size_t height = CGImageGetHeight(spriteImage);
        GLubyte *spriteData = (GLubyte *) calloc(width*height *4, sizeof(GLubyte));
        CGContextRef spriteContext = CGBitmapContextCreate(spriteData, width, height, 8, width*4, CGImageGetColorSpace(spriteImage), kCGImageAlphaPremultipliedLast);
        CGContextDrawImage(spriteContext, CGRectMake(0, 0, width, height), spriteImage);
        CGContextRelease(spriteContext);
        
        GLuint texture1;
        glGenTextures(1, &texture1);
        glActiveTexture(GL_TEXTURE0);
        glBindTexture(GL_TEXTURE_2D, texture1);
        glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR);
        glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR);
        glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_CLAMP_TO_EDGE);
        glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_CLAMP_TO_EDGE);
        glTexImage2D(GL_TEXTURE_2D, 0, GL_RGBA, (GLsizei)width, (GLsizei)height, 0, GL_RGBA, GL_UNSIGNED_BYTE, spriteData);
        glBindTexture(GL_TEXTURE_2D, 0);
        free(spriteData);
        
        
        // 加载纹理第二个纹理
        CGImageRef spriteImage2 = [UIImage imageNamed:@"awesomeface.png"].CGImage;
        size_t width2 = CGImageGetWidth(spriteImage2);
        size_t height2 = CGImageGetHeight(spriteImage2);
        GLubyte *spriteData2 = (GLubyte *) calloc(width2 * height2 * 4, sizeof(GLubyte));
        CGContextRef spriteContext2 = CGBitmapContextCreate(spriteData2, width2, height2, 8, width2*4, CGImageGetColorSpace(spriteImage2), kCGImageAlphaPremultipliedLast);
        CGContextDrawImage(spriteContext2, CGRectMake(0, 0, width2, height2), spriteImage2);
        CGContextRelease(spriteContext2);
        
        GLuint texture2;
        glGenTextures(1, &texture2);
        glActiveTexture(GL_TEXTURE1);
        glBindTexture(GL_TEXTURE_2D, texture2);
        glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR);
        glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR);
        glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_CLAMP_TO_EDGE);
        glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_CLAMP_TO_EDGE);
        glTexImage2D(GL_TEXTURE_2D, 0, GL_RGBA, (GLsizei)width2, (GLsizei)height2, 0, GL_RGBA, GL_UNSIGNED_BYTE, spriteData2);
        glBindTexture(GL_TEXTURE_2D, 0);
        free(spriteData2);
        
        
        //激活绑定第一个纹理
        glActiveTexture(GL_TEXTURE0);
        glBindTexture(GL_TEXTURE_2D, texture1);
        glUniform1i(glGetUniformLocation(_shaderProgram, "ourTexture1"), 0);
        
        //激活绑定第二个纹理
        glActiveTexture(GL_TEXTURE1);
        glBindTexture(GL_TEXTURE_2D, texture2);
        glUniform1i(glGetUniformLocation(_shaderProgram, "ourTexture2"), 1);
    }
    return self;
}

- (void)render:(CADisplayLink *)displayLink
{
    glClearColor(0.2f, 0.3f, 0.3f, 1.0f);
    glClear(GL_COLOR_BUFFER_BIT);
    
    NSLog(@"%f",displayLink.timestamp);
    
    //https://learnopengl-cn.github.io/01%20Getting%20started/08%20Coordinate%20Systems/
    //利用GLKMath做矩阵矩阵变化
    
    GLKMatrix4 model = GLKMatrix4Identity;//模型矩阵
    GLKMatrix4 view = GLKMatrix4Identity;//观察矩阵
    GLKMatrix4 projection = GLKMatrix4Identity;//投影矩阵
    
    model = GLKMatrix4Rotate(model, -M_PI_4 , 1.0, 0.0, 0.0);
    view = GLKMatrix4Translate(view, 0.0, 0.0, -3.0);
    projection = GLKMatrix4MakePerspective(M_PI_4,self.bounds.size.width / self.bounds.size.width, 0.1, 100.0);

    GLint modelLocation = glGetUniformLocation(_shaderProgram, [@"model" UTF8String]);
    GLint viewLocation = glGetUniformLocation(_shaderProgram, [@"view" UTF8String]);
    GLint projectionLocation = glGetUniformLocation(_shaderProgram, [@"projection" UTF8String]);

    glUniformMatrix4fv(modelLocation, 1, GL_FALSE, model.m);
    glUniformMatrix4fv(viewLocation, 1, GL_FALSE, view.m);
    glUniformMatrix4fv(projectionLocation, 1, GL_FALSE, projection.m);

    
    glDrawElements(GL_TRIANGLES, 6, GL_UNSIGNED_INT, 0);
    
    [_context presentRenderbuffer:GL_RENDERBUFFER];
}

- (void)dealloc
{
    if (_shaderProgram) {
        glDeleteProgram(_shaderProgram);
    }
    
    if ([EAGLContext currentContext] == _context) {
        [EAGLContext setCurrentContext:nil];
    }
}



@end
