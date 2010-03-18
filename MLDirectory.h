//
//  MLDirectory.h
//  Magic Lantern
//
//  Created by Allan Hsu on 5/21/05.
//  Copyright 2005 Allan Hsu. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "MLImageCollection.h"
#import "MLImage.h"

@interface MLDirectory : NSObject <MLImageCollection> {
	unsigned int imageIndex;
	NSMutableArray *images;
	NSString *dirPath;
}

- (id)initWithPath:(NSString *)path;
- (id)initWithFiles:(NSArray *)fileArray;
- (void)loadDirectory;
- (void)loadFromArray:(NSArray *)fileArray;

@end
