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

#import "DMImageLoopSubView.h"
#import "UIImageView+WebCache.h"
#import <UIView+WebCache.h>

@interface DMImageLoopSubView ()

@property (nullable, nonatomic, strong) UIImageView *m_bottomBackgroundView;
@property (nullable, nonatomic, strong) UILabel *m_titleLabel;
@property (nullable, nonatomic, strong) UIImage *m_placeholdImage;

@end

@implementation DMImageLoopSubView

@synthesize imageParam = _imageParam;
@synthesize titleFont = _titleFont;
@synthesize titleBackgroundImage = _titleBackgroundImage;
@synthesize titleAlignment = _titleAlignment;
@synthesize titleColor = _titleColor;
@synthesize titleVerticalAlignment = _titleVerticalAlignment;
@synthesize titleHeight = _titleHeight;


#pragma mark - Life Cycle

- (void)dealloc
{
    [self sd_cancelCurrentImageLoad];
}

+ (instancetype)imageLopSubView
{
    return [[self alloc] init];
}

+ (instancetype)imageLoopSubViewWithImageParam:(nullable id)imageParam andTitle:(nullable NSString *)title andTitleBackgroundImage:(nullable UIImage *)backgroundImage andPlaceholdImage:(nullable UIImage *)placeholdImage
{
    DMImageLoopSubView *subView = [self imageLopSubView];
    
    subView.title = title;
    subView.titleBackgroundImage = backgroundImage;
    subView.m_placeholdImage = placeholdImage;
    subView.imageParam = imageParam;
    
    return subView;
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self)
    {
        [self defaultSetting];
    }
    
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self)
    {
        [self defaultSetting];
    }
    
    return self;
}

- (void)defaultSetting
{
    self.clipsToBounds = YES;
    
    _titleHeight = 30;
    [self bottomBackgroundViewCreate];
    [self titleLabelCreate];
    _titleVerticalAlignment = UIControlContentVerticalAlignmentBottom;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    [self containtsSubViews];
    
    [self bottomBackgroundViewAdjustFrame];
    [self titleLabelAdjustFrame];
}

- (void)containtsSubViews
{
    //background image view
    if (nil != self.m_bottomBackgroundView)
    {
        if (![self.subviews containsObject:self.m_bottomBackgroundView])
        {
            [self addSubview:self.m_bottomBackgroundView];
            
            //title Label
            if (nil != self.m_titleLabel)
            {
                if (![self.m_bottomBackgroundView.subviews containsObject:self.m_titleLabel])
                {
                    [self.m_bottomBackgroundView addSubview:self.m_titleLabel];
                }
            }
        }
    }
}

#pragma mark - Bottom Background View
- (void)bottomBackgroundViewCreate
{
    if (nil == self.m_bottomBackgroundView)
    {
        UIImageView *backgroundView = [[UIImageView alloc] init];
        self.m_bottomBackgroundView = backgroundView;
    }
}

- (void)bottomBackgroundViewAdjustFrame
{
    if (nil != self.m_bottomBackgroundView)
    {
        CGFloat w = CGRectGetWidth(self.bounds);
        CGFloat h = _titleHeight;
        CGFloat x = 0;
        CGFloat y = 0;
        
        if (UIControlContentVerticalAlignmentCenter == self.titleVerticalAlignment)
        {
            y = (self.bounds.size.height - h) / 2;
        }
        else if (UIControlContentVerticalAlignmentTop == self.titleVerticalAlignment)
        {
            y = 0;
        }
        else if (UIControlContentVerticalAlignmentBottom == self.titleVerticalAlignment)
        {
            y = CGRectGetHeight(self.bounds) - h;
        }
        else if (UIControlContentVerticalAlignmentFill == self.titleVerticalAlignment)
        {
            y = 0;
            h = self.bounds.size.height;
        }

        CGRect frame = {x, y, w, h};
        
        self.m_bottomBackgroundView.frame = frame;
    }
}


#pragma mark - Title Label
- (void)titleLabelCreate
{
    if (nil == self.m_titleLabel)
    {
        UILabel *label = [[UILabel alloc] init];
        label.font = self.titleFont;
        label.textColor = self.titleColor;
        label.textAlignment = self.titleAlignment;
        label.numberOfLines = 0;
        self.m_titleLabel = label;
    }
}

- (void)titleLabelAdjustFrame
{
    if (nil != self.m_titleLabel)
    {
        CGFloat x = 10;
        CGFloat y = 0;
        CGFloat h = CGRectGetHeight(self.m_bottomBackgroundView.bounds);
        CGFloat w = CGRectGetWidth(self.m_bottomBackgroundView.bounds) - x * 2;
        
        self.m_titleLabel.frame = (CGRect){x, y, w, h};
    }
}

#pragma mark - setter / getter
- (id)imageParam
{
    return _imageParam;
}

- (void)setImageParam:(id)imageParam
{
    _imageParam = imageParam;
    
    if ([imageParam isKindOfClass:[UIImage class]])
    {
        self.image = imageParam;
    }
    else if ([imageParam isKindOfClass:[NSURL class]])
    {
        [self sd_setImageWithURL:imageParam placeholderImage:self.m_placeholdImage];
    }
}

- (NSString *)title
{
    return self.m_titleLabel.text;
}

- (void)setTitle:(NSString *)title
{
    self.m_titleLabel.text = title;
}

- (UIFont *)titleFont
{
    if (nil == _titleFont)
    {
        _titleFont = [UIFont systemFontOfSize:14];
    }
    
    return _titleFont;
}


- (void)setTitleFont:(UIFont *)titleFont
{
    _titleFont = titleFont;
    
    self.m_titleLabel.font = titleFont;
}

- (UIColor *)titleColor
{
    if (nil == _titleColor)
    {
        _titleColor = [UIColor blackColor];
    }
    
    return _titleColor;
}

- (void)setTitleColor:(UIColor *)titleColor
{
    _titleColor = titleColor;
    
    self.m_titleLabel.textColor = titleColor;
}

- (void)setTitleAlignment:(NSTextAlignment)titleAlignment
{
    _titleAlignment = titleAlignment;
    
    self.m_titleLabel.textAlignment = titleAlignment;
}

- (void)setTitleBackgroundImage:(UIImage *)titleBackgroundImage
{
    _titleBackgroundImage = titleBackgroundImage;
    
    self.m_bottomBackgroundView.image = titleBackgroundImage;
}

- (void)setTitleVerticalAlignment:(UIControlContentVerticalAlignment)titleVerticalAlignment
{
    _titleVerticalAlignment = titleVerticalAlignment;
    
    [self bottomBackgroundViewAdjustFrame];
    [self titleLabelAdjustFrame];
}

- (void)setTitleHeight:(CGFloat)titleHeight
{
    _titleHeight = titleHeight;
    
    [self bottomBackgroundViewAdjustFrame];
    [self titleLabelAdjustFrame];
}


@end
