#import <Foundation/Foundation.h>

// Not sure if this actually exists, but imma declare it
@protocol SBUIFlashlightObserver <NSObject>

- (void)flashlightAvailabilityDidChange:(BOOL)available;
- (void)flashlightLevelDidChange:(CGFloat)newLevel;

@optional

- (void)flashlightOverheatedDidChange:(BOOL)overheated;

@end

@interface SBUIFlashlightController : NSObject

+ (instancetype)sharedInstance;

- (void)addObserver:(id<SBUIFlashlightObserver>)observer;
- (void)removeObserver:(id<SBUIFlashlightObserver>)observer;

@end