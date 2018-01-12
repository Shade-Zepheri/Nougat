#import "headers.h"
#import "NUADrawerController.h"
#import "NUAPreferenceManager.h"

%hook SBUIController
- (BOOL)clickedMenuButton {
    [[NUADrawerController sharedInstance] dismissDrawer:YES];
    return %orig;
}

- (BOOL)handleHomeButtonSinglePressUp {
    [[NUADrawerController sharedInstance] dismissDrawer:YES];
    return %orig;
}
%end

static inline void initializeTweak(CFNotificationCenterRef center, void *observer, CFStringRef name, const void *object, CFDictionaryRef userInfo) {
    SBScreenEdgePanGestureRecognizer *recognizer = [[%c(SBScreenEdgePanGestureRecognizer) alloc] initWithTarget:[NUADrawerController sharedInstance] action:@selector(handleShowDrawerGesture:) type:SBSystemGestureTypeShowNotificationCenter];
    recognizer.edges = UIRectEdgeTop;
    [[%c(SBSystemGestureManager) mainDisplayManager] addGestureRecognizer:recognizer withType:50];
}

%ctor {
    CFNotificationCenterAddObserver(CFNotificationCenterGetDarwinNotifyCenter(), NULL, &initializeTweak, CFSTR("SBSpringBoardDidLaunchNotification"), NULL, CFNotificationSuspensionBehaviorDeliverImmediately);
    [NUAPreferenceManager sharedSettings];
}
