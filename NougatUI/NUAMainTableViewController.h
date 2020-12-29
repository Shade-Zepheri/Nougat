#import <UIKit/UIKit.h>
#import "NUASystemServicesProvider.h"
#import "NUACoalescedNotification.h"
#import "NUAAttachmentNotificationTableViewCell.h"
#import <NougatServices/NougatServices.h>
#import <MediaPlayerUI/MediaPlayerUI.h>

@class NUAMainTableViewController;

@protocol NUAMainTableViewControllerDelegate <NSObject>
@required

- (void)tableViewControllerWantsDismissal:(NUAMainTableViewController *)tableViewController;
- (CGFloat)tableViewControllerRequestsPanelContentHeight:(NUAMainTableViewController *)tableViewController;

@end

@interface NUAMainTableViewController : UIViewController <NUANotificationsObserver, NUATableViewCellDelegate, NUANotificationTableViewCellDelegate, NUAUserAuthenticationObserver, UITableViewDataSource, UITableViewDelegate>
@property (strong, readonly, nonatomic) NUAPreferenceManager *notificationShadePreferences;
@property (strong, readonly, nonatomic) UITableViewController *tableViewController;
@property (strong, readonly, nonatomic) id<NUASystemServicesProvider> systemServicesProvider;
@property (strong, readonly, nonatomic) id<NUANotificationsProvider> notificationsProvider;
@property (strong, readonly, nonatomic) id<NUAUserAuthenticationProvider> authenticationProvider;

@property (weak, nonatomic) id<NUAMainTableViewControllerDelegate> delegate;
@property (assign, nonatomic) CGFloat presentedHeight;
@property (assign, nonatomic) CGFloat revealPercentage;
@property (readonly, nonatomic) CGFloat contentHeight;
@property (getter=isUILocked, nonatomic) BOOL UILocked;

- (instancetype)initWithPreferences:(NUAPreferenceManager *)notificationShadePreferences systemServicesProvider:(id<NUASystemServicesProvider>)systemServicesProvider;

- (BOOL)containsPoint:(CGPoint)point;

@end