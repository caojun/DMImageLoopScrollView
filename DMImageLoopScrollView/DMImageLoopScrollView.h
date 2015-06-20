/**
 The MIT License (MIT)
 
 Copyright (c) 2015 DreamCao
 
 Permission is hereby granted, free of charge, to any person obtaining a copy
 of this software and associated documentation files (the "Software"), to deal
 in the Software without restriction, including without limitation the rights
 to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 copies of the Software, and to permit persons to whom the Software is
 furnished to do so, subject to the following conditions:
 
 The above copyright notice and this permission notice shall be included in all
 copies or substantial portions of the Software.
 
 THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
 SOFTWARE.
 */

#import <UIKit/UIKit.h>

@class DMImageLoopScrollView;

/**
 *  控制页对齐方式
 */
typedef NS_ENUM(NSInteger, DMImageLoopPageControlAlignment)
{
    /**
     *  左对齐
     */
    DMImageLoopPageControlAlignmentLeft = -1,
    /**
     *  居中
     */
    DMImageLoopPageControlAlignmentCenter = 0,
    /**
     *  右对齐
     */
    DMImageLoopPageControlAlignmentRight = 1,
};


#pragma mark - DMImageLoopScrollViewDelegate
@protocol DMImageLoopScrollViewDelegate <NSObject>


@optional
-(void)imageLoopScrollView:(DMImageLoopScrollView *)view didClickIndex:(NSInteger)index;

@end


#pragma mark - DMImageLoopScrollView
IB_DESIGNABLE
@interface DMImageLoopScrollView : UIView

@property (nonatomic, weak) IBOutlet id<DMImageLoopScrollViewDelegate> delegate;

/**
 *  占位图片
 */
@property (nonatomic, strong) UIImage *placeholdImage;

@property (nonatomic, strong) UIImage *titleBackgroundImage;

/**
 *  滚动时间为秒, 默认3秒
 */
@property (nonatomic, assign) NSInteger scrollTime;

/**
 *  imageArray 可存放UIImage / NSURL
 */
@property (nonatomic, strong) NSArray *imageParamArray;


/**
 *  title 水平对齐方式
 */
@property (nonatomic, assign) NSTextAlignment imageLoopTitleHorAlignment;

/**
 *  图片 title array
 */
@property (nonatomic, strong) NSArray *titleArray;

/**
 *  title 字体
 */
@property (nonatomic, strong) UIFont *titleFont;
/**
 *  title 颜色
 */
@property (nonatomic, strong) UIColor *titleColor;

/**
 *  控制页显示位置
 */
@property (nonatomic, assign) DMImageLoopPageControlAlignment imageLoopPageControlAlignment;

/**
 *  隐藏 页控制器, 默认是 NO
 */
@property (nonatomic, assign, getter=isHiddenPageControl) BOOL hiddenPageControl;

+ (instancetype)imageLoopScrollView;
+ (instancetype)imageLoopScrollViewWithImageParamArray:(NSArray *)array
                                         andTitleArray:(NSArray *)titleArray
                                     andPlaceholdImage:(UIImage *)placeholImage;

- (instancetype)initWithImageParamArray:(NSArray *)array
                          andTitleArray:(NSArray *)titleArray
                      andPlaceholdImage:(UIImage *)placeholdImage;

- (instancetype)initWithFrame:(CGRect)frame
           andImageParamArray:(NSArray *)array
                andTitleArray:(NSArray *)titleArray
            andPlaceholdImage:(UIImage *)placeholderImage;

- (void)setImageParamArray:(NSArray *)imageParamArray
             andTitleArray:(NSArray *)titleArray
         andPlaceholdImage:(UIImage *)placeholdImage;

@end
