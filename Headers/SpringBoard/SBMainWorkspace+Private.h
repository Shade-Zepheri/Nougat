#import <SpringBoard/SBMainWorkspace.h>

@class SBTransientOverlayPresentationManager;

@interface SBMainWorkspace ()
@property (readonly, nonatomic) SBTransientOverlayPresentationManager *transientOverlayPresentationManager; // iOS 13

@end