//
//  MLRarArchive.h
//  Magic Lantern
//
//  Created by Allan Hsu on 8/28/05.
//  Copyright 2005 Allan Hsu. All rights reserved.
//

#import <Cocoa/Cocoa.h>

#import <unrar/unrar.h>

#import "MLImageCollection.h"

@interface MLRarArchive : NSObject <MLImageCollection> {
	NSMutableArray *imageNames;
	NSMutableDictionary *imageCache;
	unsigned int imageIndex;
}

- (id)initWithPath:(NSString *)path;

@end
