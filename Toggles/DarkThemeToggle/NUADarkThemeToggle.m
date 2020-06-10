#import "NUADarkThemeToggle.h"
#import "UIUserInterfaceStyleArbiter.h"
#import <UIKit/UIImage+Private.h>

@interface NUADarkThemeToggle () 
@property (strong, nonatomic) UIUserInterfaceStyleArbiter *interfaceStyleArbiter;

@end

@implementation NUADarkThemeToggle

#pragma mark - Init

- (instancetype)init {
    self = [super init];
    if (self) {
        // Get arbiter
        _interfaceStyleArbiter = [NSClassFromString(@"UIUserInterfaceStyleArbiter") sharedInstance];

        // Register style changes
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_styleModeDidChange) name:@"UIUserInterfaceStyleArbiterStyleChangedNotification" object:nil];
    }

    return self;
}

#pragma mark - Notifications

- (void)_styleModeDidChange {
    // Simply refresh appearance
    [self refreshAppearance];
}

#pragma mark - Toggling

- (BOOL)isSelected {
    // Darn @available
    if (@available(iOS 13, *)) {
        // Get dark mode state
        return self.interfaceStyleArbiter.currentStyle == UIUserInterfaceStyleDark;
    }

    // Should never get here
    return NO;
}

- (void)setSelected:(BOOL)selected {
    if (selected == self.selected) {
        // No change
        return;
    }

    // Update dark mode state
    [self.interfaceStyleArbiter toggleCurrentStyle];
}

#pragma mark - Properties

- (NSString *)displayName {
    NSBundle *bundle = [NSBundle bundleForClass:self.class];
    return [bundle localizedStringForKey:@"NOUGAT_STATUS_DARK_THEME_DISPLAY_NAME" value:@"Dark Theme" table:nil];
}

- (NSURL *)settingsURL {
    // Display and Brightness
    return [NSURL URLWithString:@"prefs:root=DISPLAY"];
}

- (UIImage *)icon {
    // One of the few cases where state doesnt matter
    NSBundle *bundle = [NSBundle bundleForClass:self.class];
    NSString *imageName = self.usingDark ? @"Off" : @"On";
    return [UIImage imageNamed:imageName inBundle:bundle];
}

- (UIImage *)selectedIcon {
    // Icons will actually be the same
    return self.icon;
}

@end