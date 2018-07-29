#import "NUATogglesContentView.h"
#import "NUAPreferenceManager.h"

@implementation NUATogglesContentView

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        // Do somethings
        // Please excuse the messiness, extreme prototype

        [self _createToggles];
    }

    return self;
}

#pragma mark - Toggles management

- (void)_createToggles {
    NSMutableArray *toggles = [NSMutableArray array];
    for (NSString *identifier in [NUAPreferenceManager sharedSettings].togglesList) {
        NUAFlipswitchToggle *toggle = [[NUAFlipswitchToggle alloc] initWithFrame:CGRectZero andSwitchIdentifier:identifier];
        [toggles addObject:toggle];
    }
    self.togglesArray = toggles;

    _topRow = [toggles subarrayWithRange:NSMakeRange(0, 3)]; // First 3
    _middleRow = [toggles subarrayWithRange:NSMakeRange(3 , 3)]; // Middle 3
    _bottomRow = [toggles subarrayWithRange:NSMakeRange(6, 3)]; // Last 3
}

- (void)_updateToggleIdentifiers {
    for (int i = 0; i < [NUAPreferenceManager sharedSettings].togglesList.count; i++) {
        NSString *identifier = [NUAPreferenceManager sharedSettings].togglesList[i];
        NUAFlipswitchToggle *toggle = self.togglesArray[i];

        // Reassign identifiers
        if ([toggle.switchIdentifier isEqualToString:identifier]) {
            continue;
        }

        toggle.switchIdentifier = identifier;
    }
}

- (void)_layoutToggles {
    if (self.subviews.count > 0) {
        return;
    }

    CGFloat viewWidth = CGRectGetWidth(self.bounds);
    CGFloat smallWidth = viewWidth / 6;
    CGFloat fullWidth = ((viewWidth - 70) / 3);

    // Layout quick toggles view
    for (int i = 0; i < 6; i++) {
        NUAFlipswitchToggle *toggle = self.togglesArray[i];
        [self addSubview:toggle];
        
        CGFloat width = smallWidth;
        CGFloat x = width * i;
        toggle.frame = CGRectMake(x, 0, width, CGRectGetHeight(self.bounds));
    }

    // Layout bottom row
    for (int i = 0; i < _bottomRow.count; i++) {
        NUAFlipswitchToggle *toggle = _bottomRow[i];
        [self addSubview:toggle];

        CGFloat x = (fullWidth * i) + 35;
        toggle.alpha = 0.0;
        toggle.frame = CGRectMake(x, CGRectGetHeight(self.frame), fullWidth, 0);
    }

    _startingWidth = smallWidth;
    _widthDifference = fullWidth - _startingWidth;
}

#pragma mark - Rearrangement

- (void)rearrangeForPercent:(CGFloat)percent {
    CGFloat newWidth = _startingWidth + (_widthDifference * percent);
    CGFloat newHeight = 50 + (50 * percent);

    // Update size for first 6
    for (int i = 0; i < 6; i++) {
        NUAFlipswitchToggle *toggle = self.togglesArray[i];
        CGRect oldFrame = toggle.frame;
        toggle.frame = CGRectMake(oldFrame.origin.x, oldFrame.origin.y, newWidth, newHeight);
    }

    // Update first row
    for (int i = 0; i < _topRow.count; i++) {
        NUAFlipswitchToggle *toggle = _topRow[i];
        CGRect oldFrame = toggle.frame;
        CGFloat newX = (i * newWidth) + (35 * percent);
        toggle.frame = CGRectMake(newX, oldFrame.origin.y, CGRectGetWidth(oldFrame), CGRectGetHeight(oldFrame));
    }

    // Shift middle row
    for (int i = 0; i < _middleRow.count; i++) {
        NUAFlipswitchToggle *toggle = _middleRow[i];

        CGRect oldFrame = toggle.frame;
        CGFloat originalX = _startingWidth * (i + 3);
        CGFloat targetX = (i * newWidth) + (35 * percent);
        CGFloat newX = originalX - ((originalX - targetX) * percent);
        CGFloat newY = 100 * percent;
        toggle.frame = CGRectMake(newX, newY, CGRectGetWidth(oldFrame), CGRectGetHeight(oldFrame));
    }

    // Update bottom row
    for (NUAFlipswitchToggle *toggle in _bottomRow) {
        CGRect oldFrame = toggle.frame;
        CGFloat newY = ((CGRectGetHeight(self.frame) - (50 * percent)) / 3)  * 2;
        CGFloat height = 100 * percent;

        toggle.alpha = percent;
        toggle.frame = CGRectMake(oldFrame.origin.x, newY, CGRectGetWidth(oldFrame), height);
    }
}

#pragma mark - Properties

- (void)setExpandedPercent:(CGFloat)percent {
    _expandedPercent = percent;

    [self rearrangeForPercent:percent];

    for (NUAFlipswitchToggle *toggle in self.togglesArray) {
        toggle.displayName.alpha = percent;
    }
}

@end