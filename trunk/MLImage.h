//
//  MLImage.h
//  Magic Lantern
//
//  Created by Allan Hsu on 5/21/05.
//  Copyright 2005 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <QuartzCore/QuartzCore.h>

@interface MLImage : NSObject {
	NSString *imagePath;

	float scaleFactor;
	float rotation;
		
	NSData *imageData;
	CIImage *image;
	CIImageAccumulator *imageAccum;
	CGSize maxSize;
}

- (id)initFromFilePath:(NSString *)filePath;

- (void)rotateByDegrees:(float)degrees;


- (void)setAvailableSize:(CGSize)newSize;
- (CGSize)maxImageSizeForAvailableSize;

- (CIImage *)transformedImage;
- (CIImage *)processedImage;
- (void)accumulateImage:(CIImage *)newAccumImage;

- (void)loadDataIfNeeded;

- (NSString *)path;
- (NSData *)imageData;
- (CIImage *)image;

- (NSComparisonResult)finderCompare:(MLImage *)otherImage;
@end
