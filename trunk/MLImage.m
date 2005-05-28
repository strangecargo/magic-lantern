//
//  MLImage.m
//  Magic Lantern
//
//  Created by Allan Hsu on 5/21/05.
//  Copyright 2005 __MyCompanyName__. All rights reserved.
//

#import <sys/param.h>
#import "MLImage.h"

@implementation MLImage

- (id)initFromFilePath:(NSString *)filePath {
	self = [super init];
	
	if(self) {
		imagePath = filePath;

		rotation = 0.0;

		imageLock = [[NSLock alloc] init];
		renderCacheAccumulator = nil;
		
		[imagePath retain];
		
		return(self);
	}
	
	return(nil);
}

- (void)dealloc {
	//NSLog(@"MLImage dealloc: %@", imagePath);	
	if(image != nil) {
		[imagePath release];
		[imageData release];
		[image release];		
	}
	
	[self releaseRenderCache];
	[imageLock release];
	
	[super dealloc];
}

- (void)lock {
	[imageLock lock];
}

- (void)unlock {
	[imageLock unlock];
}

- (BOOL)shouldPreRender {
	return(scaleFactor != 1.0 || rotation != 0.0);
}

- (void)releaseRenderCache {
	if(renderCacheAccumulator != nil) {
		NSLog(@"Releasing cache accumulator...");
		[renderCacheAccumulator release];
		renderCacheAccumulator = nil;
	}
}

- (void) accumulateToRenderCache:(CIImage *)newCacheImage {
	//only accumulate if we have nothing cached and the image needs scaling/transform.
	if(renderCacheAccumulator == nil && (scaleFactor != 1.0 || rotation != 0.0)) {
		NSLog(@"Accumulating new image for %@", imagePath);
		renderCacheAccumulator = [[CIImageAccumulator alloc] initWithExtent:[newCacheImage extent] format:kCIFormatARGB8];
		[renderCacheAccumulator setImage:newCacheImage];
	}
}

- (CIImage *)renderCacheImage {
	if(renderCacheAccumulator != nil) {
		return([renderCacheAccumulator image]);
	}
	
	return(nil);
}

- (void)rotateByDegrees:(float)degrees {
	rotation += degrees;
	rotation = (int)rotation % 360;
	
	scaleFactor = [self scaledImageSizeForAvailableSize].height / [[self transformedImage] extent].size.height;
	[self releaseRenderCache];
}

- (void)setAvailableSize:(CGSize)newSize {
	if(maxSize.height != newSize.height || maxSize.width != newSize.width) {
		maxSize = newSize;
		scaleFactor = [self scaledImageSizeForAvailableSize].height / [[self transformedImage] extent].size.height;
		[self releaseRenderCache];
		
		NSLog(@"Scalefactor: %f", scaleFactor);
	}
}

- (CGSize)scaledImageSizeForAvailableSize {
	CGSize imageSize = [[self transformedImage] extent].size;
	
	//check to see if image can fit.
	if(imageSize.height > maxSize.height || imageSize.width > maxSize.width) {
		CGSize newSize = maxSize;
		
		//compare aspect ratios
		if(imageSize.height/imageSize.width > maxSize.height/maxSize.width) {
			//scale down the width of the new content rectangle to the right size.
			newSize.width = imageSize.width * maxSize.height/imageSize.height;
		} else {
			//scale down the height instead.
			newSize.height = imageSize.height * maxSize.width/imageSize.width;
		}
		
		return(newSize);
	}
	
	return(imageSize);
}

- (CIImage *)transformedImage {
	[self loadDataIfNeeded];
	
	CIImage *intermediate = image;
	
	if(rotation != 0.0) {
		NSAffineTransform *transform = [NSAffineTransform transform];
		[transform rotateByDegrees:rotation];
		CIFilter *affineFilter = [CIFilter filterWithName:@"CIAffineTransform"];
		[affineFilter setValue:transform forKey:@"inputTransform"];
		[affineFilter setValue:image forKey:@"inputImage"];
		intermediate = [affineFilter valueForKey:@"outputImage"];
	}
	
	return(intermediate);
}

- (CIImage *)processedImage {
	[self loadDataIfNeeded];

	if(rotation == 0.0 && scaleFactor == 1.0)
		return(image);
	
	if(renderCacheAccumulator != nil) {
		return([renderCacheAccumulator image]);
	}
	
	CIImage *intermediate = image;
		
	intermediate = [self transformedImage];

	if(scaleFactor != 1.0) {
		CIFilter *scaleFilter = [CIFilter filterWithName:@"CILanczosScaleTransform"];
		[scaleFilter setDefaults];
		[scaleFilter setValue:[NSNumber numberWithFloat:scaleFactor] forKey:@"inputScale"];
		[scaleFilter setValue:intermediate forKey:@"inputImage"];
		intermediate = [scaleFilter valueForKey:@"outputImage"];
	}
		
	return(intermediate);
}

- (void)loadDataIfNeeded {
	if(image == nil) {
		imageData = [NSData dataWithContentsOfMappedFile:imagePath];
		image = [CIImage imageWithData:imageData];
				
		[imageData retain];
		[image retain];
	}
}

- (NSString *)path {
	return(imagePath);
}

- (NSData *)imageData {
	[self loadDataIfNeeded];
	return(imageData);
}

- (CIImage *)image {
	[self loadDataIfNeeded];
	return(image);
}

// blargle. ganked and adapted from the version in Magic Lantern 1.0.1
// with some input from
// http://developer.apple.com/qa/qa2004/qa1159.html
// "Technical Q&A QA1159: Sorting Like The Finder
const UCCollateOptions MLIMAGE_COMPARE_OPTIONS =
kUCCollateComposeInsensitiveMask
| kUCCollateWidthInsensitiveMask
| kUCCollateCaseInsensitiveMask
| kUCCollateDigitsOverrideMask
| kUCCollateDigitsAsNumberMask
| kUCCollatePunctuationSignificantMask;

- (NSComparisonResult) finderCompare:(MLImage *)otherImage {
	SInt32 compareResult;
	NSString *path1;
	NSString *path2;
	UniChar buff1[MAXPATHLEN];
	UniChar buff2[MAXPATHLEN];
	
	path1 = [self path];
	path2 = [otherImage path];
	
	[path1 getCharacters:buff1];
	[path2 getCharacters:buff2];
	
	UCCompareTextDefault(MLIMAGE_COMPARE_OPTIONS, buff1, [path1 length], buff2, [path2 length], NULL, &compareResult);
	
	return((NSComparisonResult)compareResult);	
}

@end