//
//  MLImageWindowController.h
//  Magic Lantern
//
//  Created by Allan Hsu on 5/19/05.
//  Copyright 2005 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "MLImageView.h"
#import "MLDirectory.h"
#import "MLFullScreenWindow.h"

@interface MLImageWindowController : NSWindowController {

	MLDirectory *directory;
	IBOutlet MLImageView *imageView;
	
	//full screen craps.
	BOOL fullScreenMode;
	NSWindow *normalWindow;
	MLFullScreenWindow *fullScreenWindow;
	MLImageView *fullScreenImageView;
}

- (id)initWithPath:(NSString *)path;
- (id)initWithFiles:(NSArray *)fileNames;

- (void)rotateCCW;
- (void)rotateCW;

- (BOOL)hasPrevImage;
- (BOOL)hasNextImage;
- (void)prevImage;
- (void)nextImage;

- (MLImageView *)activeImageView;
- (void)updateViewWithImage:(MLImage *)newImage;
- (void)updateSizeAndScale;

- (BOOL)isFullScreen;
- (void)toggleFullScreen;
- (void)goFullScreen;
- (void)returnFromFullScreen;
@end
