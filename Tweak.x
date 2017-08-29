#import "headers.h"
#import "NUADrawerController.h"
#import "NUAPreferenceManager.h"

%hook SBUIController
- (BOOL)clickedMenuButton {
    [[NUADrawerController sharedInstance] dismissDrawer];
    return %orig;
}

- (BOOL)handleHomeButtonSinglePressUp {
    [[NUADrawerController sharedInstance] dismissDrawer];
    return %orig;
}
%end

static inline void dismissForLock(CFNotificationCenterRef center, void *observer, CFStringRef name, const void *object, CFDictionaryRef userInfo) {
    [[NUADrawerController sharedInstance] dismissDrawer];
}

static inline void initializeTweak(CFNotificationCenterRef center, void *observer, CFStringRef name, const void *object, CFDictionaryRef userInfo) {
    SBScreenEdgePanGestureRecognizer *recognizer = [[%c(SBScreenEdgePanGestureRecognizer) alloc] initWithTarget:[NUADrawerController sharedInstance] action:@selector(handleShowDrawerGesture:) type:SBSystemGestureTypeShowNotificationCenter];
    recognizer.edges = UIRectEdgeTop;
    [[%c(SBSystemGestureManager) mainDisplayManager] addGestureRecognizer:recognizer withType:50];
}

%ctor {
    CFNotificationCenterAddObserver(CFNotificationCenterGetDarwinNotifyCenter(), NULL, &initializeTweak, CFSTR("SBSpringBoardDidLaunchNotification"), NULL, CFNotificationSuspensionBehaviorDeliverImmediately);
    CFNotificationCenterAddObserver(CFNotificationCenterGetDarwinNotifyCenter(), NULL, &dismissForLock, CFSTR("com.apple.springboard.lockcomplete"), NULL, CFNotificationSuspensionBehaviorDeliverImmediately);
    [NUAPreferenceManager sharedSettings];
}
