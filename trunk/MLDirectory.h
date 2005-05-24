//
//  MLDirectory.h
//  Magic Lantern
//
//  Created by Allan Hsu on 5/21/05.
//  Copyright 2005 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "MLImage.h"

@interface MLDirectory : NSObject {
	unsigned int imageIndex;
	NSMutableArray *images;
	NSString *dirPath;
}

- (id)initWithPath:(NSString *)path;
- (id)initWithFiles:(NSArray *)fileArray;
- (void)loadDirectory;
- (void)loadFromArray:(NSArray *)fileArray;

- (MLImage *)currentImage;
- (BOOL)hasPrevImage;
- (BOOL)hasNextImage;
- (MLImage *)prevImage;
- (MLImage *)nextImage;

- (NSArray *)images;

- (unsigned int)count;
- (unsigned int)index;
- (void)setIndex:(unsigned int)newIndex;

@end
