//
//  Utility.m
//  Magic Lantern
//
//  Created by Allan Hsu on 5/21/05.
//  Copyright 2005 __MyCompanyName__. All rights reserved.
//

#import "Utility.h"


@implementation Utility

+ (NSArray *)GetDocumentExtensions {
	NSDictionary *info = [[NSBundle mainBundle] infoDictionary];
	NSEnumerator *enumerator = [[info objectForKey:@"CFBundleDocumentTypes"] objectEnumerator];
	NSMutableArray *fileTypes = [[NSMutableArray alloc] initWithCapacity:10];
	id type;
	
	while(type = [enumerator nextObject]) {
		//add extension
		[fileTypes addObjectsFromArray:[type objectForKey:@"CFBundleTypeExtensions"]];
		
		//add HFS types
		id hfsTypes = [type objectForKey:@"CFBundleTypeOSTypes"];
		id hfsTypesEnum = [hfsTypes objectEnumerator];
		id hfsType;
		
		while(hfsType = [hfsTypesEnum nextObject]) {
			[fileTypes addObject:[NSString stringWithFormat:@"'%@'", hfsType]];
		}
	}
	
	return([fileTypes autorelease]);
}

@end
