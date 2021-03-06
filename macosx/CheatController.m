//
//  CheatController.m
//  Pcsxr
//

#import <Cocoa/Cocoa.h>
#include "psxcommon.h"
#include "cheat.h"
#import "CheatController.h"
#import "ARCBridge.h"

@implementation CheatController

- (id)init
{
	self = [self initWithWindowNibName:@"CheatWindow"];
	return self;
}

- (void)refresh
{
	[cheatView reloadData];
}

- (NSInteger)numberOfRowsInTableView:(NSTableView *)view
{
    return NumCheats;
}

- (id)tableView:(NSTableView *)tableView objectValueForTableColumn:(NSTableColumn *)col row:(NSInteger)idx
{
    if (idx >= NumCheats)
        return nil;
    NSString *ident = [col identifier];
    if ([ident isEqualToString:@"COL_NAME"]) {
        return [NSString stringWithCString:Cheats[idx].Descr encoding:NSUTF8StringEncoding];
    }
    if ([ident isEqualToString:@"COL_ENABLE"]) {
        return [NSNumber numberWithInt: Cheats[idx].Enabled ? NSOnState : NSOffState];
    }
    NSLog(@"Unknown column identifier: %@", ident);
    return nil;
}

- (void)tableView:(NSTableView *)tableView setObjectValue:(id)object forTableColumn:(NSTableColumn *)col row:(NSInteger)row
{
    if (row >= NumCheats)
        return;
    NSString *ident = [col identifier];
    if ([ident isEqualToString:@"COL_ENABLE"]) {
        Cheats[row].Enabled = [object integerValue] == NSOnState;
    }
}

- (IBAction)LoadCheats:(id)sender
{
    NSOpenPanel *openDlg = RETAINOBJ([NSOpenPanel openPanel]);
    [openDlg setCanChooseFiles:YES];
    [openDlg setCanChooseDirectories:NO];
    
    if ([openDlg runModal] == NSFileHandlingPanelOKButton) {
        NSArray *files = [openDlg URLs];
		for (NSURL *theURL in files) {
			LoadCheats([[theURL path] fileSystemRepresentation]);
		}
        [self refresh];
    }
    RELEASEOBJ(openDlg);
}

- (IBAction)SaveCheats:(id)sender
{
    NSSavePanel *saveDlg = RETAINOBJ([NSSavePanel savePanel]);
    [saveDlg setPrompt:NSLocalizedString(@"Save Cheats", nil)];
    if ([saveDlg runModal] == NSFileHandlingPanelOKButton) {
        NSURL *url = [saveDlg URL];
        SaveCheats((const char *)[[url path] fileSystemRepresentation]);
    }
    RELEASEOBJ(saveDlg);
}

- (IBAction)clear:(id)sender
{
    ClearAllCheats();
    [self refresh];
}

- (IBAction)close:(id)sender
{
    [[self window] close];
}

@end
