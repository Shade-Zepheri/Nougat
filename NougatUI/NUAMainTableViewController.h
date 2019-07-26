#import <UIKit/UIKit.h>
#import "NUACoalescedNotification.h"
#import "NUANotificationRepository.h"
#import <MediaPlayerUI/MediaPlayerUI.h>

@class NUAMainTableViewController;

@protocol NUAMainTableViewControllerDelegate <NSObject>
@required

- (void)tableViewControllerWantsDismissal:(NUAMainTableViewController *)controller;

@end

@interface NUAMainTableViewController : UIViewController <UITableViewDataSource, UITableViewDelegate> {
    NSLayoutConstraint *_heightConstraint;
    NSArray<NUACoalescedNotification *> *_notifications;
}
@property (strong, readonly, nonatomic) UITableViewController *tableViewController;
@property (strong, readonly, nonatomic) MPUNowPlayingController *nowPlayingController;
@property (strong, readonly, nonatomic) NUANotificationRepository *notificationRepository;
@property (weak, nonatomic) id<NUAMainTableViewControllerDelegate> delegate;
@property (assign, nonatomic) CGFloat presentedHeight;
@property (readonly, nonatomic) CGFloat contentHeight;

@end