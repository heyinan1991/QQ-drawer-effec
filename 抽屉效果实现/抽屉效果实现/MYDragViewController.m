//
//  MYDragViewController.m
//  抽屉效果实现
//
//  Created by xuchuangnan on 15/8/18.
//  Copyright (c) 2015年 xuchuangnan. All rights reserved.
//

#import "MYDragViewController.h"
#define kMaxY 100 // 定义主屏幕位移到最右边Y的最大值
#define leftPMax  -250 // 向左滑最大偏移量
#define rightPmax 300  // 向右滑最大偏移量
#define screenW [UIScreen mainScreen].bounds.size.width
@interface MYDragViewController ()
@property(nonatomic,weak) UIView *leftView;
@property(nonatomic,weak) UIView *rightView;
@property(nonatomic,weak) UIView *mainView;
@end

@implementation MYDragViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // 添加子所有
    [self setUpChildView];
    // 添加mainView的手势
    [self setUIPanGesture];
    // 添加mainView的Frame属性的改变的监听
    
    [self setKVO];
}
#pragma mark - KVO监听mainView的frame的变化
- (void)setKVO
{
    [_mainView addObserver:self forKeyPath:@"frame" options:NSKeyValueObservingOptionNew context:nil];
}

// frame属性变化会调用这个方法
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    if (_mainView.frame.origin.x>0) {
        _rightView.hidden = YES;
    }else if (_mainView.frame.origin.x<0)
    {
        _rightView.hidden = NO;
    }
}

// 添加手势
- (void)setUIPanGesture
{
    UIPanGestureRecognizer *mainPan = [[UIPanGestureRecognizer alloc]initWithTarget:self action:@selector(mainViewClick:)];
    [_mainView addGestureRecognizer:mainPan];
    
    //  添加点按手势
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(tapClick)];
    [self.view addGestureRecognizer:tap];
}

- (void)tapClick
{
    if (_mainView.frame.origin.x !=0) {
        [UIView animateWithDuration:.5 animations:^{
            _mainView.frame = self.view.bounds;
        }];
    }
}


- (void)mainViewClick:(UIPanGestureRecognizer *)pan
{
    // 获取x轴的偏移量
    CGFloat offSetX = [pan translationInView:_mainView].x;
    NSLog(@"%f",offSetX);
    // 根据偏移量计算目前_main的frame
    _mainView.frame = [self frameWithOffSetX:offSetX];
    // 复位
    [pan setTranslation:CGPointZero inView:_mainView];
    // 如果_mainView.x>screenView*0.5 就跳到rightPmax - 目前x的偏移距离的位置,如果小于的话,就偏移当前的x的-x距离,那就是回到原位(这个是判断右滑的时候)
    // 这个是判断左划的,如果Max(_mainView).x<screenView*0.5,在左边,就位移leftPMax - 此时的x,此时x为负值,而且x值肯定不会比250大,所以就再往左划一点停下,如果最大的x还小于屏幕的一半,说明在屏幕一半的右边,就会回归原位
    if (pan.state == UIGestureRecognizerStateEnded) {
        
        CGFloat target = 0;
        
        if (_mainView.frame.origin.x>screenW*0.5) {
            // 如果_mainView.x>screenView*0.5 
            target = rightPmax;
        }else if(CGRectGetMaxX(_mainView.frame)<screenW*0.5){
            // 如果Max(_mainView).x<screenView*0.5 就回原位
            target = leftPMax;
        }
        // 计算x轴偏移量
      CGFloat  offSetX = target - _mainView.frame.origin.x;
        // 计算最新的frame
        [UIView animateWithDuration:.5 animations:^{
            _mainView.frame = [self frameWithOffSetX:offSetX];
        }];
    }
    
    
}

- (CGRect)frameWithOffSetX:(CGFloat)offSetX
{
    
    CGFloat screenH = [UIScreen mainScreen].bounds.size.height;
    
    // 获取上一次main的frame
    CGRect frame = _mainView.frame;
    // 获取位移后的x
    CGFloat x = frame.origin.x + offSetX;
    // 获取位移后的Y值
    // 计算缩放比例
    CGFloat scaleY = x/screenW;
    CGFloat y = fabs(scaleY * kMaxY);
    // 获取最新的H值
    CGFloat h = screenH - 2*y;
    // 获取x的缩放比例
    CGFloat scaleX = h/screenH;
    // 获取w值
    CGFloat w = scaleX * screenW;
    
    // 返回frame
    return CGRectMake(x, y, w, h);
}



#pragma mark - 添加子控件
- (void)setUpChildView
{
    UIView *leftView = [[UIView alloc]initWithFrame:self.view.bounds];
    leftView.backgroundColor = [UIColor greenColor];
    self.leftView = leftView;
    [self.view addSubview:leftView];
    
    UIView *rightView = [[UIView alloc]initWithFrame:self.view.bounds];
    rightView.backgroundColor = [UIColor blueColor];
    self.rightView = rightView;
    [self.view addSubview:rightView];
    UIView *mainView = [[UIView alloc]initWithFrame:self.view.bounds];
    mainView.backgroundColor = [UIColor redColor];
    self.mainView = mainView;
    [self.view addSubview:mainView];
}


@end
