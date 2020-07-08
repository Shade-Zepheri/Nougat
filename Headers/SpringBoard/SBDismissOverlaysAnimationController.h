#import "SBUIAnimationController.h"

typedef NS_OPTIONS(NSUInteger, SBDismissOverlaysOptions) {
    SBDismissOverlaysOptionsNone = 0,
    SBDismissOverlaysOptionsControlCenter = 1 << 0,
    SBDismissOverlaysOptionsContextMenus = 1 << 1,
    SBDismissOverlaysOptionsSiri = 1 << 2,
    SBDismissOverlaysOptionsCommandTab = 1 << 3,
    SBDismissOverlaysOptionsBanners = 1 << 4,
    SBDismissOverlaysOptionsIconOverlays = 1 << 5,
    SBDismissOverlaysOptionsNougat = 1 << 6,
};

@interface SBDismissOverlaysAnimationController : SBUIAnimationController
@property (readonly, nonatomic) NSUInteger dismissOptions;

+ (BOOL)willDismissOverlaysForDismissOptions:(NSUInteger)dismissOptions;
+ (SBDismissOverlaysOptions)_overlaysToDismissForOptions:(NSUInteger)dismissOptions;

@end