//
//  MLImageWindowController.m
//  Magic Lantern
//
//  Created by Allan Hsu on 5/19/05.
//  Copyright 2005 __MyCompanyName__. All rights reserved.
//

#import <Carbon/Carbon.h>
#import "MLImageWindowController.h"
#import "MLImage.h"


@implementation MLImageWindowController

- (id)initWithPath:(NSString *)path {
	self = [super initWithWindowNibName:@"ImageWindow"];

	if(self) {
		fullScreenMode = NO;
		fullScreenWindow = nil;
		fullScreenImageView = nil;
		
		directory = [[MLDirectory alloc] initWithPath:path];
	}
	
	return(self);
}

- (id)initWithFiles:(NSArray *)fileNames {
	self = [super initWithWindowNibName:@"ImageWindow"];
	
	if(self) {
		fullScreenMode = NO;
		fullScreenWindow = nil;
		fullScreenImageView = nil;
		
		directory = [[MLDirectory alloc] initWithFiles:fileNames];
	}
	
	return(self);
}

- (void)dealloc {
	NSLog(@"MLImageWindowController dealloc.");
	[directory release];
	
	[super dealloc];
}

- (void)windowDidLoad {
	[self updateViewWithImage:[directory currentImage]];	
}

- (void)windowWillClose:(NSNotification *)aNotification {
	if(!fullScreenMode) {
		[self autorelease];
	}
}

-(void)cancel:(id)sender {
	if(fullScreenMode) [self returnFromFullScreen];
}

- (void)keyDown:(NSEvent *)theEvent {
	NSString *eventChars = [theEvent characters];

	switch([eventChars characterAtIndex:0]) {
		case NSUpArrowFunctionKey:
		case NSLeftArrowFunctionKey:
			[self prevImage];
			break;
		case NSRightArrowFunctionKey:
		case NSDownArrowFunctionKey:
			[self nextImage];
			break;
		default: break;
	}	
}

- (void)flagsChanged:(NSEvent *)theEvent {
	if([theEvent modifierFlags] & NSShiftKeyMask) {
		NSLog(@"shift modifierflag changed.");
	}
}

- (void)rotateCCW {
	MLImage *currentImage = [directory currentImage];
	
	if(currentImage != nil) {
		NSAffineTransform *transform = [currentImage transformation];
	
		[transform rotateByDegrees:90.0];
		[self updateViewWithImage:currentImage];
	}
}

- (void)rotateCW {
	MLImage *currentImage = [directory currentImage];
	
	if(currentImage != nil) {
		NSAffineTransform *transform = [currentImage transformation];
				
		[transform rotateByDegrees:-90.0];
		[self updateViewWithImage:currentImage];
	}
}

- (BOOL)hasPrevImage {
	return([directory hasPrevImage]);
}

- (BOOL)hasNextImage {
	return([directory hasNextImage]);
}

- (void)prevImage {
	if([directory hasPrevImage]) {
		[self updateViewWithImage:[directory prevImage]];
	}
}

- (void)nextImage {
	if([directory hasNextImage]) {
		[self updateViewWithImage:[directory nextImage]];
	}
}

- (MLImageView *)activeImageView {
	return(fullScreenMode ? fullScreenImageView : imageView);
}

- (void)updateViewWithImage:(MLImage *)newImage {
	if(newImage != nil) {
		MLImageView *activeView = [self activeImageView];
		[[self window] setTitle:[[newImage path] lastPathComponent]];
		[activeView setImage:newImage];
		[self updateWindowFrame];
		[activeView setNeedsDisplay:YES];
	}
}

- (void)updateWindowFrame {
	NSWindow *window = [self window];
	MLImage *currentImage = [directory currentImage];
	
	NSRect visibleFrame = fullScreenMode ? [[NSScreen mainScreen] frame] : [[NSScreen mainScreen] visibleFrame];
	NSRect currentContentRect = [window contentRectForFrameRect:[window frame]];
	NSRect visibleContentRect = [window contentRectForFrameRect:visibleFrame];
	
	CGSize visibleContentSize;
	visibleContentSize.height = visibleContentRect.size.height;
	visibleContentSize.width = visibleContentRect.size.width;

	CGSize newContentSize = [currentImage maxImageSizeForAvailableSize:visibleContentSize];
	NSRect newContentRect = NSMakeRect(NSMinX(currentContentRect), NSMaxY(currentContentRect) - newContentSize.height, newContentSize.width, newContentSize.height);
	[currentImage setTargetRectSize:newContentRect.size];

	if(!fullScreenMode)
		[window setFrame:[window frameRectForContentRect:newContentRect] display:YES animate:NO];
}

- (BOOL)isFullScreen {
	return(fullScreenMode);
}

- (void)toggleFullScreen {
	if(fullScreenMode)
		[self returnFromFullScreen];
	else
		[self goFullScreen];
}

- (void)goFullScreen {
	NSLog(@"going full screen...");
	fullScreenMode = YES;
	
	NSScreen *thisScreen = [NSScreen mainScreen];
	NSScreen *zeroScreen = [[NSScreen screens] objectAtIndex:0];
	
	NSRect screenFrame = [thisScreen frame];
	//to make multiple displays behave.
	screenFrame.origin.x = 0;
	screenFrame.origin.y = 0;
	
	normalWindow = [[self window] retain];
	[normalWindow orderOut:self];
	
	fullScreenWindow = [[MLFullScreenWindow alloc] initWithContentRect:screenFrame
												   styleMask:NSBorderlessWindowMask
													 backing:NSBackingStoreBuffered
													   defer:NO
													  screen:thisScreen];
	[fullScreenWindow setDelegate:self];
	fullScreenImageView = [[MLImageView alloc] initWithFrame:screenFrame];
	[fullScreenImageView setCenterImage:YES];
	
	[fullScreenWindow setContentView:fullScreenImageView];
	[fullScreenWindow setBackgroundColor:[NSColor blackColor]];

	[self setWindow:fullScreenWindow];
	[fullScreenWindow makeKeyAndOrderFront:self];
	
	if(thisScreen == zeroScreen)
		SetSystemUIMode(kUIModeAllHidden, 0);
	
	[self updateViewWithImage:[directory currentImage]];
	[NSCursor hide];
}

- (void)returnFromFullScreen {
	NSLog(@"returning from full screen...");
	[fullScreenWindow close];
	
	fullScreenMode = NO;
	[self setWindow:normalWindow];
				
	SetSystemUIMode(kUIModeNormal, 0);
	
	[self updateViewWithImage:[directory currentImage]];
	[self showWindow:self];
	[NSCursor unhide];	
	
	[fullScreenWindow release];
	[fullScreenImageView release];
}

@end
