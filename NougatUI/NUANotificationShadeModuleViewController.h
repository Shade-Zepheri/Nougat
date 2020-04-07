#import <UIKit/UIKit.h>
#import <NougatServices/NougatServices.h>

@class NUANotificationShadeModuleViewController;

@protocol NUANotificationShadeModuleViewControllerDelegate <NSObject>
@property (strong, readonly, nonatomic) NUAPreferenceManager *notificationShadePreferences;

@required

- (void)moduleWantsNotificationShadeDismissal:(NUANotificationShadeModuleViewController *)module completely:(BOOL)completely;
- (void)moduleWantsNotificationShadeExpansion:(NUANotificationShadeModuleViewController *)module;
- (CGFloat)moduleRequestsContainerHeightWhenFullyRevealed:(NUANotificationShadeModuleViewController *)module;
- (NUAPreferenceManager *)notificationShadePreferences;

@end

@interface NUANotificationShadeModuleViewController : UIViewController {
    NSLayoutConstraint *_heightConstraint;
}

@property (class, readonly, nonatomic) Class viewClass;
@property (class, readonly, nonatomic) CGFloat defaultModuleHeight;
@property (strong, readonly, nonatomic) NUAPreferenceManager *notificationShadePreferences;

@property (copy, readonly, nonatomic) NSString *moduleIdentifier;
@property (weak, nonatomic) id<NUANotificationShadeModuleViewControllerDelegate> delegate;

@end