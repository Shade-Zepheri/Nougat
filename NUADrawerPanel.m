#import "headers.h"
#import "NUADrawerPanel.h"
#import "NUAMainToggleButton.h"
#import "NUAPreferenceManager.h"

@implementation NUADrawerPanel

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.togglesArray = @[@"wifi", @"cellular-data", @"bluetooth", @"do-not-disturb", @"flashlight", @"rotation-lock", @"low-power", @"location", @"airplane-mode"];
        [self loadToggles];
        [self loadBrightnessSlider];
    }

    return self;
}

- (void)loadBrightnessSlider {
    self.brightnessSlider = [[UISlider alloc] initWithFrame:CGRectMake(0, 0, self.frame.size.width, 20)];
    [self.brightnessSlider addTarget:self action:@selector(sliderDidChange:) forControlEvents:UIControlEventValueChanged];
    self.brightnessSlider.continuous = YES;
    self.brightnessSlider.minimumValue = 0;
    self.brightnessSlider.maximumValue = 1;
    [self.brightnessSlider setValue:[UIScreen mainScreen].brightness animated:NO];

    NSBundle *imageBundle = [NSBundle bundleWithPath:@"/var/mobile/Library/Nougat-Resources.bundle"];
    UIImage *thumbImage = [UIImage imageWithContentsOfFile:[imageBundle pathForResource:@"brightness" ofType:@"png"]];
    [self.brightnessSlider setThumbImage:thumbImage forState:UIControlStateNormal];
    [self addSubview:self.brightnessSlider];
}

- (void)setBrighness:(CGFloat)value {
    BKSDisplayBrightnessSet(value, 1);
}

- (void)sliderDidChange:(id)sender {
    if (!_brightnessTransaction) {
        self->_brightnessTransaction = BKSDisplayBrightnessTransactionCreate(kCFAllocatorDefault);
    }
    [self setBrighness:self.brightnessSlider.value];
}

- (void)loadToggles {
    NSArray *togglesArray = self.togglesArray;
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
        UIView *view = [[NUAMainToggleButton alloc] initWithFrame:frame andSwitchIdentifier:togglesArray[i]];
        [self addSubview:view];
    }
}

@end
