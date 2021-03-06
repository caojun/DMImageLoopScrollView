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

#import "DMImageLoopScrollView.h"
#import "DMImageLoopSubView.h"

#if DEBUG
#define DMIMAGELOOPDEBUG(...)   NSLog(__VA_ARGS__)
#else
#define DMIMAGELOOPDEBUG(...)
#endif

static const NSInteger kImageViewTagBeginID = 200;
static const NSInteger kScrollTimeDelay = 3;

@interface DMImageLoopScrollView () <UIScrollViewDelegate>


@property (nonatomic, strong) NSTimer *m_scrollTimer;
@property (nonatomic, assign) BOOL m_isUserHandleFlag;
@property (atomic, assign) NSInteger m_timerCount;

@property (nonatomic, strong) UIScrollView *m_scrollView;
@property (nonatomic, strong) UIPageControl *m_pageControl;

/**
 *  保存 DMImageLoopSubView 的数组
 */
@property (nonatomic, strong, readonly) NSMutableArray *m_loopSubViewArray;


@end


#pragma mark - DMImageLoopScrollView


static inline CGFloat viewWidth(UIView *view)
{
    return view.bounds.size.width;
}

static inline CGFloat viewHeight(UIView *view)
{
    return view.bounds.size.height;
}


@implementation DMImageLoopScrollView

@synthesize m_loopSubViewArray = _m_loopSubViewArray;
@synthesize curPage = _curPage;

#pragma mark - Life Cycle
- (void)dealloc
{
    [self scrollTimerStop];
}

- (void)defaultSetting
{
    _titleVerticalAlignment = UIControlContentVerticalAlignmentBottom;
    _titleHeight = 30;
    
    [self scrollViewCreate];
    [self pageControlCreate];
    
    self.scrollTime = kScrollTimeDelay;
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

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self)
    {
        [self defaultSetting];
    }
    
    return self;
}

+ (instancetype)imageLoopScrollView
{
    return [[self alloc] init];
}

+ (instancetype)imageLoopScrollViewWithImageParamArray:(nullable NSArray *)array
                                         andTitleArray:(nullable NSArray *)titleArray
                                   andPlaceholderImage:(nullable UIImage *)placeholderImage
{
    return [[self alloc] initWithImageParamArray:array
                                   andTitleArray:titleArray
                             andPlaceholderImage:placeholderImage];
}

- (instancetype)initWithImageParamArray:(nullable NSArray *)array
                          andTitleArray:(nullable NSArray *)titleArray
                    andPlaceholderImage:(nullable UIImage *)placeholderImage
{
    return [self initWithFrame:CGRectZero
            andImageParamArray:array
                 andTitleArray:titleArray
           andPlaceholderImage:placeholderImage];
}

- (instancetype)initWithFrame:(CGRect)frame
           andImageParamArray:(nullable NSArray *)array
                andTitleArray:(nullable NSArray *)titleArray
          andPlaceholderImage:(nullable UIImage *)placeholderImage
{
    self = [super initWithFrame:frame];
    if (self)
    {
        [self defaultSetting];
        
        _placeholderImage = placeholderImage;
        _imageParamArray = array;
        _titleArray = titleArray;
        
        [self scrollSubViewCreate];
    }
    
    return self;
}


- (void)layoutSubviews
{
    [super layoutSubviews];
    
    if (![self.subviews containsObject:self.m_scrollView])
    {
        [self addSubview:self.m_scrollView];
    }
    
    //adjust scrollview frame
    [self scrollViewAdjustFrame];
    
    if (![self.subviews containsObject:self.m_pageControl])
    {
        [self addSubview:self.m_pageControl];
    }
    
    //adjust pageControl
    [self pageControlAdjustFrame];
}


#pragma mark - SubViews
#pragma mark PageControl
- (void)pageControlAdjustFrame
{
    CGFloat w = 20 * self.m_pageControl.numberOfPages;
    CGFloat h = 30;
    CGFloat x = 0;
    CGFloat y = viewHeight(self) - h;
    
    if (DMImageLoopPageControlAlignmentLeft == self.imageLoopPageControlAlignment)
    {
        x = 0;
    }
    else if (DMImageLoopPageControlAlignmentRight == self.imageLoopPageControlAlignment)
    {
        x = viewWidth(self) - w;
    }
    else
    {
        x = (viewWidth(self) - w) / 2;
    }
    
    self.m_pageControl.frame = (CGRect){x, y, w, h};
}

