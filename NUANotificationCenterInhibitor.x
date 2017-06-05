#import "NUANotificationCenterInhibitor.h"
#import "headers.h"

@implementation NUANotificationCenterInhibitor

+ (void)setInhibited:(BOOL)value {
    [[%c(SBSystemGestureManager) mainDisplayManager] setSystemGesturesDisabledForAccessibility:value];
}

+ (BOOL)isInhibited {
    return [[%c(SBSystemGestureManager) mainDisplayManager] areSystemGesturesDisabledForAccessibility];
}

@end
