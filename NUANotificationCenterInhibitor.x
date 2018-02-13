#import "NUANotificationCenterInhibitor.h"
#import <SpringBoard/SBSystemGestureManager+Private.h>

static BOOL _inhibited = NO;

@implementation NUANotificationCenterInhibitor

+ (void)setInhibited:(BOOL)inhibited {
    _inhibited = inhibited;
    [%c(SBSystemGestureManager) mainDisplayManager].systemGesturesDisabledForAccessibility = inhibited;
}

+ (BOOL)inhibited {
    return _inhibited;
}

@end

%hook SBNotificationCenterController

- (void)beginPresentationWithTouchLocation:(CGPoint)location presentationBegunHandler:(void(^)())handler {
    if (_inhibited) {
        return;
    }

    %orig;
}

- (void)_showNotificationCenterGestureBeganWithGestureRecognizer:(UIGestureRecognizer *)recognier {
    if (_inhibited) {
        return;
    }

    %orig;
}

%end
