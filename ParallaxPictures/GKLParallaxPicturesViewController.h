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
}

- (id)initWithImages:(NSArray *)images andContentView:(UIView*)contentView;
- (void)addImages:(NSArray*)moreImages;
@end
