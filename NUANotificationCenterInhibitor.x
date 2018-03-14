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
