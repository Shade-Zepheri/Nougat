#import "NUATableViewCellBase.h"
#import "NUACoalescedNotification.h"
#import "NUADateLabelRepository.h"
#import "NUAImageColorCache.h"

@class NUASimpleNotificationTableViewCell;

@protocol NUANotificationTableViewCellDelegate <NSObject>
@required

- (void)notificationTableViewCell:(NUASimpleNotificationTableViewCell *)tableViewCell requestsExecuteAction:(NCNotificationAction *)action fromNotificationRequest:(NCNotificationRequest *)request;

@end

@interface NUASimpleNotificationTableViewCell : NUATableViewCellBase <NUADateLabelDelegate>
@property (weak, nonatomic) id<NUANotificationTableViewCellDelegate> actionsDelegate;
@property (strong, nonatomic) NUACoalescedNotification *notification;

@property (getter=isUILocked, nonatomic) BOOL UILocked;
@property (assign, nonatomic) BOOL hasActions;
@property (copy, nonatomic) NSString *titleText;
@property (copy, nonatomic) NSString *messageText;
@property (strong, nonatomic) UIImage *attachmentImage;
@property (strong, nonatomic) NSDate *timestamp;

@end