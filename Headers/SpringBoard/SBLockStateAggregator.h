@interface SBLockStateAggregator : NSObject

+ (instancetype)sharedInstance;

- (BOOL)hasAnyLockState;

@end