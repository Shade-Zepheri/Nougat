#import "NUANotificationCenterInhibitor.h"
#import <SpringBoard/SBSystemGestureManager.h>

static BOOL _inhibited = NO;

@implementation NUANotificationCenterInhibitor

+ (void)setInhibited:(BOOL)inhibited {
    _inhibited = inhibited;
    ((SBSystemGestureManager *)[%c(SBSystemGestureManager) mainDisplayManager]).systemGesturesDisabledForAccessibility = inhibited;
}

+ (BOOL)inhibited {
    return _inhibited;
}

@end
