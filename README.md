<a href="http://gokartlabs.com"><img src="https://raw.github.com/pyro2927/GKLImages/master/icon_xtra_small.png"></a>GKLParallaxPictures
===================

**Heavy** inspiration drawn from <https://github.com/Rheeseyb/RBParallaxTableViewController> and <https://github.com/tapi/PXParallaxViewController>.  Much credit to both of those projects, as I probably wouldn't have had a good enough understanding of parallax without reading through their code.  I wanted a parallax view that had an image (UIPageControl) indicator, allowed you to add images after the view controller was initialized, and had a parallax effect while scrolling down instead of just while scrolling up (as Path does it).

### How To Use

	GKLParallaxPicturesViewController *paralaxViewController = [[GKLParallaxPicturesViewController alloc] initWithImages:uiimagesArray andContentView:contentView];
	
Where `contentView` is the detailed view you want below your images.  You can always add more images after the view controller is instantiated by calling:

	[paralaxViewController addImages:moarImages];
	
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
	
Image loading with [SDWebImage](https://github.com/rs/SDWebImage):

	-(void)loadImageFromURLString:(NSString*)urlString forImageView:(UIImageView*)imageView{
    	[imageView setImageWithURL:[NSURL URLWithString:urlString]];
	}

### Delegate Callbacks

Currently there is only one delegate method, `imageTapped:`.  Implementing this and setting a `parallaxDelegate` will give you a callback whenever the picture gallery is double tapped by the user, along with the UIImage that was tapped.

![](https://raw.github.com/pyro2927/GKLParallaxPictures/master/parallax.gif)