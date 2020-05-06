#import <SpringBoard/SBLockScreenManager.h>

// Really dumbed down
@protocol SBLockScreenBehaviorSuppressing <NSObject>
@required

- (BOOL)suppressesBanners;
- (BOOL)suppressesControlCenter;
- (BOOL)suppressesScreenshots;

@end

@protocol SBLockScreenEnvironment <NSObject>
@property (readonly, nonatomic) id<SBLockScreenBehaviorSuppressing> behaviorSuppressor;

@required

- (id<SBLockScreenBehaviorSuppressing>)behaviorSuppressor;

@end

@class SBDashBoardViewController, CSCoverSheetViewController;

@interface SBLockScreenManager ()
@property (readonly, nonatomic) SBDashBoardViewController *dashBoardViewController;
@property (readonly, nonatomic) CSCoverSheetViewController *coverSheetViewController;
@property (readonly, nonatomic) id<SBLockScreenEnvironment> lockScreenEnvironment; // iOS 13

@end