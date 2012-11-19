GKLParallaxPictures
===================

**Heavy** inspiration drawn from <https://github.com/Rheeseyb/RBParallaxTableViewController> and <https://github.com/tapi/PXParallaxViewController>.  Much credit to both of those projects, as I probably wouldn't have had a good enough understanding of parallax without reading through their code.  I wanted a parallax view that had an image (UIPageControl) indicator, allowed you to add images after the view controller was initialized, and had a parallax effect while scrolling down instead of just while scrolling up (as Path does it).

### How To Use

	GKLParallaxPicturesViewController *paralaxViewController = [[GKLParallaxPicturesViewController alloc] initWithImages:uiimagesArray andContentView:contentView];
	
Where `contentView` is the detailed view you want below your images.  You can always add more images after the view controller is instantiated by calling:

	[paralaxViewController addImages:moarImages];

![](https://raw.github.com/pyro2927/GKLParallaxPictures/master/parallax.gif)