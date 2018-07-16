#import <UIKit/UIKit.h>

@class NUANotificationShadeModuleViewController;

@protocol NUANotificationShadeModuleViewControllerDelegate <NSObject>
@required

- (void)moduleWantsNotificationShadeDismissal:(NUANotificationShadeModuleViewController *)module completely:(BOOL)completely;
- (void)moduleWantsNotificationShadeExpansion:(NUANotificationShadeModuleViewController *)module;

@end

@interface NUANotificationShadeModuleViewController : UIViewController {
    NSLayoutConstraint *_heightConstraint;
}

@property (copy, readonly, nonatomic) NSString *moduleIdentifier;
@property (weak, nonatomic) id<NUANotificationShadeModuleViewControllerDelegate> delegate;

+ (Class)viewClass;

@end