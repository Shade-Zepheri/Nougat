@protocol SBDashBoardIdleBehaviorProviding <NSObject>
@property (readonly, nonatomic) NSInteger idleWarnMode;
@property (readonly, nonatomic) NSInteger idleTimerMode;
@property (readonly, nonatomic) NSInteger idleTimerDuration;

@required

- (NSInteger)idleTimerDuration;
- (NSInteger)idleWarnMode;
- (NSInteger)idleTimerMode;

@end