/* MLMainController */

#import <Cocoa/Cocoa.h>

@interface MLMainController : NSObject
{
	IBOutlet NSMenuItem *openFileMenuItem;
	
	IBOutlet NSMenuItem *rotateCCWMenuItem;
	IBOutlet NSMenuItem *rotateCWMenuItem;
	
	IBOutlet NSMenuItem *nextImageMenuItem;
	IBOutlet NSMenuItem *prevImageMenuItem;
	IBOutlet NSMenuItem *fullScreenMenuItem;
}

- (void)openSingleFile:(NSString *)filename;
- (void)openFileArray:(NSArray *)filenames;

- (IBAction)menuOpenFile:(id)sender;

- (IBAction)menuRotateCCW:(id)sender;
- (IBAction)menuRotateCW:(id)sender;

- (IBAction)menuPrevImage:(id)sender;
- (IBAction)menuNextImage:(id)sender;
- (IBAction)menuFullScreen:(id)sender;
@end
