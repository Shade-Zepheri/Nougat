#import "NUAFlipswitchToggle.h"
#import <Flipswitch/Flipswitch.h>
#import <FrontBoardServices/FBSSystemService.h>
#import <NougatServices/NougatServices.h>
#import <UIKit/UIImage+Private.h>
#import <HBLog.h>

@interface NUAFlipswitchToggle ()
@property (strong, nonatomic) UIImageView *imageView;
@property (assign, nonatomic) FSSwitchState switchState;

@end

@implementation NUAFlipswitchToggle

- (instancetype)initWithSwitchIdentifier:(NSString *)identifier {
    self = [super initWithFrame:CGRectZero];
    if (self) {
        _toggleLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        self.toggleLabel.translatesAutoresizingMaskIntoConstraints = NO;
        self.toggleLabel.alpha = 0.0;
        self.toggleLabel.font = [UIFont systemFontOfSize:12];
        self.toggleLabel.text = self.displayName;
        self.toggleLabel.backgroundColor = [UIColor clearColor];
        self.toggleLabel.textAlignment = NSTextAlignmentCenter;
        [self addSubview:self.toggleLabel];

        _switchIdentifier = identifier;
#if TARGET_OS_SIMULATOR
        self.switchState = [[NSClassFromString(@"FSSwitchPanel") sharedPanel] stateForSwitchIdentifier:identifier];
#else
        self.switchState = [[FSSwitchPanel sharedPanel] stateForSwitchIdentifier:identifier];
#endif

        // Gesture
        if (self.settingsURL) {
            UILongPressGestureRecognizer *longPressGesture = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(handleLongPressGesture:)];
            [self addGestureRecognizer:longPressGesture];
        }

        // Constraints
        [self.toggleLabel.bottomAnchor constraintEqualToAnchor:self.bottomAnchor].active = YES;
        [self.toggleLabel.centerXAnchor constraintEqualToAnchor:self.centerXAnchor].active = YES;

        // Create imageView
        self.imageView = [[UIImageView alloc] initWithFrame:CGRectZero];
        self.imageView.translatesAutoresizingMaskIntoConstraints = NO;
        self.imageView.contentMode = UIViewContentModeScaleAspectFit;
        [self addSubview:self.imageView];

        [self _updateImageView:NO];

        // Constraints
        [self.imageView.centerXAnchor constraintEqualToAnchor:self.centerXAnchor].active = YES;
        [self.imageView.centerYAnchor constraintEqualToAnchor:self.centerYAnchor].active = YES;
        [self.imageView.widthAnchor constraintEqualToConstant:28].active = YES;
        [self.imageView.heightAnchor constraintEqualToConstant:28].active = YES;

        NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
#if TARGET_OS_SIMULATOR
        [center addObserver:self selector:@selector(switchesChangedState:) name:@"FSSwitchPanelSwitchStateChangedNotification" object:nil];
#else
        [center addObserver:self selector:@selector(switchesChangedState:) name:FSSwitchPanelSwitchStateChangedNotification object:nil];
#endif
        [center addObserver:self selector:@selector(backgroundColorDidChange:) name:@"NUANotificationShadeChangedBackgroundColor" object:nil];
    }

    return self;
}

- (NSString *)description {
    return [NSString stringWithFormat:@"<%@: %p; switchIdentifier = %@>", self.class, self, self.switchIdentifier];
}

#pragma mark - Properties

- (void)setNotificationShadePreferences:(NUAPreferenceManager *)preferences {
    _notificationShadePreferences = preferences;

    // Update text and images
    self.toggleLabel.textColor = preferences.textColor;
    [self _updateImageView:NO];
}

#pragma mark - Ripple

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
    [self toggleSwitchState];

    [super touchesEnded:touches withEvent:event];
}

#pragma mark - Gesture

- (void)handleLongPressGesture:(UILongPressGestureRecognizer *)gestureRecognizer {
    if (gestureRecognizer.state != UIGestureRecognizerStateBegan) {
        return;
    }

    // Open the URL
    [self _openURL:self.settingsURL bundleIdentifier:@"com.apple.Preferences" completion:^{
        // Dismiss notification shade
        [self.delegate toggleWantsNotificationShadeDismissal:self];
    }];
}

