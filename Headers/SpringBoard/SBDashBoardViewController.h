#import "SBDashBoardExternalBehaviorProviding.h"
#import "SBDashBoardExternalPresentationProviding.h"
#import "SBDashBoardExternalAppearanceProviding.h"

// Has a bunch of superclasses so simplyfiying
@interface SBDashBoardViewController : UIViewController

- (void)registerExternalBehaviorProvider:(UIViewController<SBDashBoardExternalBehaviorProviding> *)provider;
- (void)externalBehaviorProviderBehaviorChanged:(UIViewController<SBDashBoardExternalBehaviorProviding> *)provider;
- (void)unregisterExternalBehaviorProvider:(UIViewController<SBDashBoardExternalBehaviorProviding> *)provider;

- (void)registerExternalPresentationProvider:(UIViewController<SBDashBoardExternalPresentationProviding> *)provider;
- (void)externalPresentationProviderPresentationChanged:(UIViewController<SBDashBoardExternalPresentationProviding> *)provider;
- (void)unregisterExternalPresentationProvider:(UIViewController<SBDashBoardExternalPresentationProviding> *)provider;

- (void)registerExternalAppearanceProvider:(UIViewController<SBDashBoardExternalAppearanceProviding> *)provider;
- (void)externalAppearanceProviderBehaviorChanged:(UIViewController<SBDashBoardExternalAppearanceProviding> *)provider;
- (void)unregisterExternalAppearanceProvider:(UIViewController<SBDashBoardExternalAppearanceProviding> *)provider;

@end