#import "NUAToggleButton.h"
#import "NUARippleButton.h"

#import <FrontBoardServices/FBSSystemService.h>
#import <UIKit/UIImage+Private.h>
#import <HBLog.h>

@interface NUAToggleButton ()
@property (strong, nonatomic) NUARippleButton *rippleButton;
@property (strong, nonatomic) UIImageView *imageView;

@end

@implementation NUAToggleButton

#pragma mark - Initialization

- (instancetype)init {
    self = [super init];
    if (self) {
        // Create ripple button
        self.rippleButton = [[NUARippleButton alloc] init];
        [self.rippleButton addTarget:self action:@selector(toggleSelectedState:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:self.rippleButton];

        // Create toggle label
        _displayNameLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        self.displayNameLabel.translatesAutoresizingMaskIntoConstraints = NO;
        self.displayNameLabel.alpha = 0.0;
        self.displayNameLabel.font = [UIFont systemFontOfSize:12];
        self.displayNameLabel.text = self.displayName;
        self.displayNameLabel.backgroundColor = [UIColor clearColor];
        self.displayNameLabel.textAlignment = NSTextAlignmentCenter;
        [self addSubview:self.displayNameLabel];

        // Gesture if there's a settings url
        if (self.settingsURL) {
            UILongPressGestureRecognizer *longPressGesture = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(handleLongPressGesture:)];
            [self addGestureRecognizer:longPressGesture];
        }

        // Constraints
        [self.displayNameLabel.bottomAnchor constraintEqualToAnchor:self.bottomAnchor].active = YES;
        [self.displayNameLabel.centerXAnchor constraintEqualToAnchor:self.centerXAnchor].active = YES;

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

        // Register for notifications
        [NSNotificationCenter.defaultCenter addObserver:self selector:@selector(backgroundColorDidChange:) name:@"NUANotificationShadeChangedBackgroundColor" object:nil];
    }

    return self;
}

#pragma mark - View Management

- (void)layoutSubviews {
    // Update button frame
    self.rippleButton.frame = self.bounds;
}

#pragma mark - Properties

- (void)setNotificationShadePreferences:(NUAPreferenceManager *)preferences {
    _notificationShadePreferences = preferences;

    // Update text and images
    self.displayNameLabel.textColor = preferences.textColor;
    [self _updateImageView:NO];
}

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

#pragma mark - Actions

- (void)toggleSelectedState:(NUARippleButton *)button {
    // Toggle selected state
    self.selected = !self.selected;
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

#pragma mark - Image management

- (void)refreshAppearance {
    // All we have to do is update image
    // since the state is already set
    [self _updateImageView:YES];
}

- (void)_updateImageView:(BOOL)animated {
    // Get proper image
    UIImage *glyph = (self.selected) ? self.selectedIcon : self.icon;

    // Animate transition
    CGFloat duration = animated ? 0.4 : 0.0;
    [UIView transitionWithView:self.imageView duration:duration options:UIViewAnimationOptionTransitionCrossDissolve animations:^{
        self.imageView.image = glyph;
    } completion:nil];
}

#pragma mark - Appearance Updates

- (void)traitCollectionDidChange:(UITraitCollection *)previousTraitCollection {
    [super traitCollectionDidChange:previousTraitCollection];

    // Check if appearance changed
    if (@available(iOS 13, *)) {
        if (![self.traitCollection hasDifferentColorAppearanceComparedToTraitCollection:previousTraitCollection] || !self.notificationShadePreferences.usesSystemAppearance) {
            return;
        }

        self.displayNameLabel.textColor = self.notificationShadePreferences.textColor;
        [self _updateImageView:NO];
    }
}

- (void)backgroundColorDidChange:(NSNotification *)notification {
    NSDictionary<NSString *, UIColor *> *colorInfo = notification.userInfo;

    // Update label and image
    self.displayNameLabel.textColor = colorInfo[@"textColor"];
    [self _updateImageView:NO];
}

@end