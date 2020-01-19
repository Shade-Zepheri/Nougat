#import "CSExternalBehaviorProviding.h"
#import "CSExternalPresentationProviding.h"
#import "CSExternalAppearanceProviding.h"

@interface CSCoverSheetViewController : UIViewController

- (void)registerExternalBehaviorProvider:(UIViewController<CSExternalBehaviorProviding> *)provider;
- (void)externalBehaviorProviderBehaviorChanged:(UIViewController<CSExternalBehaviorProviding> *)provider;
- (void)unregisterExternalBehaviorProvider:(UIViewController<CSExternalBehaviorProviding> *)provider;

- (void)registerExternalPresentationProvider:(UIViewController<CSExternalPresentationProviding> *)provider;
- (void)externalPresentationProviderPresentationChanged:(UIViewController<CSExternalPresentationProviding> *)provider;
- (void)unregisterExternalPresentationProvider:(UIViewController<CSExternalPresentationProviding> *)provider;

- (void)registerExternalAppearanceProvider:(UIViewController<CSExternalAppearanceProviding> *)provider;
- (void)externalAppearanceProviderBehaviorChanged:(UIViewController<CSExternalAppearanceProviding> *)provider;
- (void)unregisterExternalAppearanceProvider:(UIViewController<CSExternalAppearanceProviding> *)provider;

@end