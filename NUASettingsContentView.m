#import "NUASettingsContentView.h"
#import "NUAPreferenceManager.h"
#import "Macros.h"
#import <UIKit/UIImage+Private.h>

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
    _dividerView.backgroundColor = OreoDividerColor;
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

    BOOL useDark = [[NUAPreferenceManager sharedSettings].textColor isEqual:[UIColor blackColor]];
    NSString *imageStyle = useDark ? @"_black" : @"_white";
    imageName = [imageName stringByAppendingString:imageStyle];

    NSBundle *imageBundle = [NSBundle bundleWithPath:@"/var/mobile/Library/Nougat-Resources.bundle"];
    UIImage *image = [UIImage imageNamed:imageName inBundle:imageBundle];
    imageView.image = image;

    return imageView;
}

#pragma mark - Gesture

- (void)handleTap:(UITapGestureRecognizer *)gestureRecognizer {
    if (!gestureRecognizer.view) {
        return;
    }

    if (gestureRecognizer.view.tag == 4) {
        // Do something else
        [self _toggleNotificationShadeState];
        return;
    }

    NSString *URLString = @"prefs:root=";
    switch (gestureRecognizer.view.tag) {
        case 1:
            URLString = [URLString stringByAppendingString:@"iCloud"];
            break;
        case 2:
            URLString = [URLString stringByAppendingString:@"Nougat"];
            break;
        case 3:
            URLString = [URLString stringByAppendingString:@"Settings"];
            break;
        default:
            break;
    }

    NSURL *URL = [NSURL URLWithString:URLString];
    if (![[UIApplication sharedApplication] openURL:URL]) {
        // Failed
        return;
    }

    [self.delegate contentViewWantsNotificationShadeDismissal:self completely:YES];
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
}

#pragma mark - Notifications

- (void)backgroundColorDidChange:(NSNotification *)notification {
    NSDictionary<NSString *, UIColor *> *colorInfo = notification.userInfo;
    UIColor *textColor = colorInfo[@"textColor"];
    self.dateLabel.textColor = textColor;

    BOOL useDark = [textColor isEqual:[UIColor blackColor]];
    _dividerView.backgroundColor = useDark ? OreoDividerColor : [UIColor clearColor];
}

@end