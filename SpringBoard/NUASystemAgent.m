#import "NUASystemAgent.h"
#import <SpringBoard/SpringBoard+Private.h>

@implementation NUASystemAgent

#pragma mark - Init

- (instancetype)initWithNotificationsProvider:(id<NUANotificationsProvider>)notificationsProvider authenticationProvider:(id<NUAUserAuthenticationProvider>)authenticationProvider {
    self = [super init];
    if (self) {
        _notificationsProvider = notificationsProvider;
        _authenticationProvider = authenticationProvider;
    }

    return self;
}

#pragma mark - Properties

- (UIInterfaceOrientation)activeInterfaceOrientation {
    return [(SpringBoard *)[UIApplication sharedApplication] activeInterfaceOrientation];
}

@end