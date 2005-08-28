//
//  MLDirectory.m
//  Magic Lantern
//
//  Created by Allan Hsu on 5/21/05.
//  Copyright 2005 __MyCompanyName__. All rights reserved.
//

#import "MLDirectory.h"
#import "Utility.h"


@implementation MLDirectory

- (id)initWithPath:(NSString *)path {
	self = [super init];
	
	if(self) {		
		NSFileManager *fileMan = [NSFileManager defaultManager];
		BOOL isDir = NO;
		
		if([fileMan fileExistsAtPath:path isDirectory:&isDir]) {
			dirPath = [path stringByDeletingLastPathComponent];
		} else {
			isDir = YES;
			if([fileMan fileExistsAtPath:path isDirectory:&isDir])
				dirPath = path;
		}

		[self loadDirectory];
		
		imageIndex = 0;

		if(!isDir) {
			unsigned int i;
			
			for(i = 0; i < [images count]; i++) {
				MLImage *image = [images objectAtIndex:i];
				if([[image path] isEqualToString:path]) {
					imageIndex = i;
					break;
				}
			}
		}
		
		[dirPath retain];
	}
	
	return(self);
}

- (id)initWithFiles:(NSArray *)fileArray {
	self = [super init];
	
	if(self) {
		dirPath = nil;
		imageIndex = 0;
		[self loadFromArray:fileArray];
	}
	
	return(self);
}

- (void)dealloc {
	NSLog(@"Deallocating MLDirectory.");
	
	if(dirPath != nil) {
		[dirPath release];
	}
	[images release];
	
	[super dealloc];
}

- (void)loadDirectory {
	NSFileManager *fileMan = [NSFileManager defaultManager];
	NSArray *allFiles = [fileMan directoryContentsAtPath:dirPath];
	
	[self loadFromArray:allFiles];
}

- (void)loadFromArray:(NSArray *)fileArray {
	NSArray *fileTypes = [Utility GetDocumentExtensions];
	images = [[NSMutableArray alloc] initWithCapacity:23];
	
	unsigned int i;
	
	for(i = 0; i < [fileArray count]; i++) {
		NSString *fileName = [fileArray objectAtIndex:i];
		NSString *extension = [[fileName pathExtension] lowercaseString];
		
		if([fileTypes containsObject:extension]) {
			NSString *fullFilePath = fileName;
			if(dirPath != nil)
				fullFilePath = [dirPath stringByAppendingFormat:@"/%@", fileName];
			MLImage *image = [[MLImage alloc] initFromFilePath:fullFilePath];
			[images addObject:image];
			
			[image release]; //image is retained by the images array.
		}
	}
	
	[images sortUsingSelector:@selector(finderCompare:)];	
}

- (BOOL)hasPrevImage {
	return(imageIndex > 0 && [images count] > 0);
}

- (BOOL)hasNextImage {
	return(imageIndex < [images count] - 1);
}

- (MLImage *)currentImage {
	return([images objectAtIndex:imageIndex]);
}

- (MLImage *)prevImage {
	if([self hasPrevImage]) {
		imageIndex--;
		return([self currentImage]);
	}
	
	return(nil);
}

- (MLImage *)nextImage {
	if([self hasNextImage]) {
		imageIndex++;
		return([self currentImage]);
	}
	
	return(nil);
}

- (MLImage *)imageAtIndex:(unsigned int)index {
	return([images objectAtIndex:index]);
}

- (unsigned int)count {
	return([images count]);
}

- (unsigned int)index {
	return(imageIndex);
}

- (void)setIndex:(unsigned int)newIndex {
	imageIndex = newIndex;
}

@end
