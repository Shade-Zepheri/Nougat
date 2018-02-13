#import "NUADrawerPanel.h"
#import "NUAMainToggleButton.h"
#import "NUAPreferenceManager.h"

@implementation NUADrawerPanel

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        _toggleArray = [NSMutableArray array];
        [self loadToggles];

        _brightnessSection = [[NUABrightnessSectionController alloc] init];
        [self addSubview:_brightnessSection.view];
    }

    return self;
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

@end
