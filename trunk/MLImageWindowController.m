//
//  MLImageWindowController.m
//  Magic Lantern
//
//  Created by Allan Hsu on 5/19/05.
//  Copyright 2005 __MyCompanyName__. All rights reserved.
//

#import <Carbon/Carbon.h>
#import <time.h>
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
		
		stopPreload = NO;
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
	
	[NSThread detachNewThreadSelector:@selector(preloadThread:) toTarget:self withObject:nil];
}

- (void)windowWillClose:(NSNotification *)aNotification {
	if(!fullScreenMode) {
		stopPreload = YES;
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
		[currentImage rotateByDegrees:90.0];
		[self updateViewWithImage:currentImage];
	}
}

- (void)rotateCW {
	MLImage *currentImage = [directory currentImage];
	
	if(currentImage != nil) {				
		[currentImage rotateByDegrees:-90.0];
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

- (CGSize)visibleContentCGSize {
	NSRect visibleFrame = fullScreenMode ? [[NSScreen mainScreen] frame] : [[NSScreen mainScreen] visibleFrame];
	NSRect visibleContentRect = [[self window] contentRectForFrameRect:visibleFrame];
	
	CGSize visibleContentSize;
	visibleContentSize.height = visibleContentRect.size.height;
	visibleContentSize.width = visibleContentRect.size.width;

	return(visibleContentSize);
}

- (MLImageView *)activeImageView {
	return(fullScreenMode ? fullScreenImageView : imageView);
}

- (void)updateViewWithImage:(MLImage *)newImage {
	if(newImage != nil) {		
		MLImageView *activeView = [self activeImageView];
		[[self window] setTitle:[[newImage path] lastPathComponent]];
		
		[newImage lock];
		[newImage setAvailableSize:[self visibleContentCGSize]];
		[activeView setImage:newImage];
		[self updateWindowFrameForImage:newImage];
		[newImage unlock];
		
		[activeView setNeedsDisplay:YES];
	}
}

- (void)updateWindowFrameForImage:(MLImage *)image {
	NSWindow *window = [self window];
	NSRect currentContentRect = [window contentRectForFrameRect:[window frame]];
	
	CGSize newContentSize = [image scaledImageSizeForAvailableSize];
	NSRect newContentRect = NSMakeRect(NSMinX(currentContentRect), NSMaxY(currentContentRect) - newContentSize.height, newContentSize.width, newContentSize.height);

	if(!fullScreenMode) {
		newContentRect.size.width = floor(newContentRect.size.width);
		newContentRect.size.height = floor(newContentRect.size.height);
		[window setFrame:[window frameRectForContentRect:newContentRect] display:YES animate:NO];
	}
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

//threading junks

- (void)renderImage:(MLImage *)image forSize:(CGSize)size{
	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
	[image lock];
					
	[image setAvailableSize:size];
	
	if([image shouldPreRender]) {
		NSLog(@"Preloading %@", [image path]);
		CIImage *ciImage = [image processedImage];
	
		NSImageView *preloadView = [preloadWindow contentView];
		[preloadView lockFocus];
	
		NSGraphicsContext *nsContext = [NSGraphicsContext currentContext];	
		CIContext *ciContext = [nsContext CIContext];
		if(nsContext == nil) NSLog(@"current context nil");
	
		//yeeeeah. this isn't in the header. but it *is* in the nm output!
		[image accumulateToRenderCache:ciImage];
		[ciContext render:[image renderCacheImage]];

		[preloadView unlockFocus];
		NSLog(@"Preloaded.");		
	}
	
	[image unlock];
	[pool release];
}

- (void)preloadThread:(id)arg {
	int i = 0;
	struct timespec sleep_interval;
	sleep_interval.tv_sec = 0;
	sleep_interval.tv_nsec = 250000000;
	
	CGSize mostRecentVisibleSize = [self visibleContentCGSize];
	NSArray *images = [directory images];
	int centerIndex = [directory index];
	
	NSLog(@"preload thread started.");
	
	while(!stopPreload) {
		i++;
		BOOL withinBounds = NO;
		int currentIndex = i + centerIndex;
		
		if(currentIndex < [directory count]) {
			CGSize visibleSize = [self visibleContentCGSize];
			if(visibleSize.height != mostRecentVisibleSize.height || visibleSize.width != mostRecentVisibleSize.width)
				goto reset_loop;
			[self renderImage:[images objectAtIndex:currentIndex] forSize:visibleSize];
			withinBounds = YES;
		}
		
		currentIndex = centerIndex - i;
		if(currentIndex > 0) {
			CGSize visibleSize = [self visibleContentCGSize];
			if(visibleSize.height != mostRecentVisibleSize.height || visibleSize.width != mostRecentVisibleSize.width)
				goto reset_loop;
			[self renderImage:[images objectAtIndex:currentIndex] forSize:visibleSize];
			withinBounds = YES;
		}
		
		if(!withinBounds) {
			nanosleep(&sleep_interval, NULL);
			
			CGSize visibleSize = [self visibleContentCGSize];
			if(visibleSize.height != mostRecentVisibleSize.height || visibleSize.width != mostRecentVisibleSize.width)
				goto reset_loop;			
		}
		continue;
		
reset_loop:
		NSLog(@"resetting preload loop.");
		i = 0;
		centerIndex = [directory index];
		mostRecentVisibleSize = [self visibleContentCGSize];
	}
	
	NSLog(@"preload thread exiting.");
	//[NSThread exit];
}

@end
