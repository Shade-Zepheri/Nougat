#import "NUANotificationCenterInhibitor.h"
#import <UIKit/UIKit.h>

BOOL overrideNC = NO;

@implementation NUANotificationCenterInhibitor : NSObject
+ (void)setInhibited:(BOOL)value {
    overrideNC = value;
}

+ (BOOL)isInhibited {
    return overrideNC;
}
@end

//not sure if even needed
%hook SBNotificationCenterController
- (void)presentAnimated:(BOOL)arg1 {
  	if (!overrideNC) {
  	   return;
  	}
  	%orig;
}

- (void)presentAnimated:(BOOL)arg1 presentationType:(long long)arg2 completion:(/*^block*/id)arg3 {
    if (!overrideNC) {
        return;
    }
    %orig;
}

- (void)_showNotificationCenterGestureBeganWithGestureRecognizer:(id)arg1 {
    if (!overrideNC) {
        return;
    }
    %orig;
}
%end
