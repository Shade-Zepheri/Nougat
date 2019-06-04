#import "NUAWiFiToggle.h"
#import <SpringBoard/SBWiFiManager.h>

@implementation NUAWiFiToggle

#pragma mark - Init

- (instancetype)init {
    self = [super initWithSwitchIdentifier:@"com.a3tweaks.switch.wifi"];
    if (self) {
        // Register for notifications
        NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
        [center addObserver:self selector:@selector(_updateLabel) name:@"SBWifiManagerPowerStateDidChangeNotification" object:nil];
        [center addObserver:self selector:@selector(_updateLabel) name:@"SBWifiManagerLinkDidChangeNotification" object:nil];
        [center addObserver:self selector:@selector(_updateLabel) name:@"SBWifiManagerDevicePresenceDidChangeNotification" object:nil];
        [center addObserver:self selector:@selector(_updateLabel) name:@"SBWifiManagerPrimaryInterfaceMayHaveChangedNotification" object:nil];
    }

    return self;
}

- (void)_updateLabel {
    NSString displayName = self.displayName ?: @"WiFi";
    self.displayLabel.text = displayName;
}

#pragma mark - Toggle

- (NSBundle *)resourceBundle {
    return [NSBundle bundleForClass:[self class]];
}

- (NSString *)displayName {
    return [[NSClassFromString(@"SBWiFiManager") sharedInstance] currentNetworkName];
}

- (UIImage *)icon {
    return [UIImage imageNamed:@"Off" inBundle:self.resourceBundle];
}

- (UIImage *)selectedIcon {
    NSString *imageName = [NSString stringWithFormat:@"On-", self.usingDark ? @"Dark" : @"Light"];
    return [UIImage imageNamed:imageName inBundle:self.resourceBundle];
}

@end