#import "headers.h"
#import "NUADrawerController.h"
#import "NUAPreferenceManager.h"

%hook SpringBoard
- (void)applicationDidFinishLaunching:(id)application {
    %orig;

    UIScreenEdgePanGestureRecognizer *screenEdgePan = [[UIScreenEdgePanGestureRecognizer alloc] initWithTarget:[NUADrawerController sharedInstance] action:@selector(handleShowDrawerGesture:)];
    screenEdgePan.edges = UIRectEdgeTop;
    [[%c(FBSystemGestureManager) sharedInstance] addGestureRecognizer:screenEdgePan toDisplay:[%c(FBDisplayManager) mainDisplay]];
}
%end

%ctor {
    [NUAPreferenceManager sharedSettings];
}
