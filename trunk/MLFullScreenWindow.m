//
//  MLFullScreenWindow.m
//  Magic Lantern
//
//  Created by Allan Hsu on 5/22/05.
//  Copyright 2005 __MyCompanyName__. All rights reserved.
//

#import "MLFullScreenWindow.h"


@implementation MLFullScreenWindow

- (BOOL)canBecomeKeyWindow {
	return(YES);
}

- (BOOL)canBecomeMainWindow {
	return(YES);
}

@end
