#import "NUANotificationShadePanelView.h"
#import <NougatServices/NougatServices.h>
#import "Macros.h"

@interface NUANotificationShadePanelView ()
@property (strong, nonatomic) NSLayoutConstraint *heightConstraint;

@end

@implementation NUANotificationShadePanelView

#pragma mark - Init

- (instancetype)initWithPreferences:(NUAPreferenceManager *)preferences {
    self = [super initWithFrame:CGRectZero];
    if (self) {
        // Init properities
        _notificationShadePreferences = preferences;
        _inset = 0.0;
        self.backgroundColor = preferences.backgroundColor;
        self.translatesAutoresizingMaskIntoConstraints = NO;

        // Constraint
        _heightConstraint = [self.heightAnchor constraintEqualToConstant:150.0];
        _heightConstraint.active = YES;

        // Notifications
        NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
        [center addObserver:self selector:@selector(backgroundColorDidChange:) name:@"NUANotificationShadeChangedBackgroundColor" object:nil];
    }

    return self;
}

#pragma mark - Appearance Updates

- (void)traitCollectionDidChange:(UITraitCollection *)previousTraitCollection {
    [super traitCollectionDidChange:previousTraitCollection];

    // Check if appearance changed
    if (@available(iOS 13, *)) {
        if (![self.traitCollection hasDifferentColorAppearanceComparedToTraitCollection:previousTraitCollection] || !self.notificationShadePreferences.usesSystemAppearance) {
            return;
        }

        self.backgroundColor = self.notificationShadePreferences.backgroundColor;
    }
}

- (void)backgroundColorDidChange:(NSNotification *)notification {
    NSDictionary *colorInfo = notification.userInfo;
    self.backgroundColor = colorInfo[@"backgroundColor"];
}

#pragma mark - Properties

- (void)setInset:(CGFloat)height {
    if (_inset == height) {
        // Nothing to change
        return;
    }

    _inset = height;

    if (height > 150.0) {
        // Reset incase touch doesnt set it exactly to 150
        height = 150.0;
    }

    // Pan down
    self.insetConstraint.constant = height - 150.0;
}

- (void)setRevealPercentage:(CGFloat)percent {
    _revealPercentage = percent;

    // Calculate height
    CGFloat revealPortion = (self.fullyPresentedHeight - 150.0) * percent;
    self.heightConstraint.constant = revealPortion + 150.0;
}

- (void)setContentView:(UIView *)contentView {
    if (_contentView == contentView) {
        return;
    }

    if ([self.contentView superview] == self) {
        [self.contentView removeFromSuperview];
    }

    _contentView = contentView;

    if ([self.contentView superview] == self) {
        return;
    }

    [self addSubview:contentView];

    // Constraints
    self.contentView.translatesAutoresizingMaskIntoConstraints = NO;

    [self.contentView.topAnchor constraintEqualToAnchor:self.topAnchor].active = YES;
    [self.contentView.bottomAnchor constraintEqualToAnchor:self.bottomAnchor].active = YES;
    [self.contentView.leadingAnchor constraintEqualToAnchor:self.leadingAnchor].active = YES;
    [self.contentView.trailingAnchor constraintEqualToAnchor:self.trailingAnchor].active = YES;
}

@end