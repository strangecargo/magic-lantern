/* MLImageView */

#import <Cocoa/Cocoa.h>
#import <QuartzCore/QuartzCore.h>
#import "MLImage.h"

@interface MLImageView : NSView
{
	BOOL centerImage;
	MLImage *image;
}

- (void)setCenterImage:(BOOL)newValue;

- (void)setImage:(MLImage *)newImage;

@end
