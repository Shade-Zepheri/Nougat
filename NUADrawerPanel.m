#import "headers.h"
#import "NUADrawerPanel.h"
#import "NUAMainToggleButton.h"
#import "NUAPreferenceManager.h"

@implementation NUADrawerPanel

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.toggleArray = [NSMutableArray array];
        [self loadToggles];
        [self loadBrightnessSlider];
    }

    return self;
}

- (void)loadBrightnessSlider {
    self.brightnessSlider = [[UISlider alloc] initWithFrame:CGRectMake(0, 0, self.frame.size.width, 20)];
    [self.brightnessSlider addTarget:self action:@selector(sliderValueDidChange:) forControlEvents:UIControlEventValueChanged];
    [self.brightnessSlider addTarget:self action:@selector(sliderDidEndTracking:) forControlEvents:UIControlEventTouchCancel];
    [self.brightnessSlider addTarget:self action:@selector(sliderDidEndTracking:) forControlEvents:UIControlEventTouchUpInside];
    [self.brightnessSlider addTarget:self action:@selector(sliderDidEndTracking:) forControlEvents:UIControlEventTouchUpOutside];
    self.brightnessSlider.continuous = YES;
    self.brightnessSlider.minimumValue = 0;
    self.brightnessSlider.maximumValue = 1;
    self.brightnessSlider.minimumTrackTintColor = [NUAPreferenceManager sharedSettings].highlightColor;
    [self.brightnessSlider setValue:[UIScreen mainScreen].brightness animated:NO];

    NSBundle *imageBundle = [NSBundle bundleWithPath:@"/var/mobile/Library/Nougat-Resources.bundle"];
    UIImage *thumbImage = [UIImage imageWithContentsOfFile:[imageBundle pathForResource:@"brightness" ofType:@"png"]];
    [self.brightnessSlider setThumbImage:thumbImage forState:UIControlStateNormal];
    [self addSubview:self.brightnessSlider];
}

- (void)updateSliderValue {
    [self.brightnessSlider setValue:[UIScreen mainScreen].brightness animated:NO];
}

- (void)updateTintTo:(UIColor*)color {
    self.brightnessSlider.minimumTrackTintColor = color;
}

- (void)setBrighness:(CGFloat)value {
    BKSDisplayBrightnessSet(value, 1);
}

- (void)sliderValueDidChange:(UISlider *)sender {
    if (!_brightnessTransaction) {
        self->_brightnessTransaction = BKSDisplayBrightnessTransactionCreate(kCFAllocatorDefault);
    }
    [self setBrighness:self.brightnessSlider.value];
}

- (void)sliderDidEndTracking:(UISlider *)sender {
    BKSDisplayBrightnessTransactionRef brightnessTransaction = self->_brightnessTransaction;

    if (brightnessTransaction) {
        CFRelease(brightnessTransaction);
        self->_brightnessTransaction = nil;
    }
}

- (void)refreshTogglePanel {
    for (NUAMainToggleButton *view in self.toggleArray) {
        [view removeFromSuperview];
    }
    [self.toggleArray removeAllObjects];
    [self loadToggles];
}

- (void)loadToggles {
    NSArray *togglesArray = [NUAPreferenceManager sharedSettings].mainPanelOrder;
    NSInteger toggleNumber = 0;
    NSInteger currentRow = 0;
    CGFloat width = self.frame.size.width / 3;

    for (int i = 0; i < togglesArray.count; i++) {
        CGFloat x = width * toggleNumber;
        CGFloat y = currentRow * width;

        toggleNumber++;
        if (toggleNumber >= 3) {
            //start new row
            toggleNumber = 0;
            currentRow++;
        }

        CGRect frame = CGRectMake(x, y + 30, width, width);
        NUAMainToggleButton *view = [[NUAMainToggleButton alloc] initWithFrame:frame andSwitchIdentifier:togglesArray[i]];
        [self.toggleArray addObject:view];
        [self addSubview:view];
    }
}

- (void)dealloc {
    BKSDisplayBrightnessTransactionRef brightnessTransaction = self->_brightnessTransaction;

    if (brightnessTransaction) {
        CFRelease(brightnessTransaction);
    }
}

@end
