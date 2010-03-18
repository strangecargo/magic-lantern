//
//  MLImage.h
//  Magic Lantern
//
//  Created by Allan Hsu on 5/21/05.
//  Copyright 2005 Allan Hsu. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <QuartzCore/QuartzCore.h>

@interface MLImage : NSObject {
	NSString *imagePath;

	float scaleFactor;
	float rotation;
		
	NSData *imageData;
	CIImage *image;
	
	//render cache craps.
	NSLock *imageLock;
	CIImageAccumulator *renderCacheAccumulator;
	
	CGSize maxSize;
}

- (void)lock;
- (void)unlock;

- (id)initFromFilePath:(NSString *)filePath;

- (BOOL)shouldPreRender;
- (void) releaseRenderCache;
- (void) accumulateToRenderCache:(CIImage *)newCacheImage;
- (CIImage *)renderCacheImage;

- (void)rotateByDegrees:(float)degrees;


- (void)setAvailableSize:(CGSize)newSize;
- (CGSize)scaledImageSizeForAvailableSize;

- (CIImage *)transformedImage;
- (CIImage *)processedImage;

- (void)loadDataIfNeeded;

- (NSString *)path;
- (NSData *)imageData;
- (CIImage *)image;

- (NSComparisonResult)finderCompare:(MLImage *)otherImage;
@end
