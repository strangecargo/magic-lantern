//
//  MLImageCollection.h
//  Magic Lantern
//
//  Created by Allan Hsu on 8/28/05.
//  Copyright 2005 Allan Hsu. All rights reserved.
//

#import <Cocoa/Cocoa.h>

#import "MLImage.h"

@protocol MLImageCollection

- (id)initWithPath:(NSString *)path;

- (MLImage *)currentImage;
- (BOOL)hasPrevImage;
- (BOOL)hasNextImage;
- (MLImage *)prevImage;
- (MLImage *)nextImage;
- (MLImage *)imageAtIndex:(unsigned int)index;

- (unsigned int)count;
- (unsigned int)index;
- (void)setIndex:(unsigned int)newIndex;

@end
