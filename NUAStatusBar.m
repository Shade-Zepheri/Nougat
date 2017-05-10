#import "headers.h"
#import "NUAStatusBar.h"
#import "NUAPreferenceManager.h"

@implementation NUAStatusBar

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        _imageBundle = [NSBundle bundleWithPath:@"/var/mobile/Library/Nougat-Resources.bundle"];

        self.dateLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 10, frame.size.width / 2, frame.size.height)];
        self.dateLabel.font = [UIFont systemFontOfSize:14];
        self.dateLabel.textColor = [UIColor whiteColor];
        self.dateLabel.backgroundColor = [UIColor clearColor];
        self.dateLabel.textAlignment = NSTextAlignmentLeft;
        [self addSubview:self.dateLabel];

        self.dateFormatter = [[NSDateFormatter alloc] init];
        self.dateFormatter.dateFormat = @"h:mm a - EEE, MMM d";

        NSString *dateString = [self.dateFormatter stringFromDate:[NSDate date]];
        self.dateLabel.text = dateString;

        [NSTimer scheduledTimerWithTimeInterval:10.0 target:self selector:@selector(updateTime:) userInfo:nil repeats:YES];

        [self loadRight];
    }

    return self;
}

- (void)loadRight {
    UIButton *settingsButton = [UIButton buttonWithType:UIButtonTypeCustom];
    settingsButton.frame = CGRectMake(kScreenWidth / 1.3, 10, 20, 20);
    UIImage *settingsCog = [UIImage imageWithContentsOfFile:[_imageBundle pathForResource:@"settings" ofType:@"png"]];
    [settingsButton setImage:settingsCog forState:UIControlStateNormal];
    [settingsButton addTarget:self action:@selector(settingsButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:settingsButton];

}

- (void)settingsButtonTapped:(id)sender {
    [[UIApplication sharedApplication] launchApplicationWithIdentifier:@"com.apple.Preferences" suspended:NO];
}

- (void)updateTime:(NSTimer*)timer {
    NSString *dateString = [self.dateFormatter stringFromDate:[NSDate date]];
    self.dateLabel.text = dateString;
}

- (void)updateTextColor {
    UIColor *backgroundColor = [NUAPreferenceManager sharedSettings].backgroundColor;
    if ([backgroundColor isEqual:NougatDarkColor]) {
        self.dateLabel.textColor = [UIColor whiteColor];
    } else {
        self.dateLabel.textColor = [UIColor blackColor];
    }
}

@end
