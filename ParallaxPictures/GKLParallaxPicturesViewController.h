//
//  GKLParallaxPicturesViewController.h
//  ParallaxPictures
//
//  Created by Joseph Pintozzi on 11/19/12.
//  Copyright (c) 2012 GoKart Labs. All rights reserved.
//

#import <UIKit/UIKit.h>

@class GKLParallaxPicturesViewController;

@protocol parallaxDelegate <NSObject>

@optional
- (void)GKLPPController:(GKLParallaxPicturesViewController *)controller tappedImage:(UIImage *)img atIndex:(NSUInteger)index;

@end

@interface GKLParallaxPicturesViewController : UIViewController

- (id)initWithImages:(NSArray *)images andContentView:(UIView*)contentView;
- (void)addImages:(NSArray*)moreImages;
- (void)addImage:(id)image atIndex:(int)index;

@property (weak, nonatomic) id<parallaxDelegate> parallaxDelegate;

@end
