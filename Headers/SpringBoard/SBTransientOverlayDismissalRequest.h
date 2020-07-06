@class SBTransientOverlayViewController;

@interface SBTransientOverlayDismissalRequest : NSObject <NSCopying, NSMutableCopying> 
@property (getter=isAnimated, readonly, nonatomic) BOOL animated;
@property (copy, readonly, nonatomic) void (^completionHandler)(void);
@property (readonly, nonatomic) NSInteger requestType;
@property (readonly, nonatomic) SBTransientOverlayViewController *viewController;

+ (instancetype)dismissalRequestForAllViewControllers;
+ (instancetype)dismissalRequestForViewController:(SBTransientOverlayViewController *)viewController;

@end