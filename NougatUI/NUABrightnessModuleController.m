#import "NUABrightnessModuleController.h"
#import "NUANotificationShadeController.h"
#import <UIKit/UIImage+Private.h>

@implementation NUABrightnessModuleController

- (NSString *)moduleIdentifier {
    return @"com.shade.nougat.brightness";
}

- (float)backlightLevel {
    return BKSDisplayBrightnessGetCurrent();
}

#pragma mark - UIViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    // Register for notifications
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(backgroundColorDidChange:) name:@"NUANotificationShadeChangedBackgroundColor" object:nil];

    _slider = [[UISlider alloc] initWithFrame:CGRectZero];
    [self.slider addTarget:self action:@selector(sliderValueDidChange:) forControlEvents:UIControlEventValueChanged];
    [self.slider addTarget:self action:@selector(sliderDidBeginTracking:) forControlEvents:UIControlEventTouchDown];
    [self.slider addTarget:self action:@selector(sliderDidEndTracking:) forControlEvents:UIControlEventTouchCancel];
    [self.slider addTarget:self action:@selector(sliderDidEndTracking:) forControlEvents:UIControlEventTouchUpInside];
    [self.slider addTarget:self action:@selector(sliderDidEndTracking:) forControlEvents:UIControlEventTouchUpOutside];
    self.slider.continuous = YES;
    self.slider.minimumValue = 0;
    self.slider.maximumValue = 1;
    self.slider.minimumTrackTintColor = self.notificationShadePreferences.highlightColor;
    self.slider.alpha = 0.0;

    NSString *imageName = [NSString stringWithFormat:@"brightness-%@", self.notificationShadePreferences.usingDark ? @"dark" : @"light"];
    NSBundle *bundle = [NSBundle bundleForClass:[self class]];
    UIImage *thumbImage = [UIImage imageNamed:imageName inBundle:bundle];
    [self.slider setThumbImage:thumbImage forState:UIControlStateNormal];
    [self.view addSubview:self.slider];

    // Constraints
    self.slider.translatesAutoresizingMaskIntoConstraints = NO;

    [self.slider.topAnchor constraintEqualToAnchor:self.view.topAnchor].active = YES;
    [self.slider.bottomAnchor constraintEqualToAnchor:self.view.bottomAnchor].active = YES;
    [self.slider.leadingAnchor constraintEqualToAnchor:self.view.leadingAnchor constant:35.0].active = YES;
    [self.slider.trailingAnchor constraintEqualToAnchor:self.view.trailingAnchor constant:-35.0].active = YES;
}

- (void)viewWillAppear:(BOOL)animated {
    // Register for notifications
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_noteScreenBrightnessDidChange:) name:UIScreenBrightnessDidChangeNotification object:[UIScreen mainScreen]];

    [self.slider setValue:[self backlightLevel] animated:NO];

    [super viewWillAppear:animated];
}

- (void)viewDidDisappear:(BOOL)animated {
    // Deregister for notifications
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIScreenBrightnessDidChangeNotification object:nil];

    if (_brightnessTransaction) {
        CFRelease(_brightnessTransaction);
        _brightnessTransaction = nil;
    }

    [super viewDidDisappear:animated];
}

- (void)dealloc {
    NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
    [center removeObserver:self];

    if (_brightnessTransaction) {
        CFRelease(_brightnessTransaction);
    }
}

#pragma mark - Properties

- (void)setRevealPercentage:(CGFloat)percent {
    _revealPercentage = percent;

    CGFloat defaultModuleHeight = [self.class defaultModuleHeight];
    _heightConstraint.constant = percent * defaultModuleHeight;

    // Update slider alpha with delay
    self.slider.alpha = (percent - 0.5) * 2;
}

#pragma mark - Slider Delegate

- (void)sliderDidBeginTracking:(UISlider *)slider {
    [NUANotificationShadeController notifyNotificationShade:@"brightness" didActivate:YES];
}

- (void)sliderValueDidChange:(UISlider *)slider {
    if (!_brightnessTransaction) {
        _brightnessTransaction = BKSDisplayBrightnessTransactionCreate(kCFAllocatorDefault);
    }

    BKSDisplayBrightnessSet(slider.value, 1);
}

- (void)sliderDidEndTracking:(UISlider *)slider {
    if (!_brightnessTransaction) {
        return;
    }

    CFRelease(_brightnessTransaction);
    _brightnessTransaction = nil;
    [NUANotificationShadeController notifyNotificationShade:@"brightness" didActivate:NO];
}

#pragma mark - Notifications

- (void)_noteScreenBrightnessDidChange:(NSNotification *)notification {
    if (self.slider.tracking) {
        return;
    }

    [self.slider setValue:[self backlightLevel] animated:NO];
}

#pragma mark - Appearance Updates

- (void)traitCollectionDidChange:(UITraitCollection *)previousTraitCollection {
    [super traitCollectionDidChange:previousTraitCollection];

    // Check if appearance changed
    if (@available(iOS 13, *)) {
        if (![self.traitCollection hasDifferentColorAppearanceComparedToTraitCollection:previousTraitCollection] || !self.notificationShadePreferences.usesSystemAppearance) {
            // Not different color, nor using system appearance
            return;
        }

        self.slider.minimumTrackTintColor = self.notificationShadePreferences.highlightColor;

        NSString *imageName = [NSString stringWithFormat:@"brightness-%@", self.notificationShadePreferences.usingDark ? @"dark" : @"light"];
        NSBundle *bundle = [NSBundle bundleForClass:[self class]];
        UIImage *thumbImage = [UIImage imageNamed:imageName inBundle:bundle];
        [self.slider setThumbImage:thumbImage forState:UIControlStateNormal];
    }
}

- (void)backgroundColorDidChange:(NSNotification *)notification {
    NSDictionary<NSString *, UIColor *> *colorInfo = notification.userInfo;

    self.slider.minimumTrackTintColor = colorInfo[@"tintColor"];

    NSString *imageName = [NSString stringWithFormat:@"brightness-%@", self.notificationShadePreferences.usingDark ? @"dark" : @"light"];
    NSBundle *bundle = [NSBundle bundleForClass:[self class]];
    UIImage *thumbImage = [UIImage imageNamed:imageName inBundle:bundle];
    [self.slider setThumbImage:thumbImage forState:UIControlStateNormal];
}

@end
