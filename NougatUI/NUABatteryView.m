#import "NUABatteryView.h"
#import <UIKit/UIImage+Private.h>

@interface NUABatteryView ()
@property (strong, nonatomic) UIView *topBatteryPart;
@property (strong, nonatomic) UIView *bottomBatteryPart;
@property (strong, nonatomic) NSLayoutConstraint *bottomHeightConstraint;
@property (strong, nonatomic) NSLayoutConstraint *topHeightConstraint;

@end

@implementation NUABatteryView

- (instancetype)initWithFrame:(CGRect)frame andPercent:(CGFloat)percent {
    self = [super initWithFrame:frame];
    if (self) {
        // Settings items
        _settings = [NUAPreferenceManager sharedSettings];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(backgroundColorDidChange:) name:@"NUANotificationShadeChangedBackgroundColor" object:nil];

        // View Constraints
        self.translatesAutoresizingMaskIntoConstraints = NO;
        [self.widthAnchor constraintEqualToConstant:23.0].active = YES;

        [self _createCutout];
        [self _createBatteryViews];
    }

    return self;
}

- (void)_createCutout {
    UIColor *backgroundColor = [UIColor colorWithRed:0.62 green:0.62 blue:0.62 alpha:1.0];

    // Bottom cutout
    UIView *bottomCutout = [[UIView alloc] initWithFrame:CGRectZero];
    bottomCutout.backgroundColor = backgroundColor;
    bottomCutout.layer.cornerRadius = 1.0;
    bottomCutout.translatesAutoresizingMaskIntoConstraints = NO;
    [self addSubview:bottomCutout];

    [bottomCutout.leadingAnchor constraintEqualToAnchor:self.leadingAnchor constant:6.0].active = YES;
    [bottomCutout.widthAnchor constraintEqualToConstant:11.0].active = YES;
    [bottomCutout.bottomAnchor constraintEqualToAnchor:self.bottomAnchor constant:-15.0].active = YES;
    [bottomCutout.heightAnchor constraintEqualToConstant:18.0].active = YES;

    // Top cutout
    UIView *topCutout = [[UIView alloc] initWithFrame:CGRectZero];
    topCutout.backgroundColor = backgroundColor;
    topCutout.layer.cornerRadius = 0.5;
    topCutout.translatesAutoresizingMaskIntoConstraints = NO;
    [self addSubview:topCutout];

    [topCutout.bottomAnchor constraintEqualToAnchor:bottomCutout.topAnchor].active = YES;
    [topCutout.widthAnchor constraintEqualToConstant:4.0].active = YES;
    [topCutout.leadingAnchor constraintEqualToAnchor:bottomCutout.leadingAnchor constant:3.5].active = YES;
    [topCutout.heightAnchor constraintEqualToConstant:2.0].active = YES;
}

- (void)_createBatteryViews {
    // Bottom part
    self.bottomBatteryPart = [[UIView alloc] initWithFrame:CGRectZero];
    self.bottomBatteryPart.backgroundColor = self.settings.textColor;
    self.bottomBatteryPart.layer.cornerRadius = 1.0;
    self.bottomBatteryPart.translatesAutoresizingMaskIntoConstraints = NO;
    [self addSubview:self.bottomBatteryPart];

    [self.bottomBatteryPart.leadingAnchor constraintEqualToAnchor:self.leadingAnchor constant:6.0].active = YES;
    [self.bottomBatteryPart.widthAnchor constraintEqualToConstant:11.0].active = YES;
    [self.bottomBatteryPart.bottomAnchor constraintEqualToAnchor:self.bottomAnchor constant:-15.0].active = YES;
    self.bottomHeightConstraint = [self.bottomBatteryPart.heightAnchor constraintEqualToConstant:0.0];
    self.bottomHeightConstraint.active = YES;

    // Top part
    self.topBatteryPart = [[UIView alloc] initWithFrame:CGRectZero];
    self.topBatteryPart.backgroundColor = self.settings.textColor;
    self.topBatteryPart.layer.cornerRadius = 0.5;
    self.topBatteryPart.translatesAutoresizingMaskIntoConstraints = NO;
    [self addSubview:self.topBatteryPart];

    [self.topBatteryPart.bottomAnchor constraintEqualToAnchor:self.bottomBatteryPart.topAnchor].active = YES;
    [self.topBatteryPart.widthAnchor constraintEqualToConstant:4.0].active = YES;
    [self.topBatteryPart.leadingAnchor constraintEqualToAnchor:self.bottomBatteryPart.leadingAnchor constant:3.5].active = YES;
    self.topHeightConstraint = [self.topBatteryPart.heightAnchor constraintEqualToConstant:0.0];
    self.topHeightConstraint.active = YES;

    // Charging bolt
    _chargingImage = [[UIImageView alloc] initWithFrame:CGRectZero];
    self.chargingImage.hidden = YES;
    self.chargingImage.image = [self chargingBoltImage];
    self.chargingImage.translatesAutoresizingMaskIntoConstraints = NO;
    [self.bottomBatteryPart addSubview:self.chargingImage];

    [self.chargingImage.leadingAnchor constraintEqualToAnchor:self.bottomBatteryPart.leadingAnchor].active = YES;
    [self.chargingImage.widthAnchor constraintEqualToConstant:11.0].active = YES;
    [self.chargingImage.bottomAnchor constraintEqualToAnchor:self.bottomBatteryPart.bottomAnchor].active = YES;
    [self.chargingImage.heightAnchor constraintEqualToConstant:18.0].active = YES;
}

#pragma mark - Properties

- (void)setCurrentPercent:(CGFloat)currentPercent {
    _currentPercent = currentPercent;

    if (currentPercent > 0.9) {
        // Expand top
        self.bottomHeightConstraint.constant = 18.0;
        self.topHeightConstraint.constant = (currentPercent * 20.0) - 18.0;
    } else {
        // Expand bottom
        self.topHeightConstraint.constant = 0.0;
        self.bottomHeightConstraint.constant = (currentPercent * 20.0);
    }
}

- (void)setCharging:(BOOL)isCharging {
    _charging = isCharging;

    // Reveal charging bolt
    self.chargingImage.hidden = !isCharging;
}

#pragma mark - Image management

- (UIImage *)chargingBoltImage {
    NSString *name = @"charging-";
    NSString *imageStyle = self.settings.usingDark ? @"light" : @"dark";
    name = [name stringByAppendingString:imageStyle];
    NSBundle *bundle = [NSBundle bundleForClass:[self class]];
    return [UIImage imageNamed:name inBundle:bundle];
}

#pragma mark - Appearance Updates

- (void)traitCollectionDidChange:(UITraitCollection *)previousTraitCollection {
    [super traitCollectionDidChange:previousTraitCollection];

    // Check if appearance changed
    if (@available(iOS 13, *)) {
        if (![self.traitCollection hasDifferentColorAppearanceComparedToTraitCollection:previousTraitCollection]) {
            return;
        }

        self.bottomBatteryPart.backgroundColor = self.settings.textColor;
        self.topBatteryPart.backgroundColor = self.settings.textColor;

        self.chargingImage.image = [self chargingBoltImage];
    }
}

- (void)backgroundColorDidChange:(NSNotification *)notification {
    self.bottomBatteryPart.backgroundColor = self.settings.textColor;
    self.topBatteryPart.backgroundColor = self.settings.textColor;

    self.chargingImage.image = [self chargingBoltImage];
}

@end
