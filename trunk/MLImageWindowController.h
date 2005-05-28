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
	IBOutlet NSWindow *preloadWindow;
	
	//full screen craps.
	BOOL fullScreenMode;
	NSWindow *normalWindow;
	MLFullScreenWindow *fullScreenWindow;
	MLImageView *fullScreenImageView;
	
	//threaded preloading
	BOOL stopPreload;
	NSThread *preloadThread;
}

- (id)initWithPath:(NSString *)path;
- (id)initWithFiles:(NSArray *)fileNames;

- (void)rotateCCW;
- (void)rotateCW;

- (BOOL)hasPrevImage;
- (BOOL)hasNextImage;
- (void)prevImage;
- (void)nextImage;

- (CGSize)visibleContentCGSize;
- (MLImageView *)activeImageView;
- (void)updateViewWithImage:(MLImage *)newImage;
- (void)updateWindowFrameForImage:(MLImage *)imag;

- (BOOL)isFullScreen;
- (void)toggleFullScreen;
- (void)goFullScreen;
- (void)returnFromFullScreen;

- (void)renderImage:(MLImage *)image forSize:(CGSize)size;
- (void)renderImageUsingBitmapContext:(MLImage *)image forSize:(CGSize)size;
- (void)renderImageUsingWindowContext:(MLImage *)image forSize:(CGSize)size;
- (void)preloadThread:(id)arg;
@end
