#import <UIKit/UIKit.h>

// Holy crap so many
typedef NS_ENUM(NSUInteger, SBSystemGestureType) {
    SBSystemGestureTypeNone,
    SBSystemGestureTypeShowCoverSheet,
    SBSystemGestureTypeDismissCoverSheet,
    SBSystemGestureTypeDismissCoverSheetExtendedRegion,
    SBSystemGestureTypeDismissSecureApp,
    SBSystemGestureTypeShowNotifications,
    SBSystemGestureTypeDismissBanner,
    SBSystemGestureTypeDismissLongLook,
    SBSystemGestureTypeShowControlCenter,
    SBSystemGestureTypeShowControlCenterFromStatusBar,
    SBSystemGestureTypeDismissControlCenter,
    SBSystemGestureTypeScrunch,
    SBSystemGestureTypeResizeScene,
    SBSystemGestureTypeMoveSideApp,
    SBSystemGestureTypeUnpinSideApp,
    SBSystemGestureTypePresentPiPApp,
    SBSystemGestureTypeMovePiPApp,
    SBSystemGestureTypePinPiPApp,
    SBSystemGestureTypePiPBottomEdge,
    SBSystemGestureTypeDismissDock,
    SBSystemGestureTypeForceSwitcher,
    SBSystemGestureTypeBottomEdgeSwitcher,
    SBSystemGestureTypeDismissModal,
    SBSystemGestureTypeDismissAlertItem,
    SBSystemGestureTypeDismissSheet,
    SBSystemGestureTypeSwitcherActivateReachability,
    SBSystemGestureTypeActivateReachability,
    SBSystemGestureTypeEdgeDeactivateReachability,
    SBSystemGestureTypePanDeactivateReachability,
    SBSystemGestureTypeTapDeactivateReachability,
    SBSystemGestureTypeDismissCPBanner,
    SBSystemGestureTypeTapToWake,
    SBSystemGestureTypePencilToWake,
    SBSystemGestureTypeHomeButtonDown,
    SBSystemGestureTypeHomeButtonUp,
    SBSystemGestureTypeHomeButtonSingle,
    SBSystemGestureTypeHomeACCSingle,
    SBSystemGestureTypeHomeLongPress,
    SBSystemGestureTypeHomeDoubleDown,
    SBSystemGestureTypeHomeDoubleUp,
    SBSystemGestureTypeHomeDoubleUpAgain,
    SBSystemGestureTypeHomeTripleDown,
    SBSystemGestureTypeHomeTripleUp,
    SBSystemGestureTypeLockButtonDown,
    SBSystemGestureTypeLockButtonSingle,
    SBSystemGestureTypeLockLongPress,
    SBSystemGestureTypeLockButtonDouble,
    SBSystemGestureTypeLockButtonTriple,
    SBSystemGestureTypeLockButtonQuadruple,
    SBSystemGestureTypeLockButtonLog,
    SBSystemGestureTypeSOS,
    SBSystemGestureTypeShutDown,
    SBSystemGestureTypeVolumeIncreasePress,
    SBSystemGestureTypeVolumeDecreasePress,
    SBSystemGestureTypeScreenshot,
    SBSystemGestureTypeScrollDashBoard,
    SBSystemGestureTypeCancelScrollDashBoard,
    SBSystemGestureTypeHorizCancelScrollLock,
    SBSystemGestureTypeEdgeScrollLock,
    SBSystemGestureTypeDismissCameraUIDashboard,
    SBSystemGestureTypeDismissSpotlightUIDashBoard,
    SBSystemGestureTypeDismissModalUIDashboard,
    SBSystemGestureTypeHomeAffordanceBounceTap,
    SBSystemGestureTypeHomeAffordanceRevealTap,
    SBSystemGestureTypeHomeAffordanceRevealDoubleTap,
    SBSystemGestureTypeHomeAffordanceRevealEdgePan,
    SBSystemGestureTypeInteractiveScreenshotBottomLeft,
    SBSystemGestureTypeInteractiveScreenshotBottomRight,
    SBSystemGestureTypeDismissCoverSheetTodayOverlay,
    SBSystemGestureTypeDismissHomeScreenTodayOverlay,
    SBSystemGestureTypeShowNougat = 2323            // Added by me
};

@class SBMainDisplaySystemGestureManager;

@interface SBSystemGestureManager : NSObject <UIGestureRecognizerDelegate>
@property (assign, getter=areSystemGesturesDisabledForAccessibility, nonatomic) BOOL systemGesturesDisabledForAccessibility;

+ (SBMainDisplaySystemGestureManager *)mainDisplayManager;

- (void)addGestureRecognizer:(UIGestureRecognizer *)gestureRecognizer withType:(SBSystemGestureType)type;
- (void)removeGestureRecognizer:(UIGestureRecognizer *)gestureRecognizer;

- (void)gestureRecognizerOfType:(SBSystemGestureType)type shouldBeRequiredToFailByGestureRecognizer:(UIGestureRecognizer *)gestureRecognizer;
- (void)gestureRecognizerOfType:(SBSystemGestureType)type shouldRequireFailureOfGestureRecognizer:(UIGestureRecognizer *)gestureRecognizer;

@end