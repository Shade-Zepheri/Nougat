#import "NUATableViewCell.h"
#import "NUACoalescedNotification.h"
#import "NUADateLabelRepository.h"
#import "NUAImageColorCache.h"

@class NUANotificationTableViewCell;

@protocol NUANotificationTableViewCellDelegate <NSObject>
@required

- (void)notificationTableViewCellRequestsExecuteDefaultAction:(NUANotificationTableViewCell *)cell;
- (void)notificationTableViewCellRequestsExecuteAlternateAction:(NUANotificationTableViewCell *)cell;

@end

@interface NUANotificationTableViewCell : NUATableViewCell <NUADateLabelDelegate>
@property (weak, nonatomic) id<NUANotificationTableViewCellDelegate> actionsDelegate;
@property (strong, nonatomic) NUACoalescedNotification *notification;

@property (copy, nonatomic) NSString *titleText;
@property (copy, nonatomic) NSString *messageText;
@property (strong, nonatomic) UIImage *attachmentImage;
@property (strong, nonatomic) NSDate *timestamp;

@end