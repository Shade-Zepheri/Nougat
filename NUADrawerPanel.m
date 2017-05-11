#import "NUADrawerPanel.h"
#import "NUAMainToggleButton.h"

@implementation NUADrawerPanel

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor redColor];
        self.togglesArray = @[@"wifi", @"cellular-data", @"bluetooth", @"do-not-disturb", @"flashlight", @"rotation-lock", @"low-power", @"location", @"airplane-mode"];

        [self loadToggles];
    }

    return self;
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

        CGRect frame = CGRectMake(x, y, width, width);
        UIView *view = [[NUAMainToggleButton alloc] initWithFrame:frame andSwitchIdentifier:togglesArray[i]];
        [self addSubview:view];
    }
}

@end
