#import "NUANotificationCenterInhibitor.h"
#import "headers.h"

static BOOL inhibited = NO;

@implementation NUANotificationCenterInhibitor

+ (void)setInhibited:(BOOL)value {
    inhibited = value;
}

+ (BOOL)isInhibited {
    return inhibited;
}

@end

%hook SBNotificationCenterController
- (void)beginPresentationWithTouchLocation:(CGPoint)location presentationBegunHandler:(void(^)())handler {
    if (inhibited) {
        return;
    }

    %orig;
}

- (void)_showNotificationCenterGestureBeganWithGestureRecognizer:(UIGestureRecognizer *)recognier {
    if (inhibited) {
        return;
    }

    %orig;
}
%end
