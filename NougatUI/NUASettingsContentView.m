#import "NUASettingsContentView.h"
#import <Macros.h>
#import <FrontBoardServices/FBSSystemService.h>
#import <NougatServices/NougatServices.h>
#import <UIKit/UIImage+Private.h>
#import <version.h>

@implementation NUASettingsContentView

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        // Register for notification
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(backgroundColorDidChange:) name:@"NUANotificationShadeChangedBackgroundColor" object:nil];

        _dateFormatter = [[NSDateFormatter alloc] init];
        _dateFormatter.dateFormat = @"E, MMM d";

        // Create views
        [self _createDivider];
        [self _createDateLabel];
        [self _createStackView];
    }

    return self;
}

#pragma mark - View creation

- (void)_createDivider {
    _dividerView = [[UIView alloc] initWithFrame:CGRectZero];
    _dividerView.backgroundColor = [NUAPreferenceManager sharedSettings].usingDark ? OreoDividerColor : [UIColor clearColor];
    [self addSubview:_dividerView];

    // Constraints
    _dividerView.translatesAutoresizingMaskIntoConstraints = NO;

    [_dividerView.topAnchor constraintEqualToAnchor:self.topAnchor].active = YES;
    [_dividerView.leadingAnchor constraintEqualToAnchor:self.leadingAnchor].active = YES;
    [_dividerView.trailingAnchor constraintEqualToAnchor:self.trailingAnchor].active = YES;
    [_dividerView.heightAnchor constraintEqualToConstant:2.0].active = YES;
}

- (void)_createDateLabel {
    _dateLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    self.dateLabel.textColor = [NUAPreferenceManager sharedSettings].textColor;
    self.dateLabel.textAlignment = NSTextAlignmentLeft;
    self.dateLabel.font = [UIFont systemFontOfSize:15];
    [self addSubview:self.dateLabel];

    // Constraints (Massive mess but keeps things clean)
    self.dateLabel.translatesAutoresizingMaskIntoConstraints = NO;

    [self.dateLabel.topAnchor constraintEqualToAnchor:self.topAnchor].active = YES;
    [self.dateLabel.leadingAnchor constraintEqualToAnchor:self.leadingAnchor constant:20.0].active = YES;
    [self.dateLabel.heightAnchor constraintEqualToAnchor:self.heightAnchor].active = YES;
}

- (void)_createStackView {
    UIStackView *horizontalStackView = [[UIStackView alloc] initWithFrame:CGRectZero];
    horizontalStackView.axis = UILayoutConstraintAxisHorizontal;
    horizontalStackView.alignment = UIStackViewAlignmentFill;
    horizontalStackView.distribution = UIStackViewDistributionEqualSpacing;
    horizontalStackView.spacing = 25.0;
    [self addSubview:horizontalStackView];

    // Constraints
    horizontalStackView.translatesAutoresizingMaskIntoConstraints = NO;

    [horizontalStackView.topAnchor constraintEqualToAnchor:self.topAnchor].active = YES;
    [horizontalStackView.bottomAnchor constraintEqualToAnchor:self.bottomAnchor].active = YES;
    [horizontalStackView.trailingAnchor constraintEqualToAnchor:self.trailingAnchor constant:-20.0].active = YES;
    [horizontalStackView.widthAnchor constraintEqualToConstant:155.0].active = YES;

    _accountView = [self _imageViewForImageName:@"account"];
    self.accountView.alpha = 0.0;
    self.accountView.tag = 1; // Use to identify which view tapped
    _accountConstraint = [self.accountView.widthAnchor constraintEqualToConstant:0.0];
    _accountConstraint.active = YES;
    [horizontalStackView addArrangedSubview:self.accountView];

    _nougatView = [self _imageViewForImageName:@"edit"];
    self.nougatView.alpha = 0.0;
    self.nougatView.tag = 2; // Use to identify which view tapped
    _preferencesConstraint = [self.nougatView.widthAnchor constraintEqualToConstant:0.0];
    _preferencesConstraint.active = YES;
    [horizontalStackView addArrangedSubview:self.nougatView];

    _settingsView = [self _imageViewForImageName:@"settings"];
    self.settingsView.tag = 3; // Use to identify which view tapped
    [self.settingsView.widthAnchor constraintEqualToConstant:20.0].active = YES;
    [horizontalStackView addArrangedSubview:self.settingsView];

    _arrowView = [self _imageViewForImageName:@"arrow"];
    self.arrowView.tag = 4; // Use to identify which view tapped
    [self.arrowView.widthAnchor constraintEqualToConstant:20.0].active = YES;
    [horizontalStackView addArrangedSubview:self.arrowView];
}

#pragma mark - Custom image

- (UIImageView *)_imageViewForImageName:(NSString *)imageName {
    UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectZero];
    imageView.contentMode = UIViewContentModeScaleAspectFit;
    imageView.userInteractionEnabled = YES;
    imageView.translatesAutoresizingMaskIntoConstraints = NO;

    // Add gesture
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTap:)];
    tapGesture.numberOfTapsRequired = 1;
    [imageView addGestureRecognizer:tapGesture];

    NSString *imageStyle = [NUAPreferenceManager sharedSettings].usingDark ? @"-dark" : @"-light";
    imageName = [imageName stringByAppendingString:imageStyle];

    NSBundle *bundle = [NSBundle bundleForClass:[self class]];
    UIImage *image = [UIImage imageNamed:imageName inBundle:bundle];
    imageView.image = image;

    return imageView;
}

#pragma mark - Gesture

