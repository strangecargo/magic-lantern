#import "MLMainController.h"
#import "MLImageWindowController.h"
#import "Utility.h"

@implementation MLMainController

- (IBAction)menuOpenFile:(id)sender{	
	NSOpenPanel *openPanel = [NSOpenPanel openPanel];
	[openPanel setAllowsMultipleSelection:YES];
	
	if([openPanel runModalForTypes:[Utility GetDocumentExtensions]] == NSOKButton) {
		NSArray *filenames = [openPanel filenames];
		
		if([filenames count] == 1) {
			[self openSingleFile:[filenames objectAtIndex:0]];
		} else if([filenames count] > 1) {
			[self openFileArray:filenames];
		}
	}
}

- (BOOL)validateMenuItem:(NSMenuItem *)anItem {
	NSWindow *keyWindow = [[NSApplication sharedApplication] keyWindow];
	NSWindowController *wc = [keyWindow windowController];

	if(anItem == openFileMenuItem) return(YES);

	if([wc isMemberOfClass:[MLImageWindowController class]]) {
		MLImageWindowController *iwc = wc;
		if(anItem == nextImageMenuItem) {
			return([iwc hasNextImage]);
		} else if(anItem == prevImageMenuItem) {
			return([iwc hasPrevImage]);
		} else if(anItem == rotateCCWMenuItem || anItem == rotateCWMenuItem) {
			return(YES);
		} else if(anItem == fullScreenMenuItem) {
			[fullScreenMenuItem setState:([iwc isFullScreen] ? NSOnState : NSOffState)];
			return(YES);
		}
	}
	
	return(NO);
}

- (IBAction)menuRotateCCW:(id)sender {
	NSWindow *keyWindow = [[NSApplication sharedApplication] keyWindow];
	NSWindowController *wc = [keyWindow windowController];
	if([wc isMemberOfClass:[MLImageWindowController class]]) {
		[(MLImageWindowController *)wc rotateCCW];
	}	
}

- (IBAction)menuRotateCW:(id)sender {
	NSWindow *keyWindow = [[NSApplication sharedApplication] keyWindow];
	NSWindowController *wc = [keyWindow windowController];
	if([wc isMemberOfClass:[MLImageWindowController class]]) {
		[(MLImageWindowController *)wc rotateCW];
	}	
}

- (IBAction)menuPrevImage:(id)sender {
	NSWindow *keyWindow = [[NSApplication sharedApplication] keyWindow];
	NSWindowController *wc = [keyWindow windowController];
	if([wc isMemberOfClass:[MLImageWindowController class]]) {
		[(MLImageWindowController *)wc prevImage];
	}
}

- (IBAction)menuNextImage:(id)sender {
	NSWindow *keyWindow = [[NSApplication sharedApplication] keyWindow];
	NSWindowController *wc = [keyWindow windowController];
	if([wc isMemberOfClass:[MLImageWindowController class]]) {
		[(MLImageWindowController *)wc nextImage];
	}	
}

- (IBAction)menuFullScreen:(id)sender {
	NSWindow *keyWindow = [[NSApplication sharedApplication] keyWindow];
	NSWindowController *wc = [keyWindow windowController];
	if([wc isMemberOfClass:[MLImageWindowController class]]) {
		[(MLImageWindowController *)wc toggleFullScreen];
	}		
}

- (BOOL)application:(NSApplication *)sender openFile:(NSString *)filename {
	NSLog(@"openFile called on: ", filename);
	[self openSingleFile:filename];
	return(YES);
}


- (void)application:(NSApplication *)sender openFiles:(NSArray *)filenames {
	NSLog(@"multiple files opened.");
	if([filenames count] == 1) {
		[self openSingleFile:[filenames objectAtIndex:0]];
	} else {
		[self openFileArray:filenames];
	}
	[sender replyToOpenOrPrint:NSApplicationDelegateReplySuccess];
}

- (void)openFileArray:(NSArray *)filenames {
	MLImageWindowController *mlImageWindowController = [[MLImageWindowController alloc] initWithFiles:filenames];
	[mlImageWindowController window];
	[mlImageWindowController showWindow:self];
}

- (void)openSingleFile:(NSString *)filename {
	MLImageWindowController *mlImageWindowController = [[MLImageWindowController alloc] initWithPath:filename];
	[mlImageWindowController window];
	[mlImageWindowController showWindow:self];	
}

@end
