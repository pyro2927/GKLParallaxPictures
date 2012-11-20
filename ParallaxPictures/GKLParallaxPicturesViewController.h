//
//  GKLParallaxPicturesViewController.h
//  ParallaxPictures
//
//  Created by Joseph Pintozzi on 11/19/12.
//  Copyright (c) 2012 GoKart Labs. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface GKLParallaxPicturesViewController : UIViewController<UIScrollViewDelegate> {
    NSMutableArray  *_imageViews;
    UIScrollView    *_imageScroller;
    UIScrollView    *_transparentScroller;
    UIScrollView    *_contentScrollView;
    UIView          *_contentView;
    UIPageControl   *_pageControl;
    id parallaxDelegate;
}

- (id)initWithImages:(NSArray *)images andContentView:(UIView*)contentView;
- (void)addImages:(NSArray*)moreImages;
- (void)addImage:(id)image atIndex:(int)index;

@property (retain) id parallaxDelegate;

@end

@protocol parallaxDelegate <NSObject>
@optional
-(void)imageTapped:(UIImage*)image;
@end
