//
//  GKLParallaxPicturesViewController.m
//  ParallaxPictures
//
//  Created by Joseph Pintozzi on 11/19/12.
//  Copyright (c) 2012 GoKart Labs. All rights reserved.
//

#import "GKLParallaxPicturesViewController.h"

@interface GKLParallaxPicturesViewController ()

@end

@implementation GKLParallaxPicturesViewController

static CGFloat WindowHeight = 200.0;
static CGFloat ImageHeight  = 400.0;
static CGFloat PageControlHeight = 20.0f;

- (id)initWithImages:(NSArray *)images andContentView:(UIView *)contentView {
    self = [super initWithNibName:nil bundle:nil];
    if (self) {
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
        _transparentScroller.showsVerticalScrollIndicator   = YES;
        _transparentScroller.showsHorizontalScrollIndicator = NO;
        
        _contentScrollView = [[UIScrollView alloc] init];
        _contentScrollView.backgroundColor              = [UIColor clearColor];
        _contentScrollView.delegate                     = self;
        _contentScrollView.showsVerticalScrollIndicator = NO;
        
        _pageControl = [[UIPageControl alloc] init];
        _pageControl.currentPage = 0;
        [_pageControl setHidesForSinglePage:YES];
        
        [_contentScrollView addSubview:contentView];
        [_contentScrollView addSubview:_pageControl];
        [_contentScrollView addSubview:_transparentScroller];
        _contentView = contentView;
        [self.view addSubview:_imageScroller];
        [self.view addSubview:_contentScrollView];
    }
    return self;
}

-(void)addImages:(NSArray *)moreImages{
    CGFloat imageWidth   = _imageScroller.frame.size.width;
    CGFloat imageYOffset = floorf((WindowHeight  - ImageHeight) / 2.0);
    CGFloat imageXOffset = [_imageViews count] * imageWidth;
    
    for (id image in moreImages) {
        UIImageView *imageView  = [[UIImageView alloc] init];
        if ([image isKindOfClass:[UIImage class]]) {
            [imageView setImage:image];
            //                allow users to submit URLs
        } else if ([image isKindOfClass:[NSString class]]){
            dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0ul);
            dispatch_async(queue, ^{
                NSData *imageData = [[NSData alloc] initWithContentsOfURL:[NSURL URLWithString:(NSString*)image]];
                dispatch_sync(dispatch_get_main_queue(), ^{
                    UIImage *downloadedImage = [[UIImage alloc] initWithData:imageData];
                    [imageView setImage:downloadedImage];
                });
            });
        }
        imageView.frame = CGRectMake(imageXOffset, imageYOffset, imageWidth, ImageHeight);
        imageXOffset   += imageWidth;
        [imageView setContentMode:UIViewContentModeScaleAspectFill];
        [_imageScroller addSubview:imageView];
        [_imageViews addObject:imageView];
    }
    
    [_pageControl setNumberOfPages:[_imageViews count]];
    _imageScroller.contentSize = CGSizeMake([_imageViews count]*imageWidth, self.view.bounds.size.height);
    
    _transparentScroller.contentSize = CGSizeMake([_imageViews count]*imageWidth, WindowHeight);
    [self layoutImages];
}

#pragma mark - Parallax effect

- (void)updateOffsets {
    CGFloat yOffset   = _contentScrollView.contentOffset.y;
    CGFloat xOffset   = _transparentScroller.contentOffset.x;
    CGFloat threshold = ImageHeight - WindowHeight;
    
    if (yOffset > -threshold && yOffset < 0) {
        _imageScroller.contentOffset = CGPointMake(xOffset, floorf(yOffset / 2.0));
    } else if (yOffset < 0) {
        _imageScroller.contentOffset = CGPointMake(xOffset, yOffset + floorf(threshold / 2.0));
    } else {
        _imageScroller.contentOffset = CGPointMake(xOffset, floorf(yOffset / 2.0));
    }
}

- (void)layoutContent
{
    _contentScrollView.frame = self.view.bounds;
	
	CGFloat yOffset = WindowHeight;
	CGFloat xOffset = 0.0;
	
	CGSize contentSize = _contentView.frame.size;
	contentSize.height += yOffset;
    
	_contentView.frame				= (CGRect){.origin = CGPointMake(xOffset, yOffset), .size = _contentView.frame.size};
	_contentScrollView.contentSize	= contentSize;
}

#pragma mark - View Layout

- (void)layoutImages {
    CGFloat imageWidth   = _imageScroller.frame.size.width;
    CGFloat imageYOffset = floorf((WindowHeight  - ImageHeight) / 2.0);
    CGFloat imageXOffset = 0.0;
    
    for (UIImageView *imageView in _imageViews) {
        imageView.frame = CGRectMake(imageXOffset, imageYOffset, imageWidth, ImageHeight);
        imageXOffset   += imageWidth;
    }
    
    _imageScroller.contentSize = CGSizeMake([_imageViews count]*imageWidth, self.view.bounds.size.height);
    _imageScroller.contentOffset = CGPointMake(0.0, 0.0);
    
    _transparentScroller.contentSize = CGSizeMake([_imageViews count]*imageWidth, WindowHeight);
    _transparentScroller.contentOffset = CGPointMake(0.0, 0.0);
}

#pragma mark - View lifecycle

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    CGRect bounds = self.view.bounds;
    
    _imageScroller.frame        = CGRectMake(0.0, 0.0, bounds.size.width, bounds.size.height);
    _transparentScroller.frame  = CGRectMake(0.0, 0.0, bounds.size.width, WindowHeight);
    _pageControl.frame          = CGRectMake(0.0, WindowHeight - PageControlHeight, 0.0, PageControlHeight);
    _pageControl.numberOfPages  = [_imageViews count];
    
    _contentScrollView.frame            = bounds;
    [_contentScrollView setExclusiveTouch:NO];
    [self layoutImages];
    [self layoutContent];
    [self updateOffsets];
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
