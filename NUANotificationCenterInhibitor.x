#import "NUANotificationCenterInhibitor.h"
#import <UIKit/UIKit.h>

@implementation NUANotificationCenterInhibitor

+ (void)setInhibited:(BOOL)value {
    [[%c(SBSystemGestureManager) mainDisplayManager] setSystemGesturesDisabledForAccessibility:value];
}

+ (BOOL)isInhibited {
    [[%c(SBSystemGestureManager) mainDisplayManager] areSystemGesturesDisabledForAccessibility];
}

@end
