#import "headers.h"
#import "NUADrawerController.h"
#import "NUAPreferenceManager.h"

%hook SpringBoard
- (instancetype)init {
    self = %orig;
    if (self) {
        UIScreenEdgePanGestureRecognizer *screenEdgePan = [[UIScreenEdgePanGestureRecognizer alloc] initWithTarget:[NUADrawerController sharedInstance] action:@selector(handleShowDrawerGesture:)];
        screenEdgePan.edges = UIRectEdgeTop;
        [[%c(FBSystemGestureManager) sharedInstance] addGestureRecognizer:screenEdgePan toDisplay:[%c(FBDisplayManager) mainDisplay]];
    }

    return self;
}
%end

%ctor {
    [NUAPreferenceManager sharedSettings];
}
