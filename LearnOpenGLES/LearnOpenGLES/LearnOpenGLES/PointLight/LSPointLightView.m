//
//  LSPointLightView.m
//  LearnOpenGLES
//
//  Created by zsr on 2017/4/4.
//  Copyright © 2017年 Lpzsrong Inc. All rights reserved.
//

#import "LSPointLightView.h"
#import <QuartzCore/QuartzCore.h>
#import <OpenGLES/ES3/gl.h>
#import <OpenGLES/ES3/glext.h>
#import "LSShaderTool.h"
#import <GLKit/GLKMath.h>

@interface LSPointLightView ()
{
    CAEAGLLayer *_eaglLayer;
    EAGLContext *_context;
    GLuint _colorRenderBuffer;
    GLuint _depthRenderBuffer;
    
    GLuint _shaderProgram;
    GLuint _lampShaderProgram;
    
    GLuint _lightVAO;
    GLuint _containerVAO;
    
    GLuint _diffuseMap;//漫反射贴图
    GLuint _specularMap;//镜面贴图
    
    GLKVector3 cameraPos;
    GLKVector3 cameraFront;
    GLKVector3 cameraUp;
    
    CGFloat _beginX;
    CGFloat _beginY;
    
    GLfloat deltaTime;   // 当前帧与上一帧的时间差
    GLfloat lastFrame;   // 上一帧的时间
}

@end

@implementation LSPointLightView

+ (Class)layerClass
{
    return [CAEAGLLayer class];
}

