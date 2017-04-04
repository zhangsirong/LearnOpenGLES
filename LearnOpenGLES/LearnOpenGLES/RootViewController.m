//
//  ViewController.m
//  LearnOpenGLES
//
//  Created by zsr on 2017/3/25.
//  Copyright © 2017年 Lpzsrong Inc. All rights reserved.
//

#import "RootViewController.h"
#import "LSTestViewController.h"

@interface RootViewController ()<UITableViewDelegate,UITableViewDataSource>

@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) NSArray *titles;

@end

@implementation RootViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.title = @"demo";
    [self.view addSubview:self.tableView];
    
}

- (NSArray *)titles
{
    if (!_titles) {
        _titles = @[
                    @"第一个窗口",
                    @"第一个三角形",
                    @"不好的方式矩形",
                    @"索引矩形",
                    @"两个不同颜色的三角形",
                    @"颜色随时间变化的三角形",
                    @"颜色渐变的三角形",
                    @"简单加载纹理图片",
                    @"混合纹理",
                    @"不同的纹理环绕方式",
                    @"可调节的混合纹理",
                    @"简单变换",
                    @"3D坐标系",
                    @"立方体",
                    @"更多的立方体",
                    @"旋转的场景摄像机",
                    @"手势移动场景摄像机",
                    @"创建一个光照场景",
                    @"基础光照",
                    @"材质",
                    @"光照贴图",
                    @"发光的文字-放射光贴图",
                    @"定向光-太阳光",
                    @"点光源",
                    @"聚光-手电筒光线效果",
                    @"多光源效果",

                    ];
    }
    return _titles;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *ID = @"cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:ID];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:ID];
    }
    
    cell.textLabel.text = self.titles[indexPath.row];
    return cell;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.titles.count;
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    LSTestViewController *vc = [[LSTestViewController alloc] init];
    [self.navigationController pushViewController:vc animated:YES];
    vc.title = self.titles[indexPath.row];
    vc.index = indexPath.row;
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
}



- (UITableView *)tableView
{
    if (!_tableView) {
        _tableView = [[UITableView alloc] initWithFrame:self.view.bounds style:UITableViewStylePlain];
        _tableView.delegate = self;
        _tableView.dataSource = self;
        _tableView.tableFooterView = [[UIView alloc] init];
    }
    return _tableView;
}

- (BOOL)prefersStatusBarHidden
{
    return YES;
}


@end
