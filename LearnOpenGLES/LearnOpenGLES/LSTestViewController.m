//
//  LSTestViewController.m
//  LearnOpenGLES
//
//  Created by zsr on 2017/3/25.
//  Copyright © 2017年 Lpzsrong Inc. All rights reserved.
//

#define ViewClass(className)   [[NSClassFromString(className) alloc] initWithFrame:self.view.bounds];

#import "LSTestViewController.h"
#import "LSBaseDisplayLinkView.h"

@interface LSTestViewController ()

@property (nonatomic,strong) UIView* openGLView;

@end

@implementation LSTestViewController



- (void)viewDidLoad
{
    [super viewDidLoad];
    [self.view addSubview:self.openGLView];
}

- (UIView *)openGLView
{
    if (!_openGLView) {
        switch (self.index) {
            case 0:
                _openGLView = ViewClass(@"LSFirstView");
                break;
            case 1:
                _openGLView = ViewClass(@"LSTriangleView");
                break;
            case 2:
                _openGLView = ViewClass(@"LSRectangleView");
                break;
            case 3:
                _openGLView = ViewClass(@"LSRectangleIndexView");
                break;
            case 4:
                _openGLView = ViewClass(@"LSTwoTriangleView");
                break;
            case 5:
                _openGLView = ViewClass(@"LSAnimationColorView");
                break;
            case 6:
                _openGLView = ViewClass(@"LSGradientTriangleView");
                break;
            case 7:
                _openGLView = ViewClass(@"LSSampleTextureView");
                break;
            case 8:
                _openGLView = ViewClass(@"LSBlendTextureView");
                break;
            case 9:
                _openGLView = ViewClass(@"LSFourFaceTextureView");
                break;
            case 10:
                _openGLView = ViewClass(@"LSFlexableMixTextureView");
                break;
            case 11:
                _openGLView = ViewClass(@"LSSampleTransformationView");
                break;
            case 12:
                _openGLView = ViewClass(@"LS3DCoordinateView");
                break;
            case 13:
                _openGLView = ViewClass(@"LS3DCubeView");
                break;
            case 14:
                _openGLView = ViewClass(@"LSMore3DCubeView");
                break;
            case 15:
                _openGLView = ViewClass(@"LS3DCubeCameraView");
                break;
            case 16:
                _openGLView = ViewClass(@"LSMoveCameraView");
                break;
            case 17:
                _openGLView = ViewClass(@"LSColorSceneView");
                break;
            case 18:
                _openGLView = ViewClass(@"LSBaseLightingView");
                break;
            case 19:
                _openGLView = ViewClass(@"LSMaterialView");
                break;
            case 20:
                _openGLView = ViewClass(@"LSLightingMapView");
                break;
            case 21:
                _openGLView = ViewClass(@"LSLightingTextView");
                break;
                
            default:
                _openGLView = ViewClass(@"UIView");
        }
    }
    return _openGLView;
}


- (BOOL)prefersStatusBarHidden
{
    return YES;
}

- (void)dealloc
{    
    if ([self.openGLView isKindOfClass:[LSBaseDisplayLinkView class]]) {
        //释放定时器
        [(LSBaseDisplayLinkView*)self.openGLView invalidate];
    }
}

@end
