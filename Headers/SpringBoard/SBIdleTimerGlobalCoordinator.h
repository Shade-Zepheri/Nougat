#import <BaseBoard/BSInvalidatable.h>

@interface SBIdleTimerGlobalCoordinator : NSObject

+ (instancetype)sharedInstance;

- (id<BSInvalidatable>)acquireIdleTimerDisableAssertionForReason:(NSString *)reason;

@end