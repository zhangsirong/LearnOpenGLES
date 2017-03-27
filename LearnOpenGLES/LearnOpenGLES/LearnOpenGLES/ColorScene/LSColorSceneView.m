//
//  LSColorSceneView.m
//  LearnOpenGLES
//
//  Created by zsr on 2017/3/27.
//  Copyright © 2017年 Lpzsrong Inc. All rights reserved.
//

#import "LSColorSceneView.h"
#import <QuartzCore/QuartzCore.h>
#import <OpenGLES/ES3/gl.h>
#import <OpenGLES/ES3/glext.h>
#import "LSShaderTool.h"
#import <GLKit/GLKMath.h>

@interface LSColorSceneView ()
{
    CAEAGLLayer *_eaglLayer;
    EAGLContext *_context;
    GLuint _colorRenderBuffer;
    GLuint _depthRenderBuffer;
    
    GLuint _shaderProgram;
    GLuint _lampShaderProgram;
    
    GLuint _lightVAO;
    GLuint _containerVAO;
}

@end

@implementation LSColorSceneView

+ (Class)layerClass
{
    return [CAEAGLLayer class];
}

- (instancetype)initWithFrame:(CGRect)frame
{
    if(self = [super initWithFrame:frame]){
        _eaglLayer = (CAEAGLLayer *) self.layer;
        _eaglLayer.opaque = YES;
        
        _context = [[EAGLContext alloc] initWithAPI:kEAGLRenderingAPIOpenGLES3];
        [EAGLContext setCurrentContext:_context];
        
        //深度缓冲 要写在渲染缓冲前面
        glGenRenderbuffers(1, &_depthRenderBuffer);
        glBindRenderbuffer(GL_RENDERBUFFER, _depthRenderBuffer);
        glRenderbufferStorage(GL_RENDERBUFFER, GL_DEPTH_COMPONENT16, self.bounds.size.width, self.bounds.size.height);
        
        //渲染缓冲
        glGenRenderbuffers(1, &_colorRenderBuffer);
        glBindRenderbuffer(GL_RENDERBUFFER, _colorRenderBuffer);
        [_context renderbufferStorage:GL_RENDERBUFFER fromDrawable:_eaglLayer];
        
        //帧缓冲，包含了渲染缓冲，还有其他缓冲，如深度、模版
        GLuint framebuffer;
        glGenFramebuffers(1, &framebuffer);
        glBindFramebuffer(GL_FRAMEBUFFER, framebuffer);
        glFramebufferRenderbuffer(GL_FRAMEBUFFER, GL_COLOR_ATTACHMENT0, GL_RENDERBUFFER, _colorRenderBuffer);
        glFramebufferRenderbuffer(GL_FRAMEBUFFER, GL_DEPTH_ATTACHMENT, GL_RENDERBUFFER, _depthRenderBuffer);
        
        //开启深度测试
        glEnable(GL_DEPTH_TEST);
        
        //顶点数组
        GLfloat vertices[] = {
            -0.5f, -0.5f, -0.5f,
            0.5f, -0.5f, -0.5f,
            0.5f,  0.5f, -0.5f,
            0.5f,  0.5f, -0.5f,
            -0.5f,  0.5f, -0.5f,
            -0.5f, -0.5f, -0.5f,
            
            -0.5f, -0.5f,  0.5f,
            0.5f, -0.5f,  0.5f,
            0.5f,  0.5f,  0.5f,
            0.5f,  0.5f,  0.5f,
            -0.5f,  0.5f,  0.5f,
            -0.5f, -0.5f,  0.5f,
            
            -0.5f,  0.5f,  0.5f,
            -0.5f,  0.5f, -0.5f,
            -0.5f, -0.5f, -0.5f,
            -0.5f, -0.5f, -0.5f,
            -0.5f, -0.5f,  0.5f,
            -0.5f,  0.5f,  0.5f,
            
            0.5f,  0.5f,  0.5f,
            0.5f,  0.5f, -0.5f,
            0.5f, -0.5f, -0.5f,
            0.5f, -0.5f, -0.5f,
            0.5f, -0.5f,  0.5f,
            0.5f,  0.5f,  0.5f,
            
            -0.5f, -0.5f, -0.5f,
            0.5f, -0.5f, -0.5f,
            0.5f, -0.5f,  0.5f,
            0.5f, -0.5f,  0.5f,
            -0.5f, -0.5f,  0.5f,
            -0.5f, -0.5f, -0.5f,
            
            -0.5f,  0.5f, -0.5f,
            0.5f,  0.5f, -0.5f,
            0.5f,  0.5f,  0.5f,
            0.5f,  0.5f,  0.5f,
            -0.5f,  0.5f,  0.5f,
            -0.5f,  0.5f, -0.5f
        };
        
        //顶点缓冲
        GLuint VBO;
        glGenVertexArrays(1, &_containerVAO);
        glGenBuffers(1, &VBO);
        
        glBindBuffer(GL_ARRAY_BUFFER, VBO);
        glBufferData(GL_ARRAY_BUFFER, sizeof(vertices), vertices, GL_STATIC_DRAW);
        
        glBindVertexArray(_containerVAO);
        //位置属性
        glVertexAttribPointer(0, 3, GL_FLOAT, GL_FALSE, 3 * sizeof(GLfloat), (GLvoid*)0);
        glEnableVertexAttribArray(0);
        glBindVertexArray(0);
        
        glGenVertexArrays(1, &_lightVAO);
        glBindVertexArray(_lightVAO);
        glBindBuffer(GL_ARRAY_BUFFER, VBO);
        //设置灯立方体的顶点属性指针(仅设置灯的顶点数据)
        glVertexAttribPointer(0, 3, GL_FLOAT, GL_FALSE, 3 * sizeof(GLfloat), (GLvoid*)0);
        glEnableVertexAttribArray(0);
        glBindVertexArray(0);
        
        //着色器程序
        _shaderProgram = [LSShaderTool getShaderWithVertexShaderFile:@"ColorScene" fragmentShaderFile:@"ColorScene"];
        
        //灯的着色器程序
        _lampShaderProgram = [LSShaderTool getShaderWithVertexShaderFile:@"lamp" fragmentShaderFile:@"lamp"];
        
        glViewport(0, 0, self.bounds.size.width, self.bounds.size.height);
    }
    return self;
}

