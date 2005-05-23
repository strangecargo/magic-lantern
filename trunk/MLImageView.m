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
	NSGraphicsContext *currentContext = [NSGraphicsContext currentContext];
	
	if(image != nil) {
		CIImage *ciImage = [image processedImage];
			
		CIImage *result = ciImage;
		
		CGRect cgRect = CGRectMake(NSMinX(rect), NSMinY(rect), NSWidth(rect), NSHeight(rect));
		CIContext *coreContext = [currentContext CIContext];		
					
		if(centerImage) {
			cgRect.origin.x = (cgRect.size.width - [result extent].size.width)/2;
			cgRect.origin.y = (cgRect.size.height - [result extent].size.height)/2;
		}
		
		[coreContext drawImage:result atPoint:cgRect.origin fromRect:[result extent]];
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
