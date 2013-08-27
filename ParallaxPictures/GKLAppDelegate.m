//
//  GKLAppDelegate.m
//  ParallaxPictures
//
//  Created by Joseph Pintozzi on 11/19/12.
//  Copyright (c) 2012 GoKart Labs. All rights reserved.
//

#import "GKLAppDelegate.h"
#import "GKLParallaxPicturesViewController.h"

@interface GKLAppDelegate () <GKLPPViewControllerDelegate>

@end

@implementation GKLAppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];

    //UIView *testContentView = [[[UINib nibWithNibName:@"testContentView" bundle:nil] instantiateWithOwner:nil options:nil] objectAtIndex:0];
    UIWebView *testWebView = [[UIWebView alloc] init];
    [testWebView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:@"http://nshipster.com/"]]];
    
    UIImage *testImage = [UIImage imageNamed:@"shovel"];
    NSArray *images = @[testImage, testImage, testImage];
    
    GKLParallaxPicturesViewController *paralaxViewController = [[GKLParallaxPicturesViewController alloc] initWithImages:images
                                                                                                          andContentWebView:testWebView];
    // optional delegate
    paralaxViewController.delegate = self;
    
    self.viewController = paralaxViewController;
    
    self.window.rootViewController = self.viewController;
    [self.window makeKeyAndVisible];
    return YES;
}

- (void)GKLPPController:(GKLParallaxPicturesViewController *)controller tappedImage:(UIImage *)img atIndex:(NSUInteger)index {
    NSLog(@"Tapped image (%@) at index %d", img, index);
}

@end