- (void)_openURL:(NSURL *)URL bundleIdentifier:(NSString *)bundleIdentifier completion:(void(^)(void))completion {
    // Get FBSSystemService and send on client port
	FBSSystemService *systemService = [FBSSystemService sharedService];
	mach_port_t port = [systemService createClientPort];

	[systemService openURL:URL application:bundleIdentifier options:@{FBSOpenApplicationOptionKeyUnlockDevice: @(YES)} clientPort:port withResult:^(NSError *error) {
        if (error) {
            // Print error
            HBLogError(@"[Nougat] openURL error: %@", error);
            return;
        }

        // Ensure on the main queue
        dispatch_async(dispatch_get_main_queue(), ^{
            completion();
        });
    }];
}

#pragma mark - Toggles

- (void)toggleSwitchState {
#if TARGET_OS_SIMULATOR
    FSSwitchPanel *switchPanel = [NSClassFromString(@"FSSwitchPanel") sharedPanel];
#else
    FSSwitchPanel *switchPanel = [FSSwitchPanel sharedPanel];
#endif

    self.switchState = [switchPanel stateForSwitchIdentifier:self.switchIdentifier];
    [switchPanel setState:(self.switchState == FSSwitchStateOff) ? FSSwitchStateOn : FSSwitchStateOff forSwitchIdentifier:self.switchIdentifier];
}

#pragma mark - Properties

- (BOOL)isUsingDark {
    return self.notificationShadePreferences.usingDark;
}

- (BOOL)isInverted {
    return NO;
}

- (NSURL *)settingsURL {
    return nil;
}

- (NSString *)displayName {
    return nil;
}

- (UIImage *)icon {
    return nil;
}

- (UIImage *)selectedIcon {
    return nil;
}

#pragma mark - Image management

- (void)_updateImageView:(BOOL)animated {
    // Get proper image
    FSSwitchState state;
    if (self.inverted) {
        state = (self.switchState == FSSwitchStateOn) ? FSSwitchStateOff : FSSwitchStateOn;
    } else {
        state = self.switchState;
    }

    UIImage *glyph = (state == FSSwitchStateOn) ? self.selectedIcon : self.icon;

    // Animate transition
    CGFloat duration = animated ? 0.4 : 0.0;
    [UIView transitionWithView:self.imageView duration:duration options:UIViewAnimationOptionTransitionCrossDissolve animations:^{
        self.imageView.image = glyph;
    } completion:nil];
}

#pragma mark - Notifications

- (void)switchesChangedState:(NSNotification *)notification {
#if TARGET_OS_SIMULATOR
    NSString *changedSwitch = notification.userInfo[@"switchIdentifier"];
#else
    NSString *changedSwitch = notification.userInfo[FSSwitchPanelSwitchIdentifierKey];
#endif
    if (changedSwitch && ![changedSwitch isEqualToString:self.switchIdentifier]) {
        return;
    }

#if TARGET_OS_SIMULATOR
    self.switchState = [[NSClassFromString(@"FSSwitchPanel") sharedPanel] stateForSwitchIdentifier:self.switchIdentifier];
#else
    self.switchState = [[FSSwitchPanel sharedPanel] stateForSwitchIdentifier:self.switchIdentifier];
#endif
    [self _updateImageView:YES];
}

#pragma mark - Appearance Updates

- (void)traitCollectionDidChange:(UITraitCollection *)previousTraitCollection {
    [super traitCollectionDidChange:previousTraitCollection];

    // Check if appearance changed
    if (@available(iOS 13, *)) {
        if (![self.traitCollection hasDifferentColorAppearanceComparedToTraitCollection:previousTraitCollection] || !self.notificationShadePreferences.usesSystemAppearance) {
            return;
        }

        self.toggleLabel.textColor = self.notificationShadePreferences.textColor;
        [self _updateImageView:NO];
    }
}

- (void)backgroundColorDidChange:(NSNotification *)notification {
    NSDictionary<NSString *, UIColor *> *colorInfo = notification.userInfo;

    // Update label and image
    self.toggleLabel.textColor = colorInfo[@"textColor"];
    [self _updateImageView:NO];
}

@end