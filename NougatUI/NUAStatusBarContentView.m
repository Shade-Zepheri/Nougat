#import "NUAStatusBarContentView.h"
#import <BaseBoard/BaseBoard.h>
#import <NougatServices/NougatServices.h>
#import <UIKit/UIKit+Private.h>
#import <UIKit/UIStatusBar.h>
#import <UIKit/UIApplication+Private.h>
#import <sys/utsname.h>
#import <math.h>
#import <UIKitHelpers.h>

@interface NUAStatusBarContentView ()
@property (strong, nonatomic) NSNumberFormatter *percentFormatter;

@end

@implementation NUAStatusBarContentView

#pragma mark - Init

- (instancetype)initWithPreferences:(NUAPreferenceManager *)preferences systemServicesProvider:(id<NUASystemServicesProvider>)systemServicesProvider {
    self = [super initWithPreferences:preferences systemServicesProvider:systemServicesProvider];
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

#pragma mark - View Creation

- (void)_createCarrierLabel {
    _carrierLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    self.carrierLabel.font = [UIFont systemFontOfSize:15];
    self.carrierLabel.lineBreakMode = NSLineBreakByTruncatingTail;
    self.carrierLabel.textColor = self.notificationShadePreferences.textColor;
    self.carrierLabel.textAlignment = NSTextAlignmentLeft;
    self.carrierLabel.text = [self _carrierText];
    self.carrierLabel.translatesAutoresizingMaskIntoConstraints = NO;
    [self addSubview:self.carrierLabel];

    // Constraints (Massive mess but keeps things clean)
    [self.carrierLabel.topAnchor constraintEqualToAnchor:self.topAnchor].active = YES;
    [self.carrierLabel.leadingAnchor constraintEqualToAnchor:self.leadingAnchor constant:20.0].active = YES;
    [self.carrierLabel.heightAnchor constraintEqualToAnchor:self.heightAnchor].active = YES;
    CGFloat leadingNotchInsetWidth = [self _leadingNotchInsetWidth];
    [self.carrierLabel.widthAnchor constraintLessThanOrEqualToConstant:leadingNotchInsetWidth].active = YES;
}

- (void)_createPercentLabel {
    // Since percent label would get cutoff by notch, dont add it on notched devices
    if ([self.notificationShadePreferences.class _deviceHasNotch]) {
        return;
    }

    // Create label
    _batteryLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    self.batteryLabel.textColor = self.notificationShadePreferences.textColor;
    self.batteryLabel.textAlignment = NSTextAlignmentLeft;
    self.batteryLabel.font = [UIFont systemFontOfSize:15];
    self.batteryLabel.translatesAutoresizingMaskIntoConstraints = NO;
    [self addSubview:self.batteryLabel];

    // Constraints
    [self.batteryLabel.topAnchor constraintEqualToAnchor:self.topAnchor].active = YES;
    [self.batteryLabel.trailingAnchor constraintEqualToAnchor:self.batteryView.leadingAnchor].active = YES;
    [self.batteryLabel.heightAnchor constraintEqualToAnchor:self.heightAnchor].active = YES;
}

- (void)_createBatteryView {
    _batteryView = [[NUABatteryView alloc] initWithFrame:CGRectZero andPercent:0.0 preferences:self.notificationShadePreferences];
    [self addSubview:self.batteryView];

    // Constraints
    [self.batteryView.topAnchor constraintEqualToAnchor:self.topAnchor].active = YES;
    [self.batteryView.trailingAnchor constraintEqualToAnchor:self.dateLabel.leadingAnchor].active = YES;
    [self.batteryView.heightAnchor constraintEqualToAnchor:self.heightAnchor].active = YES;
}

- (void)_createDateLabel {
    _dateLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    self.dateLabel.textColor = self.notificationShadePreferences.textColor;
    self.dateLabel.textAlignment = NSTextAlignmentLeft;
    self.dateLabel.font = [UIFont systemFontOfSize:15];
    self.dateLabel.translatesAutoresizingMaskIntoConstraints = NO;
    [self addSubview:self.dateLabel];

    // Constraints
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

#pragma mark - Time Management

- (void)updateFormat {
    [[BSDateFormatterCache sharedInstance] resetFormattersIfNecessary];
}

#pragma mark - Appearance Updates

- (void)traitCollectionDidChange:(UITraitCollection *)previousTraitCollection {
    [super traitCollectionDidChange:previousTraitCollection];

    // Check if appearance changed
    if (@available(iOS 13, *)) {
        if (![self.traitCollection hasDifferentColorAppearanceComparedToTraitCollection:previousTraitCollection] || !self.notificationShadePreferences.usesSystemAppearance) {
            return;
        }

        UIColor *textColor = self.notificationShadePreferences.textColor;

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

#pragma mark - Helper Methods

- (NSString *)_carrierText {
    if ([self.notificationShadePreferences.class carrierName]) {
        return [self.notificationShadePreferences.class carrierName];
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

- (CGFloat)_leadingNotchInsetWidth {
    UIInterfaceOrientation currentOrientation = self.systemServicesProvider.activeInterfaceOrientation;
    CGFloat currentScreenWidth = NUAGetScreenWidthForOrientation(currentOrientation);

    UIStatusBar *statusBar = [UIApplication sharedApplication].statusBar;
    if (statusBar && [statusBar isKindOfClass:NSClassFromString(@"UIStatusBar_Modern")]) {
        // Use notch insets
        UIStatusBar_Modern *modernStatusBar = (UIStatusBar_Modern *)statusBar;
        CGRect leadingFrame = [modernStatusBar frameForPartWithIdentifier:@"fittingLeadingPartIdentifier"];
        BOOL isRTL = [UIApplication sharedApplication].userInterfaceLayoutDirection == UIUserInterfaceLayoutDirectionRightToLeft;
        CGFloat maxLeadingX = isRTL ? (currentScreenWidth - CGRectGetMinX(leadingFrame)) : CGRectGetMaxX(leadingFrame);

        if (fabs(maxLeadingX) > 5000.0) {
            // Screen recording and carplay both cause the leading frame to be infinite, fallback to 1/4
            // Also now on iOS 13, default statusbar is modern, and on non notch devices, rect is infinite
            maxLeadingX = currentScreenWidth / 4;
        }

        return maxLeadingX;
    } else {
        // Regular old frames
        return currentScreenWidth / 3;
    }
}

@end