- (instancetype)initWithFrame:(CGRect)frame
{
    if(self = [super initWithFrame:frame]){
        [self configData];
        [self addGesture];
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
        
        //以左下角为原点
        glViewport(0, (self.bounds.size.height - self.bounds.size.width) * 0.5, self.bounds.size.width, self.bounds.size.width);
        
        //顶点数组
        GLfloat vertices[] = {
            // ----位置--------    ------ 法线 -------  ----纹理----
            -0.5f, -0.5f, -0.5f,  0.0f,  0.0f, -1.0f,  0.0f, 0.0f,
            0.5f, -0.5f, -0.5f,  0.0f,  0.0f, -1.0f,  1.0f, 0.0f,
            0.5f,  0.5f, -0.5f,  0.0f,  0.0f, -1.0f,  1.0f, 1.0f,
            0.5f,  0.5f, -0.5f,  0.0f,  0.0f, -1.0f,  1.0f, 1.0f,
            -0.5f,  0.5f, -0.5f,  0.0f,  0.0f, -1.0f,  0.0f, 1.0f,
            -0.5f, -0.5f, -0.5f,  0.0f,  0.0f, -1.0f,  0.0f, 0.0f,
            
            -0.5f, -0.5f,  0.5f,  0.0f,  0.0f, 1.0f,   0.0f, 0.0f,
            0.5f, -0.5f,  0.5f,  0.0f,  0.0f, 1.0f,   1.0f, 0.0f,
            0.5f,  0.5f,  0.5f,  0.0f,  0.0f, 1.0f,   1.0f, 1.0f,
            0.5f,  0.5f,  0.5f,  0.0f,  0.0f, 1.0f,   1.0f, 1.0f,
            -0.5f,  0.5f,  0.5f,  0.0f,  0.0f, 1.0f,   0.0f, 1.0f,
            -0.5f, -0.5f,  0.5f,  0.0f,  0.0f, 1.0f,   0.0f, 0.0f,
            
            -0.5f,  0.5f,  0.5f, -1.0f,  0.0f,  0.0f,  1.0f, 0.0f,
            -0.5f,  0.5f, -0.5f, -1.0f,  0.0f,  0.0f,  1.0f, 1.0f,
            -0.5f, -0.5f, -0.5f, -1.0f,  0.0f,  0.0f,  0.0f, 1.0f,
            -0.5f, -0.5f, -0.5f, -1.0f,  0.0f,  0.0f,  0.0f, 1.0f,
            -0.5f, -0.5f,  0.5f, -1.0f,  0.0f,  0.0f,  0.0f, 0.0f,
            -0.5f,  0.5f,  0.5f, -1.0f,  0.0f,  0.0f,  1.0f, 0.0f,
            
            0.5f,  0.5f,  0.5f,  1.0f,  0.0f,  0.0f,  1.0f, 0.0f,
            0.5f,  0.5f, -0.5f,  1.0f,  0.0f,  0.0f,  1.0f, 1.0f,
            0.5f, -0.5f, -0.5f,  1.0f,  0.0f,  0.0f,  0.0f, 1.0f,
            0.5f, -0.5f, -0.5f,  1.0f,  0.0f,  0.0f,  0.0f, 1.0f,
            0.5f, -0.5f,  0.5f,  1.0f,  0.0f,  0.0f,  0.0f, 0.0f,
            0.5f,  0.5f,  0.5f,  1.0f,  0.0f,  0.0f,  1.0f, 0.0f,
            
            -0.5f, -0.5f, -0.5f,  0.0f, -1.0f,  0.0f,  0.0f, 1.0f,
            0.5f, -0.5f, -0.5f,  0.0f, -1.0f,  0.0f,  1.0f, 1.0f,
            0.5f, -0.5f,  0.5f,  0.0f, -1.0f,  0.0f,  1.0f, 0.0f,
            0.5f, -0.5f,  0.5f,  0.0f, -1.0f,  0.0f,  1.0f, 0.0f,
            -0.5f, -0.5f,  0.5f,  0.0f, -1.0f,  0.0f,  0.0f, 0.0f,
            -0.5f, -0.5f, -0.5f,  0.0f, -1.0f,  0.0f,  0.0f, 1.0f,
            
            -0.5f,  0.5f, -0.5f,  0.0f,  1.0f,  0.0f,  0.0f, 1.0f,
            0.5f,  0.5f, -0.5f,  0.0f,  1.0f,  0.0f,  1.0f, 1.0f,
            0.5f,  0.5f,  0.5f,  0.0f,  1.0f,  0.0f,  1.0f, 0.0f,
            0.5f,  0.5f,  0.5f,  0.0f,  1.0f,  0.0f,  1.0f, 0.0f,
            -0.5f,  0.5f,  0.5f,  0.0f,  1.0f,  0.0f,  0.0f, 0.0f,
            -0.5f,  0.5f, -0.5f,  0.0f,  1.0f,  0.0f,  0.0f, 1.0f
        };
        
        //着色器程序
        _shaderProgram = [LSShaderTool getShaderWithVertexShaderFile:@"PointLight" fragmentShaderFile:@"PointLight"];
        glUseProgram(_shaderProgram);
        
        //灯的着色器程序
        _lampShaderProgram = [LSShaderTool getShaderWithVertexShaderFile:@"lamp" fragmentShaderFile:@"lamp"];
        
        //顶点缓冲
        GLuint VBO;
        glGenVertexArrays(1, &_containerVAO);
        glGenBuffers(1, &VBO);
        
        glBindBuffer(GL_ARRAY_BUFFER, VBO);
        glBufferData(GL_ARRAY_BUFFER, sizeof(vertices), vertices, GL_STATIC_DRAW);
        
        glBindVertexArray(_containerVAO);
        //位置属性
        GLuint positionSlot = glGetAttribLocation(_shaderProgram, [@"position" UTF8String]);
        glVertexAttribPointer(positionSlot, 3, GL_FLOAT, GL_FALSE, 8 * sizeof(GLfloat), (GLvoid*)0);
        glEnableVertexAttribArray(positionSlot);
        
        //法线属性
        GLuint normalSlot = glGetAttribLocation(_shaderProgram, [@"normal" UTF8String]);
        glVertexAttribPointer(normalSlot, 3, GL_FLOAT, GL_FALSE, 8 * sizeof(GLfloat), (GLvoid*)(3 * sizeof(GLfloat)));
        glEnableVertexAttribArray(normalSlot);
        
        // 纹理坐标属性
        GLuint texSlot = glGetAttribLocation(_shaderProgram, [@"texCoords" UTF8String]);
        glVertexAttribPointer(texSlot, 2, GL_FLOAT, GL_FALSE, 8 * sizeof(GLfloat), (GLvoid*)(6 * sizeof(GLfloat)));
        glEnableVertexAttribArray(texSlot);
        glBindVertexArray(0);
        
        glGenVertexArrays(1, &_lightVAO);
        glBindVertexArray(_lightVAO);
        glBindBuffer(GL_ARRAY_BUFFER, VBO);
        //设置灯立方体的顶点属性指针(仅设置灯的顶点数据)
        glVertexAttribPointer(0, 3, GL_FLOAT, GL_FALSE, 8 * sizeof(GLfloat), (GLvoid*)0);
        glEnableVertexAttribArray(0);
        glBindVertexArray(0);
        
        // 加载纹理第一个纹理
        CGImageRef spriteImage = [UIImage imageNamed:@"container2.png"].CGImage;
        size_t width = CGImageGetWidth(spriteImage);
        size_t height = CGImageGetHeight(spriteImage);
        GLubyte *spriteData = (GLubyte *) calloc(width*height *4, sizeof(GLubyte));
        CGContextRef spriteContext = CGBitmapContextCreate(spriteData, width, height, 8, width*4, CGImageGetColorSpace(spriteImage), kCGImageAlphaPremultipliedLast);
        CGContextDrawImage(spriteContext, CGRectMake(0, 0, width, height), spriteImage);
        CGContextRelease(spriteContext);
        
        glGenTextures(1, &_diffuseMap);
        glActiveTexture(GL_TEXTURE0);
        glBindTexture(GL_TEXTURE_2D, _diffuseMap);
        glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR);
        glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR);
        glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_CLAMP_TO_EDGE);
        glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_CLAMP_TO_EDGE);
        glTexImage2D(GL_TEXTURE_2D, 0, GL_RGBA, (GLsizei)width, (GLsizei)height, 0, GL_RGBA, GL_UNSIGNED_BYTE, spriteData);
        glBindTexture(GL_TEXTURE_2D, 0);
        
        // 加载纹理第二个纹理
        spriteImage = [UIImage imageNamed:@"container2_specular.png"].CGImage;
        width = CGImageGetWidth(spriteImage);
        height = CGImageGetHeight(spriteImage);
        spriteContext = CGBitmapContextCreate(spriteData, width, height, 8, width*4, CGImageGetColorSpace(spriteImage), kCGImageAlphaPremultipliedLast);
        CGContextDrawImage(spriteContext, CGRectMake(0, 0, width, height), spriteImage);
        CGContextRelease(spriteContext);
        
        glGenTextures(1, &_specularMap);
        glActiveTexture(GL_TEXTURE1);
        glBindTexture(GL_TEXTURE_2D, _specularMap);
        glTexImage2D(GL_TEXTURE_2D, 0, GL_RGBA,(GLsizei)width, (GLsizei)height, 0, GL_RGBA, GL_UNSIGNED_BYTE, spriteData);
        glGenerateMipmap(GL_TEXTURE_2D);
        glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_CLAMP_TO_EDGE);
        glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_CLAMP_TO_EDGE);
        glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR);
        glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR);
        glBindTexture(GL_TEXTURE_2D, 0);
        
        free(spriteData);
        
        
        // 激活绑定第一个纹理
        glActiveTexture(GL_TEXTURE0);
        glBindTexture(GL_TEXTURE_2D, _diffuseMap);
        glUniform1i(glGetUniformLocation(_shaderProgram, "material.diffuse"), 0);
        
        
        //激活绑定第二个纹理
        glActiveTexture(GL_TEXTURE1);
        glBindTexture(GL_TEXTURE_2D, _specularMap);
        glUniform1i(glGetUniformLocation(_shaderProgram, "material.specular"), 1);
        
    }
    return self;
}