- (void)render:(CADisplayLink *)displayLink
{
    glClearColor(0.2f, 0.3f, 0.3f, 1.0f);
    glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);

    NSLog(@"%f",displayLink.timestamp);
    
    //https://learnopengl-cn.github.io/02%20Lighting/01%20Colors/
    glUseProgram(_shaderProgram);

    GLint objectColorLoc = glGetUniformLocation(_shaderProgram, "objectColor");
    GLint lightColorLoc  = glGetUniformLocation(_shaderProgram, "lightColor");
    glUniform3f(objectColorLoc, 1.0f, 0.5f, 0.31f);
    glUniform3f(lightColorLoc,  1.0f, 0.5f, 1.0f);
    
    //利用GLKMath做矩阵矩阵变化
    GLKMatrix4 model = GLKMatrix4Identity;//模型矩阵
    GLKMatrix4 view = GLKMatrix4Identity;//观察矩阵
    GLKMatrix4 projection = GLKMatrix4Identity;//投影矩阵
    
    model = GLKMatrix4Rotate(model, displayLink.timestamp * 2.0, 0.5, 1.0, 0.0);
    view = GLKMatrix4Translate(view, 0.0, 0.0, -7.0);
    projection = GLKMatrix4MakePerspective(M_PI_4,self.bounds.size.width / self.bounds.size.width, 0.1, 100.0);
    
    GLint modelLocation = glGetUniformLocation(_shaderProgram, [@"model" UTF8String]);
    GLint viewLocation = glGetUniformLocation(_shaderProgram, [@"view" UTF8String]);
    GLint projectionLocation = glGetUniformLocation(_shaderProgram, [@"projection" UTF8String]);
    
    glUniformMatrix4fv(modelLocation, 1, GL_FALSE, model.m);
    glUniformMatrix4fv(viewLocation, 1, GL_FALSE, view.m);
    glUniformMatrix4fv(projectionLocation, 1, GL_FALSE, projection.m);
    
    glBindVertexArray(_containerVAO);
    glDrawArrays(GL_TRIANGLES, 0, 36);
    glBindVertexArray(0);
    
    //灯的着色器
    glUseProgram(_lampShaderProgram);
    modelLocation = glGetUniformLocation(_lampShaderProgram, "model");
    viewLocation  = glGetUniformLocation(_lampShaderProgram, "view");
    projectionLocation  = glGetUniformLocation(_lampShaderProgram, "projection");

    
    glUniformMatrix4fv(modelLocation, 1, GL_FALSE, model.m);
    glUniformMatrix4fv(viewLocation, 1, GL_FALSE, view.m);
    glUniformMatrix4fv(projectionLocation, 1, GL_FALSE, projection.m);
    
    GLKVector3 lightPos = GLKVector3Make(1.2, 1.0, 2.0);
    model = GLKMatrix4Identity;
    model = GLKMatrix4TranslateWithVector3(model, lightPos);
    model = GLKMatrix4Scale(model, 0.2, 0.2, 0.2);
    
    glUniformMatrix4fv(modelLocation, 1, GL_FALSE, model.m);
    glBindVertexArray(_lightVAO);
    glDrawArrays(GL_TRIANGLES, 0, 36);
    glBindVertexArray(0);

    [_context presentRenderbuffer:GL_RENDERBUFFER];
}

- (void)dealloc
{
    if (_shaderProgram) {
        glDeleteProgram(_shaderProgram);
    }
    if (_lampShaderProgram) {
        glDeleteProgram(_lampShaderProgram);
    }
    
    if ([EAGLContext currentContext] == _context) {
        [EAGLContext setCurrentContext:nil];
    }
}

@end