- (void)pageControlCreate
{
    if (nil == self.m_pageControl)
    {
        UIPageControl *pageControl = [[UIPageControl alloc] init];
        self.m_pageControl = pageControl;
        
        pageControl.userInteractionEnabled = NO;
        pageControl.numberOfPages = 0;
        pageControl.hidesForSinglePage = YES;
        pageControl.currentPage = 0;
        pageControl.pageIndicatorTintColor = [UIColor grayColor];
    }
}

#pragma mark ScrollView
- (void)scrollViewAdjustFrame
{
    self.m_scrollView.frame = self.bounds;
    
    [self.m_loopSubViewArray enumerateObjectsUsingBlock:^(DMImageLoopSubView *obj, NSUInteger idx, BOOL *stop) {
        CGFloat w = viewWidth(self);
        CGFloat h = viewHeight(self);
        CGFloat x = idx * w;
        CGFloat y = 0;
        obj.frame = (CGRect){x, y, w, h};
        
        if (![self.m_scrollView.subviews containsObject:obj])
        {
            [self.m_scrollView addSubview:obj];
        }
    }];
    
    self.m_scrollView.contentSize = CGSizeMake(self.m_loopSubViewArray.count * viewWidth(self), viewHeight(self));
    
    CGFloat offsetX = 0;
    if (self.m_loopSubViewArray.count > 1)
    { // fix bug, 当图片数量大于1时才调整
        offsetX = (self.m_pageControl.currentPage + 1) * viewWidth(self);
    }
    
    self.m_scrollView.contentOffset = (CGPoint){offsetX, 0};
}

- (void)scrollViewCreate
{
    if (nil == self.m_scrollView)
    {
        UIScrollView *scrollView = [[UIScrollView alloc] init];
        self.m_scrollView = scrollView;
        
        scrollView.bounces = NO;
        scrollView.pagingEnabled = YES;
        scrollView.showsHorizontalScrollIndicator = NO;
        scrollView.showsVerticalScrollIndicator = NO;
        scrollView.delegate = self;
    }
}

#pragma mark Scroll sub view
- (void)scrollSubViewRemove
{
    [self.m_loopSubViewArray enumerateObjectsUsingBlock:^(DMImageLoopSubView *obj, NSUInteger idx, BOOL *stop) {
        [obj removeFromSuperview];
    }];
    
    [self.m_loopSubViewArray removeAllObjects];
}

- (void)scrollSubViewCreate
{
    dispatch_async(dispatch_get_main_queue(), ^{
        [self scrollSubViewRemove];
        
        [self.imageParamArray enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
            NSString *title = nil;
            if (idx < self.titleArray.count)
            {
                title = self.titleArray[idx];
            }
            
            DMImageLoopSubView *subView = [DMImageLoopSubView imageLoopSubViewWithImageParam:obj andTitle:title andTitleBackgroundImage:self.titleBackgroundImage andPlaceholdImage:self.placeholderImage];
            subView.contentMode = self.imageViewContentMode;
            [self.m_loopSubViewArray addObject:subView];
            subView.titleColor = self.titleColor;
            subView.titleFont = self.titleFont;
            subView.titleAlignment = self.imageLoopTitleHorAlignment;
            subView.titleHeight = self.titleHeight;
            subView.titleVerticalAlignment = self.titleVerticalAlignment;
            
            subView.tag = kImageViewTagBeginID + idx;
            UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tap:)];
            [subView addGestureRecognizer:tap];
            subView.userInteractionEnabled = YES;
        }];
        
        NSInteger count = self.m_loopSubViewArray.count;
        
        self.m_pageControl.numberOfPages = count;
        self.m_pageControl.currentPage = 0;
        
        if (count > 1)
        {
            DMImageLoopSubView *firstView = [self.m_loopSubViewArray firstObject];
            DMImageLoopSubView *lastView = [self.m_loopSubViewArray lastObject];
            
            DMImageLoopSubView *insertFirstView = [DMImageLoopSubView imageLoopSubViewWithImageParam:firstView.imageParam andTitle:firstView.title andTitleBackgroundImage:firstView.titleBackgroundImage andPlaceholdImage:self.placeholderImage];
            insertFirstView.contentMode = self.imageViewContentMode;
            insertFirstView.tag = firstView.tag;
            UITapGestureRecognizer *firstTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tap:)];
            [insertFirstView addGestureRecognizer:firstTap];
            insertFirstView.userInteractionEnabled = YES;
            insertFirstView.titleColor = self.titleColor;
            insertFirstView.titleFont = self.titleFont;
            insertFirstView.titleAlignment = self.imageLoopTitleHorAlignment;
            insertFirstView.titleHeight = self.titleHeight;
            insertFirstView.titleVerticalAlignment = self.titleVerticalAlignment;
            
            DMImageLoopSubView *insertLastView = [DMImageLoopSubView imageLoopSubViewWithImageParam:lastView.imageParam andTitle:lastView.title andTitleBackgroundImage:lastView.titleBackgroundImage andPlaceholdImage:self.placeholderImage];
            insertLastView.contentMode = self.imageViewContentMode;
            insertLastView.tag = lastView.tag;
            UITapGestureRecognizer *lastTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tap:)];
            [insertLastView addGestureRecognizer:lastTap];
            insertLastView.userInteractionEnabled = YES;
            insertLastView.titleColor = self.titleColor;
            insertLastView.titleFont = self.titleFont;
            insertLastView.titleAlignment = self.imageLoopTitleHorAlignment;
            insertLastView.titleHeight = self.titleHeight;
            insertLastView.titleVerticalAlignment = self.titleVerticalAlignment;
            
            [self.m_loopSubViewArray insertObject:insertLastView atIndex:0];
            [self.m_loopSubViewArray addObject:insertFirstView];
        }
        
        [self setNeedsLayout];
    });
}