- (void)configData
{
    cameraPos   = GLKVector3Make(0.0, 0.0, 3.0);
    cameraFront = GLKVector3Make(0.0, 0.0, -1.0);
    cameraUp    = GLKVector3Make(0.0, 1.0, 0.0);
}

- (void)render:(CADisplayLink *)displayLink
{
    GLfloat currentFrame = displayLink.timestamp;
    deltaTime = currentFrame - lastFrame;
    lastFrame = currentFrame;
    
    //https://learnopengl-cn.github.io/02%20Lighting/05%20Light%20casters/
    glClearColor(0.1, 0.1, 0.1, 1.0f);
    glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);
    glUseProgram(_shaderProgram);
    
    GLKVector3 lightPos = GLKVector3Make(1.2, 1.0, 2.0);
    lightPos.x = sin(displayLink.timestamp) * 2.0f;
    lightPos.y = sin(displayLink.timestamp / 2.0f) * 1.0f;
    
    GLint lightPosLoc = glGetUniformLocation(_shaderProgram, "light.position");
    GLint viewPosLoc  = glGetUniformLocation(_shaderProgram, "viewPos");
    glUniform3f(lightPosLoc, lightPos.x, lightPos.y, lightPos.z);
    glUniform3f(viewPosLoc, 0.0, 0.0, 3.0);
    
    //设置光线
    glUniform3f(glGetUniformLocation(_shaderProgram, "light.ambient"),   0.2f, 0.2f, 0.2f);
    glUniform3f(glGetUniformLocation(_shaderProgram, "light.diffuse"),   0.5f, 0.5f, 0.5f);
    glUniform3f(glGetUniformLocation(_shaderProgram, "light.specular"),  1.0f, 1.0f, 1.0f);
    glUniform1f(glGetUniformLocation(_shaderProgram, "light.constant"),  1.0f);
    glUniform1f(glGetUniformLocation(_shaderProgram, "light.linear"),    0.09);
    glUniform1f(glGetUniformLocation(_shaderProgram, "light.quadratic"), 0.032);
    // 设置材质
    glUniform1f(glGetUniformLocation(_shaderProgram, "material.shininess"), 32.0);
    
    
    //利用GLKMath做矩阵矩阵变化
    GLKMatrix4 model = GLKMatrix4Identity;//模型矩阵
    //    GLKMatrix4 view = GLKMatrix4Identity;//观察矩阵
    GLKMatrix4 projection = GLKMatrix4Identity;//投影矩阵
    
    //    model = GLKMatrix4Rotate(model, M_PI_4, 1.0, 1.0, 1.0);
    //    view = GLKMatrix4MakeLookAt(2.0, 2.0, 3.0, 0.0, 0.0, 0.0, 0.0, 1.0, 0.0);
    GLKMatrix4 view = GLKMatrix4MakeLookAt(cameraPos.x, cameraPos.y, cameraPos.z, cameraPos.x + cameraFront.x, cameraPos.y + cameraFront.y, cameraPos.z + cameraFront.z, cameraUp.x, cameraUp.y, cameraUp.z);
    projection = GLKMatrix4MakePerspective(M_PI_4,self.bounds.size.width / self.bounds.size.width, 0.1, 100.0);
    
    GLint modelLocation = glGetUniformLocation(_shaderProgram, [@"model" UTF8String]);
    GLint viewLocation = glGetUniformLocation(_shaderProgram, [@"view" UTF8String]);
    GLint projectionLocation = glGetUniformLocation(_shaderProgram, [@"projection" UTF8String]);
    
    glUniformMatrix4fv(viewLocation, 1, GL_FALSE, view.m);
    glUniformMatrix4fv(projectionLocation, 1, GL_FALSE, projection.m);
    
    glBindVertexArray(_containerVAO);
    for (GLuint i = 0; i < 10; i++)
    {
        model = GLKMatrix4Identity;
        
        model = GLKMatrix4TranslateWithVector3(model, cubePositions[i]);
        GLfloat angle = M_PI * 0.1 * i;
        
        model = GLKMatrix4Rotate(model, angle, 1.0, 0.3, 0.5);
        glUniformMatrix4fv(modelLocation, 1, GL_FALSE, model.m);
        glDrawArrays(GL_TRIANGLES, 0, 36);
    }
    glBindVertexArray(0);
    
    
    //灯的着色器
    glUseProgram(_lampShaderProgram);
    
    modelLocation = glGetUniformLocation(_lampShaderProgram, "model");
    viewLocation  = glGetUniformLocation(_lampShaderProgram, "view");
    projectionLocation  = glGetUniformLocation(_lampShaderProgram, "projection");
    
    glUniformMatrix4fv(modelLocation, 1, GL_FALSE, model.m);
    glUniformMatrix4fv(viewLocation, 1, GL_FALSE, view.m);
    glUniformMatrix4fv(projectionLocation, 1, GL_FALSE, projection.m);
    
    model = GLKMatrix4Identity;
    model = GLKMatrix4TranslateWithVector3(model, lightPos);
    model = GLKMatrix4Scale(model, 0.2, 0.2, 0.2);
    
    glUniformMatrix4fv(modelLocation, 1, GL_FALSE, model.m);
    glBindVertexArray(_lightVAO);
    glDrawArrays(GL_TRIANGLES, 0, 36);
    glBindVertexArray(0);
    
    
    [_context presentRenderbuffer:GL_RENDERBUFFER];
}

