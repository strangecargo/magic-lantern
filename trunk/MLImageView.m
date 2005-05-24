#import "MLImageView.h"

@implementation MLImageView

- (id)initWithFrame:(NSRect)frameRect
{
	if ((self = [super initWithFrame:frameRect]) != nil) {
		
		centerImage = NO;
		image = nil;
	}
	return self;
}

- (void)dealloc {
	NSLog(@"MLImageView dealloc");
	
	if(image != nil) {
		[image release];
	}
	
	[super dealloc];
}

- (void)drawRect:(NSRect)rect
{	
	if(image != nil) {
		// for some mysterious reason, CIContexts created this way are slower than the ones created through
		// NSGraphicsContext...
		//CGContextRef cgContext = [[NSGraphicsContext currentContext] graphicsPort];
		//CIContext *coreContext = [CIContext contextWithCGContext:cgContext options:nil];
		//NSDictionary *contextOptions = [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithBool:NO], @"kCIContextUseSoftwareRenderer", nil];
		//CIContext *coreContext = [CIContext contextWithCGContext:cgContext options:contextOptions];
		NSGraphicsContext *currentContext = [NSGraphicsContext currentContext];
		CIContext *coreContext = [currentContext CIContext];
		
		CIImage *ciImage = [image processedImage];
		CGRect imageRect = [ciImage extent];
		CGRect cgRect = CGRectMake(NSMinX(rect), NSMinY(rect), NSWidth(rect), NSHeight(rect));
					
		if(centerImage) {
			cgRect.origin.x = (cgRect.size.width - imageRect.size.width)/2;
			cgRect.origin.y = (cgRect.size.height - imageRect.size.height)/2;
		}
		
		[coreContext drawImage:ciImage atPoint:cgRect.origin fromRect:imageRect];
	}
}

- (void)setCenterImage:(BOOL)newValue {
	centerImage = newValue;
}

- (void)setImage:(MLImage *)newImage {

	if(image != nil) {
		[image release];
	}

	image = newImage;
	[image retain];
}

@end
