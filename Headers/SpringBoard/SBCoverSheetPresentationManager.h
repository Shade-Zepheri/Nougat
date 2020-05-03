@class SBCoverSheetPrimarySlidingViewController;

@interface SBCoverSheetPresentationManager : NSObject
@property (nonatomic,retain) SBCoverSheetPrimarySlidingViewController *coverSheetSlidingViewController;

+ (instancetype)sharedInstance;

@end