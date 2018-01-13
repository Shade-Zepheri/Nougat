#import "NUABrightnessSectionController.h"
#import "NUADrawerViewController.h"
#import "NUAPreferenceManager.h"

@implementation NUABrightnessSectionController

- (float)backlightLevel {
    return BKSDisplayBrightnessGetCurrent();
}

- (void)loadView {
    // Still needs refactoring, but beginning of rewrite
    self.view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, kScreenWidth - 50, 20)];
}

- (void)viewDidLoad {
    [super viewDidLoad];

    _slider = [[UISlider alloc] initWithFrame:self.view.bounds];
    [self.slider addTarget:self action:@selector(sliderValueDidChange:) forControlEvents:UIControlEventValueChanged];
    [self.slider addTarget:self action:@selector(sliderDidBeginTracking:) forControlEvents:UIControlEventTouchDown];
    [self.slider addTarget:self action:@selector(sliderDidEndTracking:) forControlEvents:UIControlEventTouchCancel];
    [self.slider addTarget:self action:@selector(sliderDidEndTracking:) forControlEvents:UIControlEventTouchUpInside];
    [self.slider addTarget:self action:@selector(sliderDidEndTracking:) forControlEvents:UIControlEventTouchUpOutside];
    self.slider.continuous = YES;
    self.slider.minimumValue = 0;
    self.slider.maximumValue = 1;
    self.slider.minimumTrackTintColor = [NUAPreferenceManager sharedSettings].highlightColor;

    NSBundle *imageBundle = [NSBundle bundleWithPath:@"/var/mobile/Library/Nougat-Resources.bundle"];
    UIImage *thumbImage = [UIImage imageNamed:@"brightness" inBundle:imageBundle compatibleWithTraitCollection:nil];
    [self.slider setThumbImage:thumbImage forState:UIControlStateNormal];
    [self.view addSubview:self.slider];
}

- (void)viewWillAppear:(BOOL)animated {
    NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
    [center addObserver:self selector:@selector(_noteScreenBrightnessDidChange:) name:UIScreenBrightnessDidChangeNotification object:[UIScreen mainScreen]];
    [center addObserver:self selector:@selector(backgroundColorDidChange:) name:@"Nougat/BackgroundColorChange" object:nil];

    [self.slider setValue:[self backlightLevel] animated:NO];

    [super viewWillAppear:animated];
}

- (void)viewDidDisappear:(BOOL)animated {
    BKSDisplayBrightnessTransactionRef brightnessTransaction = _brightnessTransaction;

    if (brightnessTransaction) {
        CFRelease(brightnessTransaction);
        brightnessTransaction = nil;
    }

    [super viewDidDisappear:animated];
}

- (void)sliderDidBeginTracking:(UISlider *)slider {
    [NUADrawerViewController notifyNotificationShade:@"brightness" didActivate:YES];
}

- (void)sliderValueDidChange:(UISlider *)slider {
    if (!_brightnessTransaction) {
        _brightnessTransaction = BKSDisplayBrightnessTransactionCreate(kCFAllocatorDefault);
    }

    BKSDisplayBrightnessSet(slider.value, 1);
}

- (void)sliderDidEndTracking:(UISlider *)slider {
    BKSDisplayBrightnessTransactionRef brightnessTransaction = _brightnessTransaction;

    if (brightnessTransaction) {
        CFRelease(brightnessTransaction);
        _brightnessTransaction = nil;
        [NUADrawerViewController notifyNotificationShade:@"brightness" didActivate:NO];
    }
}

- (void)_noteScreenBrightnessDidChange:(NSNotification *)notification {
    if (self.slider.tracking) {
        return;
    }

    [self.slider setValue:[self backlightLevel] animated:NO];
}

- (void)backgroundColorDidChange:(NSNotification *)notification {
    NSDictionary *colorInfo = notification.userInfo;
    self.slider.minimumTrackTintColor = colorInfo[@"tintColor"];
}

- (void)dealloc {
    BKSDisplayBrightnessTransactionRef brightnessTransaction = _brightnessTransaction;

    if (brightnessTransaction) {
        CFRelease(brightnessTransaction);
    }
}

@end
