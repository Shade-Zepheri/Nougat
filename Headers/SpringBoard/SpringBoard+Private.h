#import <SpringBoard/SpringBoard.h>

@class SBNCNotificationDispatcher, SBFUserAuthenticationController;

@interface SpringBoard (Private)
@property (readonly, nonatomic) SBNCNotificationDispatcher *notificationDispatcher;
@property (readonly, nonatomic) SBFUserAuthenticationController *authenticationController;

- (UIInterfaceOrientation)activeInterfaceOrientation;

@end