#pragma mark - Event
- (void)tap:(UITapGestureRecognizer*)tap
{
    UIImageView *imageView = (UIImageView *)tap.view;

    if (tap.state == UIGestureRecognizerStateEnded)
    {
        if (self.delegate && [self.delegate respondsToSelector:@selector(imageLoopScrollView:didClickIndex:)])
        {
            NSInteger index = imageView.tag - kImageViewTagBeginID;
            
            [self.delegate imageLoopScrollView:self didClickIndex:index];
        }
    }
}


#pragma mark - UIScrollViewDelegate
- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    NSInteger page = 0;
    CGFloat x=0;
    CGFloat width = viewWidth(self);
    CGFloat contentOffsetX = self.m_scrollView.contentOffset.x;
    CGFloat contentOffsetW = self.m_scrollView.contentSize.width;
    
    if (contentOffsetX <= 0)
    {
        page = self.m_pageControl.numberOfPages - 1;
        x = contentOffsetW - width * 2;
        
        self.m_scrollView.contentOffset = CGPointMake(x, 0);
    }
    else if (contentOffsetX >= (contentOffsetW - width - (width / 2))) //由于是float计算，此会存在偏差，所以此处多减去width的一半，确保page计算正确
    {
        page = 0;
        self.m_scrollView.contentOffset = CGPointMake(width, 0);
    }
    else if (contentOffsetX >= width)
    {
        NSInteger tmpX = contentOffsetX;
        NSInteger tmpW = width;
        //由于是float计算，此会存在偏差，所以此处多加上width的一半，确保page计算正确
        page = ((tmpX - tmpW) + (tmpW / 2)) / tmpW;
    }
    
    self.m_pageControl.currentPage = page;

    self.m_isUserHandleFlag = NO;
    self.m_timerCount = 0;
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    self.m_isUserHandleFlag = YES;
    self.m_timerCount = 0;
}


// called when setContentOffset/scrollRectVisible:animated: finishes. not called if not animating
- (void)scrollViewDidEndScrollingAnimation:(UIScrollView *)scrollView
{
    [self scrollViewDidEndDecelerating:scrollView];
}

#pragma mark - NSTimer
- (void)scrollTimerStop
{
    [self.m_scrollTimer invalidate];
    self.m_scrollTimer = nil;
}

- (void)scrollTimerCreate
{
    if (nil == self.m_scrollTimer)
    {
        self.m_scrollTimer = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(scrollTimerHandle:) userInfo:nil repeats:YES];
        
        [[NSRunLoop mainRunLoop] addTimer:self.m_scrollTimer forMode:NSRunLoopCommonModes];
    }
}

-(void)scrollTimerHandle:(NSTimer *)timer
{
    if (!self.m_isUserHandleFlag)
    {
        self.m_timerCount++;
        if (self.m_timerCount >= self.scrollTime)
        {
            NSInteger oldx = self.m_scrollView.contentOffset.x;
            NSInteger w = viewWidth(self);
            //此处重新计算一下 x 坐标，解决当x坐标不是分页的起点坐标，导致显示中间一部分的问题。
            NSInteger x = oldx / w * w;
            CGFloat offsetX = x + w;

            if (offsetX < self.m_scrollView.contentSize.width)
            {
                [self.m_scrollView setContentOffset:CGPointMake(offsetX, 0) animated:YES];
            }
            else
            {
                [self.m_scrollView setContentOffset:CGPointMake(0, 0) animated:YES];
                
                self.m_timerCount = 0;
            }
        }
    }
    else
    {
        self.m_timerCount = 0;
    }
}

#pragma mark - setter / getter

- (void)setFrame:(CGRect)frame
{
    [super setFrame:frame];
    
    [self setNeedsLayout];
}

