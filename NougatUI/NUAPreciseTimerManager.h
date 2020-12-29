#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>

@protocol NUAPreciseTimerManagerObserver <NSObject>

- (void)managerUpdatedWithDate:(NSDate *)date;

@end

@interface NUAPreciseTimerManager : NSObject
@property (class, strong, readonly) NUAPreciseTimerManager *sharedManager;

- (void)addObserver:(id<NUAPreciseTimerManagerObserver>)observer;
- (void)removeObserver:(id<NUAPreciseTimerManagerObserver>)observer;

@end