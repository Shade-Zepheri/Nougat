@protocol SBTransientOverlayPresentationManagerDelegate;

@interface SBTransientOverlayPresentationManager : NSObject
@property (weak, nonatomic) id<SBTransientOverlayPresentationManagerDelegate> delegate;

@property (readonly, nonatomic) BOOL shouldDisableControlCenter; 
// iOS 13
@property (readonly, nonatomic) BOOL shouldDisableCoverSheet; 
// iOS 14
@property (readonly, nonatomic) BOOL shouldDisableCoverSheetGesture; 

@end