- (void)setImageParamArray:(nullable NSArray *)imageParamArray
             andTitleArray:(nullable NSArray *)titleArray
       andPlaceholderImage:(nullable UIImage *)placeholderImage
{
    _imageParamArray = imageParamArray;
    _titleArray = titleArray;
    _placeholderImage = placeholderImage;
    
    [self scrollSubViewCreate];
}

- (void)setImageParamArray:(NSArray *)imageParamArray
{
    _imageParamArray = imageParamArray;
    
    [self scrollSubViewCreate];
}

- (void)setImageLoopTitleHorAlignment:(NSTextAlignment)imageLoopTitleHorAlignment
{
    _imageLoopTitleHorAlignment = imageLoopTitleHorAlignment;
    
    [self.m_loopSubViewArray enumerateObjectsUsingBlock:^(DMImageLoopSubView *obj, NSUInteger idx, BOOL *stop) {
        obj.titleAlignment = imageLoopTitleHorAlignment;
    }];
}

- (void)setTitleArray:(NSArray *)titleArray
{
    _titleArray = titleArray;
    
    [self scrollSubViewCreate];
}

- (void)setTitleFont:(UIFont *)titleFont
{
    _titleFont = titleFont;
    
    [self.m_loopSubViewArray enumerateObjectsUsingBlock:^(DMImageLoopSubView *obj, NSUInteger idx, BOOL *stop) {
        obj.titleFont = titleFont;
    }];
}

- (void)setTitleColor:(UIColor *)titleColor
{
    _titleColor = titleColor;
    
    [self.m_loopSubViewArray enumerateObjectsUsingBlock:^(DMImageLoopSubView *obj, NSUInteger idx, BOOL *stop) {
        obj.titleColor = titleColor;
    }];
}

- (void)setImageLoopPageControlAlignment:(DMImageLoopPageControlAlignment)imageLoopPageControlAlignment
{
    _imageLoopPageControlAlignment = imageLoopPageControlAlignment;
    
    [self setNeedsLayout];
}

- (void)setHiddenPageControl:(BOOL)hiddenPageControl
{
    self.m_pageControl.hidden = hiddenPageControl;
}

- (BOOL)isHiddenPageControl
{
    return self.m_pageControl.hidden;
}

- (void)setScrollTime:(NSInteger)scrollTime
{
    if (_scrollTime != scrollTime)
    {
        _scrollTime = scrollTime;
        
        if (scrollTime > 0)
        {
            [self scrollTimerCreate];
        }
        else
        {
            [self scrollTimerStop];
        }
    }
}

/**
 *  保存 DMImageLoopSubView 的数组
 */
- (NSMutableArray *)m_loopSubViewArray
{
    if (nil == _m_loopSubViewArray)
    {
        _m_loopSubViewArray = [NSMutableArray array];
    }
    
    return _m_loopSubViewArray;
}

- (void)setCurPage:(NSInteger)curPage
{
    _curPage = curPage;
    
    __block NSInteger tempID = curPage;
    dispatch_async(dispatch_get_main_queue(), ^{
        if (tempID < self.imageParamArray.count)
        {
            NSInteger count = self.imageParamArray.count;
            if (count > 1)
            {
                tempID++;
            }
            
            CGFloat x = tempID * self.m_scrollView.contentSize.width;
            CGPoint point = {x, 0};
            [self.m_scrollView setContentOffset:point animated:YES];
        }
    });
}

- (NSInteger)curPage
{
    _curPage = self.m_pageControl.currentPage;
    
    return _curPage;
}

- (void)setImageViewContentMode:(UIViewContentMode)imageViewContentMode
{
    _imageViewContentMode = imageViewContentMode;
    
    [self.m_loopSubViewArray enumerateObjectsUsingBlock:^(DMImageLoopSubView *subView, NSUInteger idx, BOOL *stop) {
        subView.contentMode = imageViewContentMode;
    }];
}

- (void)setTitleVerticalAlignment:(UIControlContentVerticalAlignment)titleVerticalAlignment
{
    _titleVerticalAlignment = titleVerticalAlignment;
    
    [self.m_loopSubViewArray enumerateObjectsUsingBlock:^(DMImageLoopSubView *subView, NSUInteger idx, BOOL *stop) {
        subView.titleVerticalAlignment = titleVerticalAlignment;
    }];
}

- (void)setTitleHeight:(CGFloat)titleHeight
{
    _titleHeight = titleHeight;
    
    [self.m_loopSubViewArray enumerateObjectsUsingBlock:^(DMImageLoopSubView *subView, NSUInteger idx, BOOL *stop) {
        subView.titleHeight = titleHeight;
    }];
}

@end
