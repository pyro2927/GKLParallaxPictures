## GKLParallaxPictures

This component allows you to display an image gallery on top of a simple `UIView` or `UIWebView`. Scroll and you will see a nice parallax effect.

![](https://raw.github.com/pyro2927/GKLParallaxPictures/master/screenshot1.gif)

### Install

The easiest way to install this component is via [CocoaPods](http://cocoapods.org/).

Add the following line to your `podfile`:

    pod 'GKLParallaxPictures'

Then run the `pod install` command and import `GKLParallaxPicturesViewController.h` where you plan to use this.

You can also install it manually. Just drag `GKLParallaxPicturesViewController.h` and `GKLParallaxPicturesViewController.m` in your project and import the `.h` file where you want to use this component.


### How To Use

	GKLParallaxPicturesViewController *paralaxViewController = [[GKLParallaxPicturesViewController alloc] initWithImages:imagesArray andContentView:contentView];
	
Where `contentView` is the detailed view you want below your images.

You can always add more images after the view controller is instantiated by calling:

	[paralaxViewController addImages:moreImagesArray];

Image arrays can contain both istances of `UIImage` and `NSString`. In the latter case those will be URLs of those images which will be loaded asynchronously.

#### Displaying a web view

This is the reason I forked for. It was not possible to display an `UIWebView` as the `contentView`.

    UIWebView *testWebView = [[UIWebView alloc] init];
    [testWebView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:@"http://nshipster.com/"]]];
    
    UIImage *testImage = [UIImage imageNamed:@"shovel"];
    NSArray *images = @[testImage, testImage, testImage];
    
    GKLParallaxPicturesViewController *paralaxViewController = [[GKLParallaxPicturesViewController alloc] initWithImages:images
                                                                                                          andContentWebView:testWebView];

Result:

![](https://raw.github.com/frankdilo/GKLParallaxPictures/master/screenshot2.png)


### URL Image Loading

GKLParallaxPictures accepts both UIImages and NSStrings (of an image URL) for adding UIImageViews into the top gallery.  By default it uses dispatch_queue to load images asynchronously, but you can subclass GKLParallaxPictures and overwrite this method to handle image loading however you choose.

Default image loading:

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
