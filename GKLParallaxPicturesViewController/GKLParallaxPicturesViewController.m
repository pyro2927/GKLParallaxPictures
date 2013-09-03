//
//  GKLParallaxPicturesViewController.m
//  ParallaxPictures
//
//  Created by Joseph Pintozzi on 11/19/12.
//  Copyright (c) 2012 GoKart Labs. All rights reserved.
//

#import "GKLParallaxPicturesViewController.h"

@interface GKLParallaxPicturesViewController () <UIScrollViewDelegate>

//NSMutableArray  *_imageViews;
//UIScrollView    *_imageScroller;
//UIScrollView    *_transparentScroller;
//UIScrollView    *_contentScrollView;
//UIView          *_contentView;
//UIPageControl   *_pageControl;

@property (nonatomic, strong) NSMutableArray *imageViews;
@property (nonatomic, strong) UIScrollView *imageScroller;
@property (nonatomic, strong) UIScrollView *transparentScroller;
@property (nonatomic, strong) UIScrollView *contentScrollView;
@property (nonatomic, strong) UIView *contentView;
@property (nonatomic, strong) UIPageControl *pageControl;

@property (nonatomic, strong) UIWebView *webView;

@end

@implementation GKLParallaxPicturesViewController

static CGFloat WindowHeight = 200.0;
static CGFloat ImageHeight  = 200;
static CGFloat PageControlHeight = 20.0f;

- (id)initWithImages:(NSArray *)images andcontentObject:(id)content {
    self = [super initWithNibName:nil bundle:nil];
    
    if (self) {
        
        BOOL contentIsWebView = [content isKindOfClass:[UIWebView class]];
        BOOL contentIsScrollView = [content isKindOfClass:[UIScrollView class]];
        
        if (contentIsWebView) {
            _webView = content;
        }
        
        _imageScroller  = [[UIScrollView alloc] initWithFrame:CGRectZero];
        _imageScroller.backgroundColor                  = [UIColor clearColor];
        _imageScroller.showsHorizontalScrollIndicator   = NO;
        _imageScroller.showsVerticalScrollIndicator     = NO;
        _imageScroller.pagingEnabled                    = YES;
        
        _imageViews = [NSMutableArray arrayWithCapacity:[images count]];
        [self addImages:images];
        
        _transparentScroller = [[UIScrollView alloc] initWithFrame:CGRectZero];
        _transparentScroller.backgroundColor                = [UIColor clearColor];
        _transparentScroller.delegate                       = self;
        _transparentScroller.bounces                        = NO;
        _transparentScroller.pagingEnabled                  = YES;
        _transparentScroller.showsVerticalScrollIndicator   = NO;
        _transparentScroller.showsHorizontalScrollIndicator = NO;
        
        if (contentIsWebView) {
            _contentScrollView = _webView.scrollView;
        } else if (contentIsScrollView) {
            _contentScrollView = content;
        } else {
            _contentScrollView = [[UIScrollView alloc] init];
        }
        
        _contentScrollView.backgroundColor              = [UIColor clearColor];
        _contentScrollView.delegate                     = self;
        _contentScrollView.showsVerticalScrollIndicator = YES;
        
        // scroll to top handling
        _contentScrollView.scrollsToTop = YES;
        _transparentScroller.scrollsToTop = NO;
        _imageScroller.scrollsToTop = NO;
        
        _pageControl = [[UIPageControl alloc] init];
        _pageControl.currentPage = 0;
        [_pageControl setHidesForSinglePage:YES];
        
        if (!contentIsWebView && !contentIsScrollView) {
            _contentView = content;
            [_contentScrollView addSubview:_contentView];
        }
        
        [_contentScrollView addSubview:_pageControl];
        [self.view addSubview:_imageScroller];
        [self.view addSubview:_contentScrollView];
        [self.view addSubview:_transparentScroller];
        
        // load up our delegate to see when images are tapped on
        UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTapGesture:)];
        tapGesture.numberOfTapsRequired = 2;
        [_transparentScroller addGestureRecognizer:tapGesture];
    }
    return self;

}

- (id)initWithImages:(NSArray *)images andContentView:(UIView *)contentView {
    return [self initWithImages:images andcontentObject:contentView];	
}

- (id)initWithImages:(NSArray *)images andContentWebView:(UIWebView *)webView {
    return [self initWithImages:images andcontentObject:webView];
}

-(void)handleTapGesture:(id)sender{
    if ([self.delegate respondsToSelector:@selector(GKLPPController:tappedImage:atIndex:)]) {
        NSUInteger imageIndex = self.transparentScroller.contentOffset.x / self.imageScroller.frame.size.width;
        UIImage *image = [[self.imageViews objectAtIndex:imageIndex] image];
        [self.delegate GKLPPController:self tappedImage:image atIndex:imageIndex];
    }
    
}

-(void)loadImageFromURLString:(NSString*)urlString forImageView:(UIImageView*)imageView{
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0ul);
    dispatch_async(queue, ^{
        NSData *imageData = [[NSData alloc] initWithContentsOfURL:[NSURL URLWithString:urlString]];
        dispatch_sync(dispatch_get_main_queue(), ^{
            UIImage *downloadedImage = [[UIImage alloc] initWithData:imageData];
            [imageView setImage:downloadedImage];
        });
    });
}

