//
//  MLRarArchive.m
//  Magic Lantern
//
//  Created by Allan Hsu on 8/28/05.
//  Copyright 2005 Allan Hsu. All rights reserved.
//

#import "MLRarArchive.h"

#import "Utility.h"

@implementation MLRarArchive

- (id)initWithPath:(NSString *)path {
	self = [super init];
	if(self) {
		NSFileManager *fileMan = [NSFileManager defaultManager];
		if(![fileMan fileExistsAtPath:path]) {
			[self release];
			return(nil);
		}
		/*
		imageNames = [[NSMutableArray alloc] init];
		imageCache = [[NSMutableDictionary alloc] init];
		
		ArchiveList_struct *archiveList;
		NSData *archiveData = [NSData dataWithContentsOfMappedFile:path];
		
		memoryFile.data = (void *)[archiveData bytes];
		memoryFile.size = [archiveData length];
		memoryFile.offset = 0;
		
		urarlib_list(&memoryFile, (ArchiveList_struct *)&archiveList);
		
		NSArray *fileTypes = [Utility GetDocumentExtensions];
		ArchiveList_struct *list = archiveList;
		while(list != NULL) {
			NSString *fileName = [NSString stringWithUTF8String:list->item.Name];
			if([fileTypes containsObject:[[fileName pathExtension] lowercaseString]])
				[imageNames addObject:fileName];
			
			list = list->next;
		}
		
		urarlib_freelist(archiveList);
		 */
	}
	
	return(self);
}

//
// MLImageCollection implementation;
//

- (MLImage *)currentImage {
	return([self imageAtIndex:imageIndex]);
}

- (BOOL)hasPrevImage {
	return(imageIndex > 0 && [imageNames count] > 0);
}

- (BOOL)hasNextImage {
	return(imageIndex < [imageNames count] - 1);
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
	NSString *imageName = [imageNames objectAtIndex:index];
	MLImage *image = [imageCache objectForKey:imageName];
	if(image == nil) {
		/*
		unsigned long fileSize;
		void *fileContents;
		char *argle = [imageName UTF8String];
		int blargle = urarlib_get(&fileContents, &fileSize, [imageName UTF8String], &memoryFile, NULL);
		NSLog(@"blargle");
		 */
	}
	
	return(image);
}


- (unsigned int)count {
	return([imageNames count]);
}

- (unsigned int)index {
	return(imageIndex);
}

- (void)setIndex:(unsigned int)newIndex {
	imageIndex = newIndex;
}

@end
