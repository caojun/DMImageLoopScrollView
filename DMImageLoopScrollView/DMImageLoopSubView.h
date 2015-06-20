//
//  DMImageLoopSubView.h
//  DMImageLoopScrollViewDemo
//
//  Created by Dream on 15/6/19.
//  Copyright (c) 2015年 GoSing. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DMImageLoopSubView : UIImageView

/**
 *  图片参数，UIImage 或者 NSURL
 */
@property (nonatomic, strong) id imageParam;
@property (nonatomic, copy) NSString *title;
@property (nonatomic, strong) UIFont *titleFont;
@property (nonatomic, strong) UIColor *titleColor;
@property (nonatomic, strong) UIImage *titleBackgroundImage;
@property (nonatomic, assign) NSTextAlignment titleAlignment;


+ (instancetype)imageLopSubView;
+ (instancetype)imageLoopSubViewWithImageParam:(id)imageParam andTitle:(NSString *)title andTitleBackgroundImage:(UIImage *)backgroundImage andPlaceholdImage:(UIImage *)placeholdImage;


@end
