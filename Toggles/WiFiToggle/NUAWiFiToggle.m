#import "NUAWiFiToggle.h"
#import <SpringBoard/SBWiFiManager.h>
#import <UIKit/UIImage+Private.h>
#import <HBLog.h>

@implementation NUAWiFiToggle

#pragma mark - Init

- (instancetype)init {
    self = [super initWithSwitchIdentifier:@"com.a3tweaks.switch.wifi"];
    if (self) {
        // Register for notifications
        NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
        [center addObserver:self selector:@selector(_updateLabel:) name:@"SBWifiManagerLinkDidChangeNotification" object:nil];
    }

    return self;
}

- (void)_updateLabel:(NSNotification *)notification {
    NSBundle *bundle = [NSBundle bundleForClass:[self class]];
    NSString *localizedWifiText = [bundle localizedStringForKey:@"NOUGAT_STATUS_WIFI_DISPLAY_NAME" value:@"Wi-Fi" table:nil];
    NSString *displayName = self.displayName ?: localizedWifiText;

    // Transition label
    CATransition *animation = [CATransition animation];
    animation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
    animation.type = kCATransitionFade;
    animation.duration = 0.25;
    [self.toggleLabel.layer addAnimation:animation forKey:@"kCATransitionFade"];

    self.toggleLabel.text = displayName;
}

#pragma mark - Toggle

- (NSString *)displayName {
    return [[NSClassFromString(@"SBWiFiManager") sharedInstance] currentNetworkName];
}

- (NSURL *)settingsURL {
    return [NSURL URLWithString:@"prefs:root=WIFI"];
}

- (UIImage *)icon {
    NSBundle *bundle = [NSBundle bundleForClass:[self class]];
    return [UIImage imageNamed:@"Off" inBundle:bundle];
}

- (UIImage *)selectedIcon {
    NSBundle *bundle = [NSBundle bundleForClass:[self class]];
    NSString *imageName = [NSString stringWithFormat:@"On-%@", self.usingDark ? @"Dark" : @"Light"];
    return [UIImage imageNamed:imageName inBundle:bundle];
}

@end