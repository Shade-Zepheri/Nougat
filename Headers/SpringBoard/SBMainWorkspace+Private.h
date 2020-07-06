#import <SpringBoard/SBMainWorkspace.h>
#import "SBTransientOverlayPresentationManagerDelegate.h"

@class SBTransientOverlayPresentationManager;

@interface SBMainWorkspace () <SBTransientOverlayPresentationManagerDelegate>
@property (readonly, nonatomic) SBTransientOverlayPresentationManager *transientOverlayPresentationManager; // iOS 13

@end