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

NS_ASSUME_NONNULL_BEGIN

@interface DMImageLoopSubView : UIImageView

/// 图片参数，UIImage 或者 NSURL
@property (nonnull, nonatomic, strong) id imageParam;
@property (nonnull,nonatomic, copy) NSString *title;
@property (nonnull,nonatomic, strong) UIFont *titleFont;
@property (nonnull,nonatomic, strong) UIColor *titleColor;
@property (nonnull,nonatomic, strong) UIImage *titleBackgroundImage;
/// 文本对齐方式
@property (nonatomic, assign) NSTextAlignment titleAlignment;
/// 垂直对齐方式
@property (nonatomic, assign) UIControlContentVerticalAlignment titleVerticalAlignment;
@property (nonatomic, assign) CGFloat titleHeight;


+ (instancetype)imageLopSubView;
+ (instancetype)imageLoopSubViewWithImageParam:(nonnull id)imageParam andTitle:(nonnull NSString *)title andTitleBackgroundImage:(nonnull UIImage *)backgroundImage andPlaceholdImage:(nonnull UIImage *)placeholdImage;

@end

NS_ASSUME_NONNULL_END