- (void)addImage:(id)image atIndex:(int)index{
    UIImageView *imageView  = [[UIImageView alloc] init];
    if ([image isKindOfClass:[UIImage class]]) {
        [imageView setImage:image];
        //                allow users to submit URLs
    } else if ([image isKindOfClass:[NSString class]]){
        [self loadImageFromURLString:(NSString*)image forImageView:imageView];
    }
    [imageView setContentMode:UIViewContentModeScaleAspectFill];
    [imageView setClipsToBounds:YES];
    [_imageScroller addSubview:imageView];
    [_imageViews insertObject:imageView atIndex:index];
    [_pageControl setNumberOfPages:_pageControl.numberOfPages + 1];
    [self layoutImages];
}

-(void)addImages:(NSArray *)moreImages{
    for (id image in moreImages) {
        [self addImage:image atIndex:[_imageViews count]];
    }
    [_pageControl setNumberOfPages:[_imageViews count]];
    [self layoutImages];
}

#pragma mark - Utility

- (BOOL)contentViewIsScrollView {
    return (self.webView || !self.contentView);
}

#pragma mark - Parallax effect

- (void)updateOffsets {
    CGFloat yOffset   = _contentScrollView.contentOffset.y;
    
    if ([self contentViewIsScrollView]) {
        yOffset += WindowHeight; // compensate for the contentInset.y on self.contentScrollView
    }
    
    CGFloat xOffset   = _transparentScroller.contentOffset.x;
    CGFloat threshold = ImageHeight - WindowHeight;
    
    CGFloat yscroll = 0;
    
    if (yOffset > -threshold && yOffset < 0) { // user scrolled up to the image until showing the background
        // move the imageScroller down faster
        yscroll = floorf(yOffset / 2.0);
        _imageScroller.contentOffset = CGPointMake(xOffset, yscroll);
    } else if (yOffset < 0) { // user scrolled up to the image
        // move the imageScroller down
        yscroll = yOffset + floorf(threshold / 2.0);
        _imageScroller.contentOffset = CGPointMake(xOffset, yscroll);
    } else { // user scrolled down
        // move imageScroller up slowly
        yscroll = floorf(yOffset / 2.0);
        _imageScroller.contentOffset = CGPointMake(xOffset, yscroll);
    }
    
    CGFloat transpScrHeigth;
    transpScrHeigth = WindowHeight - abs(yOffset);
    
    CGRect transpScrFrame = self.transparentScroller.frame;
    
    if (transpScrHeigth > 0) {
        transpScrFrame.size.height = transpScrHeigth;
    } else {
        transpScrFrame.size.height = 0;
    }
    
    self.transparentScroller.frame = transpScrFrame;
}
- (void)layoutContent
{
    if (self.contentView) {
        _contentScrollView.frame = self.view.bounds;
        
        CGFloat yOffset = WindowHeight;
        CGFloat xOffset = 0.0;
        
        CGSize contentSize = _contentView.frame.size;
        contentSize.height += yOffset;
        
        _contentView.frame				= (CGRect){.origin = CGPointMake(xOffset, yOffset), .size = _contentView.frame.size};
        _contentScrollView.contentSize	= contentSize;
    } else if (self.webView) {
        self.webView.frame = self.view.bounds;
        self.webView.scrollView.contentInset = UIEdgeInsetsMake(WindowHeight, 0, 0, 0);
    }
}

#pragma mark - View Layout

- (void)layoutImages {
    CGFloat imageWidth   = _imageScroller.frame.size.width;
    
    CGFloat imageYOffset;
    if ([self contentViewIsScrollView]) {
        imageYOffset = 0;
    } else {
        imageYOffset = floorf((WindowHeight  - ImageHeight) / 2.0);
    }
    
    CGFloat imageXOffset = 0.0;
    
    for (UIImageView *imageView in _imageViews) {
        imageView.frame = CGRectMake(imageXOffset, imageYOffset, imageWidth, ImageHeight);
        imageXOffset   += imageWidth;
    }
    
    _imageScroller.contentSize = CGSizeMake([_imageViews count]*imageWidth, self.view.bounds.size.height);
    _imageScroller.contentOffset = CGPointMake(0.0, 0.0);
    
    _transparentScroller.contentSize = CGSizeMake([_imageViews count]*imageWidth, WindowHeight);
//    _transparentScroller.contentOffset = CGPointMake(0.0, 0.0);
}

#pragma mark - View lifecycle

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    CGRect bounds = self.view.bounds;
    
    _imageScroller.frame        = CGRectMake(0.0, 0.0, bounds.size.width, bounds.size.height);
    _transparentScroller.frame  = CGRectMake(0.0, 0.0, bounds.size.width, WindowHeight);
    
    
    if (self.contentView) {
        _contentScrollView.frame = bounds;
    }
    
    [_contentScrollView setExclusiveTouch:NO];
    [self layoutImages];
    [self layoutContent];
    [self updateOffsets];
    
    CGFloat pageControlY = WindowHeight - PageControlHeight;
    if (self.webView) {
        pageControlY = -PageControlHeight;
    }
    
    _pageControl.frame          = CGRectMake(0.0, pageControlY, bounds.size.width, PageControlHeight);
    _pageControl.numberOfPages  = [_imageViews count];
}

#pragma mark - Scroll View Delegate

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView{
    //    update our page marker
    [_pageControl setCurrentPage:floor(_transparentScroller.contentOffset.x/_imageScroller.frame.size.width)];
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    [self updateOffsets];
}

@end