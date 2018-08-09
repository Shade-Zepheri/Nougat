#import "SBDashBoardIdleBehaviorProviding.h"

@protocol SBDashBoardBehaviorProviding <NSObject, SBDashBoardIdleBehaviorProviding>
@property (nonatomic, readonly) NSInteger scrollingStrategy; 
@property (nonatomic, readonly) NSInteger notificationBehavior; 
@property (nonatomic, readonly) NSUInteger restrictedCapabilities; 
@property (nonatomic, readonly) NSInteger proximityDetectionMode; 

@required
- (NSInteger)scrollingStrategy;
- (NSInteger)proximityDetectionMode;
- (NSUInteger)restrictedCapabilities;
- (NSInteger)notificationBehavior;

@end