#pragma mark - 手势

- (void)addGesture
{
    UIPanGestureRecognizer *pan = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(pan:)];
    [self addGestureRecognizer:pan];
}

- (void)pan:(UIPanGestureRecognizer *)gesture
{
    CGFloat currentX = [gesture locationInView:gesture.view].x;
    CGFloat currentY = [gesture locationInView:gesture.view].y;
    
    CGFloat percentX = (_beginX - currentX) / CGRectGetWidth(gesture.view.bounds);
    CGFloat percentY = (_beginY - currentY) / CGRectGetWidth(gesture.view.bounds);
    
    //为了平衡每一帧渲染时间不一样
    GLfloat cameraSpeed = 10.0f * deltaTime;
    percentX = percentX * cameraSpeed;
    percentY = percentY * cameraSpeed;
    
    
    switch (gesture.state) {
        case UIGestureRecognizerStateBegan:
        {
            _beginX = [gesture locationInView:gesture.view].x;
            _beginY = [gesture locationInView:gesture.view].y;
        }
            break;
        case UIGestureRecognizerStateChanged:
        {
            cameraPos.z += percentY * cameraFront.z;
            GLKVector3 vector = GLKVector3Normalize(GLKVector3CrossProduct(cameraFront, cameraUp));
            vector = GLKVector3MultiplyScalar(vector, percentX);
            cameraPos = GLKVector3Add(cameraPos, vector);
        }
            break;
        default:
            break;
    }
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
