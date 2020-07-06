@class SBTransientOverlayViewController;

@interface SBTransientOverlayPresentationRequest : NSObject <NSCopying, NSMutableCopying>
@property (getter=isAnimated, readonly, nonatomic) BOOL animated;
@property (copy, readonly, nonatomic) void (^completionHandler)(void);
@property (readonly, nonatomic) BOOL shouldDismissSiri;
@property (readonly, nonatomic) SBTransientOverlayViewController *viewController;

- (instancetype)initWithViewController:(SBTransientOverlayViewController *)viewController;

@end