//
//  ViewController.m
//  DMImageLoopScrollViewDemo
//
//  Created by Dream on 15/6/19.
//  Copyright (c) 2015年 GoSing. All rights reserved.
//

#import "ViewController.h"
#import "DMImageLoopScrollView.h"

@interface ViewController ()<DMImageLoopScrollViewDelegate>
@property (weak, nonatomic) IBOutlet DMImageLoopScrollView *m_loopView;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    NSString *string = @"http://f.hiphotos.baidu.com/image/pic/item/0823dd54564e92580c4c76ee9e82d158ccbf4eb2.jpg";
    NSURL *url = [NSURL URLWithString:string];
    
    NSArray *imageParamArray = @[url, url, url, url];
    NSArray *titleArray = @[@"唐嫣0", @"唐嫣1", @"唐嫣2", @"唐嫣3"];
    
    DMImageLoopScrollView *loopView = [DMImageLoopScrollView imageLoopScrollViewWithImageParamArray:imageParamArray andTitleArray:titleArray andPlaceholdImage:nil];
    loopView.frame = (CGRect){0, CGRectGetHeight(self.view.bounds) / 2, CGRectGetWidth(self.view.bounds) / 4 * 3, CGRectGetHeight(self.view.bounds) / 2};
    loopView.delegate = self;
    loopView.titleColor = [UIColor redColor];
    [self.view addSubview:loopView];
    
    
    UIImage *image = [UIImage imageNamed:@"1.jpg"];
    imageParamArray = @[image, image, image, image];
    titleArray = @[@"赵丽颖0", @"赵丽颖1", @"赵丽颖2", @"赵丽颖3"];
    [self.m_loopView setImageParamArray:imageParamArray andTitleArray:titleArray andPlaceholdImage:nil];
    self.m_loopView.imageLoopPageControlAlignment = DMImageLoopPageControlAlignmentLeft;
    self.m_loopView.titleColor = [UIColor orangeColor];
    self.m_loopView.imageLoopTitleHorAlignment = NSTextAlignmentRight;
}

#pragma mark - DMImageLoopScrollViewDelegate
-(void)imageLoopScrollView:(DMImageLoopScrollView *)view didClickIndex:(NSInteger)index
{
    NSLog(@"Did Click Index %@", @(index));
}


@end
