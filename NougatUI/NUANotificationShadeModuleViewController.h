#import <UIKit/UIKit.h>

@class NUANotificationShadeModuleViewController;

@protocol NUANotificationShadeModuleViewControllerDelegate <NSObject>
@required

- (void)moduleWantsNotificationShadeDismissal:(NUANotificationShadeModuleViewController *)module completely:(BOOL)completely;
- (void)moduleWantsNotificationShadeExpansion:(NUANotificationShadeModuleViewController *)module;
- (CGFloat)moduleRequestsContainerHeightWhenFullyRevealed:(NUANotificationShadeModuleViewController *)module;

@end

@interface NUANotificationShadeModuleViewController : UIViewController {
    NSLayoutConstraint *_heightConstraint;
}

@property (class, readonly, nonatomic) Class viewClass;
@property (class, readonly, nonatomic) CGFloat defaultModuleHeight;

@property (copy, readonly, nonatomic) NSString *moduleIdentifier;
@property (weak, nonatomic) id<NUANotificationShadeModuleViewControllerDelegate> delegate;

@end