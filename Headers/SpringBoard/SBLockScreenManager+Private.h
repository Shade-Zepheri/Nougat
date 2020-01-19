#import <SpringBoard/SBLockScreenManager.h>

@class SBDashBoardViewController, CSCoverSheetViewController;

@interface SBLockScreenManager ()
@property (readonly, nonatomic) SBDashBoardViewController *dashBoardViewController;
@property (readonly, nonatomic) CSCoverSheetViewController *coverSheetViewController;

@end