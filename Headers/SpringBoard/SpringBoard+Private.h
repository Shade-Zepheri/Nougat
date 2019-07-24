#import <SpringBoard/SpringBoard.h>

@class SBNCNotificationDispatcher;

@interface SpringBoard (Private)
@property (readonly, nonatomic) SBNCNotificationDispatcher *notificationDispatcher;

- (UIInterfaceOrientation)activeInterfaceOrientation;

@end
