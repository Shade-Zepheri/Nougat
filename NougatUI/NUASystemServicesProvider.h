#import <UIKit/UIKit.h>
#import "NUANotificationsProvider.h"
#import "NUAUserAuthenticationProvider.h"

@protocol NUASystemServicesProvider <NSObject>
@property (strong, readonly, nonatomic) id<NUANotificationsProvider> notificationsProvider;
@property (strong, readonly, nonatomic) id<NUAUserAuthenticationProvider> authenticationProvider;
@property (readonly, nonatomic) UIInterfaceOrientation activeInterfaceOrientation;

@required

- (id<NUANotificationsProvider>)notificationsProvider;
- (id<NUAUserAuthenticationProvider>)authenticationProvider;
- (UIInterfaceOrientation)activeInterfaceOrientation;

@end