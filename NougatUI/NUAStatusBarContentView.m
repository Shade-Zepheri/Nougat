#import "NUAStatusBarContentView.h"
#import <BaseBoard/BaseBoard.h>
#import <NougatServices/NougatServices.h>
#import <UIKit/UIKit+Private.h>
#import <sys/utsname.h>

@interface NUAStatusBarContentView ()
@property (strong, nonatomic) NSNumberFormatter *percentFormatter;

@end

@implementation NUAStatusBarContentView

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        // Register for notification
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(backgroundColorDidChange:) name:@"NUANotificationShadeChangedBackgroundColor" object:nil];

        // Create number formatter
        self.percentFormatter = [[NSNumberFormatter alloc] init];
        self.percentFormatter.numberStyle = NSNumberFormatterPercentStyle;

        // Create views
        [self _createCarrierLabel];
        [self _createDateLabel];
        [self _createBatteryView];
        [self _createPercentLabel];
    }

    return self;
}

#pragma mark - View creation

- (NSString *)_carrierText {
    if ([NUAPreferenceManager carrierName]) {
        return [NUAPreferenceManager carrierName];
    } else {
        // Fallback to device type
        struct utsname systemInfo;
        uname(&systemInfo);
        NSString *deviceName = [NSString stringWithCString:systemInfo.machine encoding:NSUTF8StringEncoding];

        // Trim numbers and comma from device name
        NSCharacterSet *characterSet = [NSCharacterSet characterSetWithCharactersInString:@"123456789,"];
        return [deviceName stringByTrimmingCharactersInSet:characterSet];
    }
}

- (void)_createCarrierLabel {
    _carrierLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    self.carrierLabel.textColor = [NUAPreferenceManager sharedSettings].textColor;
    self.carrierLabel.textAlignment = NSTextAlignmentLeft;
    self.carrierLabel.text = [self _carrierText];
    self.carrierLabel.font = [UIFont systemFontOfSize:15];
    [self addSubview:self.carrierLabel];

    // Constraints (Massive mess but keeps things clean)
    self.carrierLabel.translatesAutoresizingMaskIntoConstraints = NO;

    [self.carrierLabel.topAnchor constraintEqualToAnchor:self.topAnchor].active = YES;
    [self.carrierLabel.leadingAnchor constraintEqualToAnchor:self.leadingAnchor constant:20.0].active = YES;
    [self.carrierLabel.heightAnchor constraintEqualToAnchor:self.heightAnchor].active = YES;
}

- (void)_createPercentLabel {
    // Since percent label would get cutoff by notch, dont add it on notched devices
    if ([NUAPreferenceManager _deviceHasNotch]) {
        return;
    }

    // Create label
    _batteryLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    self.batteryLabel.textColor = [NUAPreferenceManager sharedSettings].textColor;
    self.batteryLabel.textAlignment = NSTextAlignmentLeft;
    self.batteryLabel.font = [UIFont systemFontOfSize:15];
    [self addSubview:self.batteryLabel];

    // Constraints
    self.batteryLabel.translatesAutoresizingMaskIntoConstraints = NO;

    [self.batteryLabel.topAnchor constraintEqualToAnchor:self.topAnchor].active = YES;
    [self.batteryLabel.trailingAnchor constraintEqualToAnchor:self.batteryView.leadingAnchor].active = YES;
    [self.batteryLabel.heightAnchor constraintEqualToAnchor:self.heightAnchor].active = YES;
}

- (void)_createBatteryView {
    CGFloat currentPercent = [[UIDevice currentDevice] batteryLevel] * 100;
    _batteryView = [[NUABatteryView alloc] initWithFrame:CGRectZero andPercent:currentPercent];
    [self addSubview:self.batteryView];

    // Constraints
    [self.batteryView.topAnchor constraintEqualToAnchor:self.topAnchor].active = YES;
    [self.batteryView.trailingAnchor constraintEqualToAnchor:self.dateLabel.leadingAnchor].active = YES;
    [self.batteryView.heightAnchor constraintEqualToAnchor:self.heightAnchor].active = YES;
}

- (void)_createDateLabel {
    _dateLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    self.dateLabel.textColor = [NUAPreferenceManager sharedSettings].textColor;
    self.dateLabel.textAlignment = NSTextAlignmentLeft;
    self.dateLabel.font = [UIFont systemFontOfSize:15];
    [self addSubview:self.dateLabel];

    // Constraints
    self.dateLabel.translatesAutoresizingMaskIntoConstraints = NO;

    [self.dateLabel.topAnchor constraintEqualToAnchor:self.topAnchor].active = YES;
    [self.dateLabel.trailingAnchor constraintEqualToAnchor:self.trailingAnchor constant:-20.0].active = YES;
    [self.dateLabel.heightAnchor constraintEqualToAnchor:self.heightAnchor].active = YES;
}

#pragma mark - Properties

- (void)setDate:(NSDate *)date {
    _date = date;

    self.dateLabel.text = [[BSDateFormatterCache sharedInstance] formatDateAsTimeNoAMPM:date];
}

- (void)setCurrentPercent:(CGFloat)currentPercent {
    _currentPercent = currentPercent;

    // Pass to labels
    if (self.batteryLabel) {
        self.batteryLabel.text = [self.percentFormatter stringFromNumber:@(currentPercent)];
    }

    self.batteryView.currentPercent = currentPercent;
}

- (void)setCharging:(BOOL)isCharging {
    _charging = isCharging;

    // Pass to batteryView
    self.batteryView.charging = isCharging;
}

#pragma mark - Time management

- (void)updateFormat {
    [[BSDateFormatterCache sharedInstance] resetFormattersIfNecessary];
}

#pragma mark - Appearance Updates

- (void)traitCollectionDidChange:(UITraitCollection *)previousTraitCollection {
    [super traitCollectionDidChange:previousTraitCollection];

    // Check if appearance changed
    if (@available(iOS 13, *)) {
        if (![self.traitCollection hasDifferentColorAppearanceComparedToTraitCollection:previousTraitCollection]) {
            return;
        }

        UIColor *textColor = [NUAPreferenceManager sharedSettings].textColor;

        self.carrierLabel.textColor = textColor;
        if (self.batteryLabel) {
            self.batteryLabel.textColor = textColor;
        }

        self.dateLabel.textColor = textColor;
    }
}

- (void)backgroundColorDidChange:(NSNotification *)notification {
    NSDictionary *colorInfo = notification.userInfo;
    UIColor *textColor = colorInfo[@"textColor"];

    self.carrierLabel.textColor = textColor;
    if (self.batteryLabel) {
        self.batteryLabel.textColor = textColor;
    }
    self.dateLabel.textColor = textColor;
}

@end