- (void)handleTap:(UITapGestureRecognizer *)gestureRecognizer {
    if (!gestureRecognizer.view) {
        return;
    }

    NSString *URLString = @"prefs:root=";
    switch (gestureRecognizer.view.tag) {
        case 1: {
            // Go to iCloud settings
            NSString *iCloudURL = IS_IOS_OR_NEWER(iOS_10_3) ? @"APPLE_ACCOUNT" : @"CASTLE"; // On 10.3 the iCloud banner was added, changing the URL
            URLString = [URLString stringByAppendingString:iCloudURL];
            break;
        }
        case 2:
            // Go to Prefs pane
            URLString = [URLString stringByAppendingString:@"Nougat"];
            break;
        case 3:
            // Go to settings root
            URLString = [URLString stringByAppendingString:@"ROOT"];
            break;
        case 4:
            // Switcher
            [self _toggleNotificationShadeState];
            return;
        default:
            break;
    }

    // Open the bad boi
    NSURL *URL = [NSURL URLWithString:URLString];
    [self _openURL:URL bundleIdentifier:@"com.apple.Preferences" completion:^{
        // Dismiss notification shade
        [self.delegate contentViewWantsNotificationShadeDismissal:self completely:YES];
    }];
}

- (void)_openURL:(NSURL *)URL bundleIdentifier:(NSString *)bundleIdentifier completion:(void(^)(void))completion {
    // Get FBSSystemService and send on client port
	FBSSystemService *systemService = [FBSSystemService sharedService];
	mach_port_t port = [systemService createClientPort];

	[systemService openURL:URL application:bundleIdentifier options:@{
		FBSOpenApplicationOptionKeyUnlockDevice: @YES
	} clientPort:port withResult:^(NSError *error) {
        if (error) {
            // Print error
            HBLogError(@"[Nougat] openURL error: %@", error);
            return;
        }

        completion();
    }];
}

- (void)_toggleNotificationShadeState {
    if (self.expandedPercent == 1.0) {
        // Collapse to quick view
        [self.delegate contentViewWantsNotificationShadeDismissal:self completely:NO];
    } else if (self.expandedPercent == 0.0) {
        // Show full panel
        [self.delegate contentViewWantsNotificationShadeExpansion:self];
    }
}

#pragma mark - Properties

- (void)setDate:(NSDate *)date {
    _date = date;

    // Update label text
    self.dateLabel.text = [_dateFormatter stringFromDate:date];
}

- (void)setExpandedPercent:(CGFloat)percent {
    _expandedPercent = percent;

    // Update constraints
    _accountConstraint.constant = 20 * percent;
    _preferencesConstraint.constant = 20 * percent;

    // Update alpha
    self.accountView.alpha = percent;
    self.nougatView.alpha = percent;

    // Rotate arrow
    CGFloat angle = M_PI * percent;
    self.arrowView.transform = CGAffineTransformMakeRotation(angle);
}

#pragma mark - Appearance Updates

- (void)traitCollectionDidChange:(UITraitCollection *)previousTraitCollection {
    [super traitCollectionDidChange:previousTraitCollection];

    // Check if appearance changed
    if (@available(iOS 13, *)) {
        if (![self.traitCollection hasDifferentColorAppearanceComparedToTraitCollection:previousTraitCollection]) {
            return;
        }

        self.dateLabel.textColor = [NUAPreferenceManager sharedSettings].textColor;

        _dividerView.backgroundColor = [NUAPreferenceManager sharedSettings].usingDark ? OreoDividerColor : [UIColor clearColor];

        // Update imageView images
        NSString *imageStyle = [NUAPreferenceManager sharedSettings].usingDark ? @"-dark" : @"-light";
        NSBundle *bundle = [NSBundle bundleForClass:[self class]];

        NSString *accountImage = [@"account" stringByAppendingString:imageStyle];
        self.accountView.image = [UIImage imageNamed:accountImage inBundle:bundle];

        NSString *nougatImage = [@"edit" stringByAppendingString:imageStyle];
        self.nougatView.image = [UIImage imageNamed:nougatImage inBundle:bundle];

        NSString *settingsImage = [@"settings" stringByAppendingString:imageStyle];
        self.settingsView.image = [UIImage imageNamed:settingsImage inBundle:bundle];

        NSString *arrowImage = [@"arrow" stringByAppendingString:imageStyle];
        self.arrowView.image = [UIImage imageNamed:arrowImage inBundle:bundle];
    }
}

- (void)backgroundColorDidChange:(NSNotification *)notification {
    NSDictionary<NSString *, UIColor *> *colorInfo = notification.userInfo;
    self.dateLabel.textColor = colorInfo[@"textColor"];

    _dividerView.backgroundColor = [NUAPreferenceManager sharedSettings].usingDark ? OreoDividerColor : [UIColor clearColor];

    // Update imageView images
    NSString *imageStyle = [NUAPreferenceManager sharedSettings].usingDark ? @"-dark" : @"-light";
    NSBundle *bundle = [NSBundle bundleForClass:[self class]];

    NSString *accountImage = [@"account" stringByAppendingString:imageStyle];
    self.accountView.image = [UIImage imageNamed:accountImage inBundle:bundle];

    NSString *nougatImage = [@"edit" stringByAppendingString:imageStyle];
    self.nougatView.image = [UIImage imageNamed:nougatImage inBundle:bundle];

    NSString *settingsImage = [@"settings" stringByAppendingString:imageStyle];
    self.settingsView.image = [UIImage imageNamed:settingsImage inBundle:bundle];

    NSString *arrowImage = [@"arrow" stringByAppendingString:imageStyle];
    self.arrowView.image = [UIImage imageNamed:arrowImage inBundle:bundle];
}

@end