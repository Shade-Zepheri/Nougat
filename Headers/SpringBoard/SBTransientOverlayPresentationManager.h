@protocol SBTransientOverlayPresentationManagerDelegate;

@interface SBTransientOverlayPresentationManager : NSObject
@property (weak, nonatomic) id<SBTransientOverlayPresentationManagerDelegate> delegate;

@property (readonly, nonatomic) BOOL shouldDisableControlCenter; 
@property (readonly, nonatomic) BOOL shouldDisableCoverSheet; 

@end