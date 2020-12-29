#import <UIKit/UIKit.h>
#import <NougatUI/NougatUI.h>

@interface NUASystemAgent : NSObject <NUASystemServicesProvider>
@property (strong, readonly, nonatomic) id<NUANotificationsProvider> notificationsProvider;
@property (strong, readonly, nonatomic) id<NUAUserAuthenticationProvider> authenticationProvider;
@property (readonly, nonatomic) UIInterfaceOrientation activeInterfaceOrientation;

- (instancetype)initWithNotificationsProvider:(id<NUANotificationsProvider>)notificationsProvider authenticationProvider:(id<NUAUserAuthenticationProvider>)authenticationProvider;

@end