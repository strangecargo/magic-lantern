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

	NSAffineTransform *transform;
	NSSize targetRectSize;
	
	NSData *imageData;
	CIImage *image;
	CIImageAccumulator *imageAccum;
}

- (id)initFromFilePath:(NSString *)filePath;
- (NSString *)path;

- (NSAffineTransform *)transformation;
- (NSSize)targetRectSize;
- (void)setTargetRectSize:(NSSize)size;
- (CGSize)maxImageSizeForAvailableSize:(CGSize)availableSize;
- (CIImage *)transformedImage;
- (CIImage *)processedImage;
- (void)accumulateImage:(CIImage *)newAccumImage;

- (void)loadDataIfNeeded;
- (NSData *)imageData;
- (CIImage *)image;

- (NSComparisonResult)finderCompare:(MLImage *)otherImage;
@end
