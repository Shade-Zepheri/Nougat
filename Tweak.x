#import "headers.h"
#import "NUADrawerController.h"
#import "NUAPreferenceManager.h"

static inline void initializeTweak(CFNotificationCenterRef center, void *observer, CFStringRef name, const void *object, CFDictionaryRef userInfo) {
    UIScreenEdgePanGestureRecognizer *screenEdgePan = [[UIScreenEdgePanGestureRecognizer alloc] initWithTarget:[NUADrawerController sharedInstance] action:@selector(handleShowDrawerGesture:)];
    screenEdgePan.edges = UIRectEdgeTop;
    [[%c(FBSystemGestureManager) sharedInstance] addGestureRecognizer:screenEdgePan toDisplay:[%c(FBDisplayManager) mainDisplay]];
}

%ctor {
    CFNotificationCenterAddObserver(CFNotificationCenterGetDarwinNotifyCenter(), NULL, &initializeTweak, CFSTR("SBSpringBoardDidLaunchNotification"), NULL, CFNotificationSuspensionBehaviorDeliverImmediately);
    [NUAPreferenceManager sharedSettings];
}
