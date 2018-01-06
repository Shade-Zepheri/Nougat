#import "headers.h"
#import "NUADrawerController.h"
#import "NUAStatusBar.h"
#import "NUAPreferenceManager.h"

@implementation NUAStatusBar

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.resourceBundle = [NSBundle bundleWithPath:@"/var/mobile/Library/Nougat-Resources.bundle"];

        self.dateLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 0, frame.size.width / 2, frame.size.height)];
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
    UIImage *settingsCog = [UIImage imageWithContentsOfFile:[self.resourceBundle pathForResource:@"settings" ofType:@"png"]];
    [settingsButton setImage:settingsCog forState:UIControlStateNormal];
    [settingsButton addTarget:self action:@selector(settingsButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:settingsButton];

    self.toggleButton = [UIButton buttonWithType:UIButtonTypeCustom];
    self.toggleButton.frame = CGRectMake(kScreenWidth / 1.1, 10, 20, 20);
    UIImage *arrow = [UIImage imageWithContentsOfFile:[self.resourceBundle pathForResource:@"showMain" ofType:@"png"]];
    [self.toggleButton setImage:arrow forState:UIControlStateNormal];
    [self.toggleButton addTarget:self action:@selector(toggleButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:self.toggleButton];

}

- (void)settingsButtonTapped:(id)sender {
    [[NUADrawerController sharedInstance] dismissDrawer];
    [(SpringBoard *)[UIApplication sharedApplication] launchApplicationWithIdentifier:@"com.apple.Preferences" suspended:NO];
}

- (void)toggleButtonTapped:(id)sender {
    if ([[NUADrawerController sharedInstance] mainTogglesVisible]) {
        [[NUADrawerController sharedInstance] showQuickToggles];
    } else {
        [[NUADrawerController sharedInstance] showMainToggles];
    }
}

- (void)updateToggle:(BOOL)toggled {
    NSString *arrowName = toggled ? @"dismissMain" : @"showMain";
    UIImage *arrow = [UIImage imageNamed:arrowName inBundle:self.resourceBundle compatibleWithTraitCollection:nil];
    [self.toggleButton setImage:arrow forState:UIControlStateNormal];
}

- (void)updateTime:(NSTimer *)timer {
    NSString *dateString = [self.dateFormatter stringFromDate:[NSDate date]];
    self.dateLabel.text = dateString;
}

@end
