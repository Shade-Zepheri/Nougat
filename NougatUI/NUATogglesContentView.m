#import "NUATogglesContentView.h"
#import <NougatServices/NougatServices.h>
#import <Macros.h>

@implementation NUATogglesContentView

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        // Load instance manager
        _togglesProvider = [NUAToggleInstancesProvider defaultProvider];

        // Set properties
        _arranged = NO;

        // Populate Toggles
        [self _populateToggles];
    }

    return self;
}

#pragma mark - Toggles management

- (void)_populateToggles {
    self.togglesArray = self.togglesProvider.toggleInstances;

    for (NUAFlipswitchToggle *toggle in self.togglesArray) {
        toggle.delegate = self;
    }

    if (self.togglesArray.count > 6) {
        _topRow = [self.togglesArray subarrayWithRange:NSMakeRange(0, 3)]; // First 3
        _middleRow = [self.togglesArray subarrayWithRange:NSMakeRange(3 , 3)]; // Middle 3
        _bottomRow = [self.togglesArray subarrayWithRange:NSMakeRange(6, self.togglesArray.count - 6)];
    } else if (self.togglesArray.count > 3) {
        _topRow = [self.togglesArray subarrayWithRange:NSMakeRange(0, 3)]; // First 3
        _middleRow = [self.togglesArray subarrayWithRange:NSMakeRange(3 , self.togglesArray.count - 3)]; 
    } else {
        _topRow = self.togglesArray;
    }
}

- (void)_layoutToggles {
    if (self.arranged) {
        return;
    }

    // Create containers
    CGFloat viewWidth = CGRectGetWidth(self.bounds);
    CGFloat containerWidth = viewWidth / 2;
    CGFloat bottomWidth = (viewWidth - 70);

    _topContainerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, containerWidth, CGRectGetHeight(self.bounds))];
    [self addSubview:_topContainerView];
    _middleContainerView = [[UIView alloc] initWithFrame:CGRectMake(containerWidth, 0, containerWidth, CGRectGetHeight(self.bounds))];
    [self addSubview:_middleContainerView];
    _bottomContainerView = [[UIView alloc] initWithFrame:CGRectMake(35, CGRectGetHeight(self.bounds), bottomWidth, 0)];
    _bottomContainerView.alpha = 0.0;
    [self addSubview:_bottomContainerView];

    UIStackView *topStackView = [self _createHorizontalStackViewForView:_topContainerView];
    UIStackView *middleStackView = [self _createHorizontalStackViewForView:_middleContainerView];
    UIStackView *bottomStackView = [self _createHorizontalStackViewForView:_bottomContainerView];

    // Layout quick toggles view
    for (NUAFlipswitchToggle *toggle in _topRow) {
        [topStackView addArrangedSubview:toggle];
    }
    
    if (_middleRow) {
        for (NUAFlipswitchToggle *toggle in _middleRow) {
            [middleStackView addArrangedSubview:toggle];
        }
    }
    
    if (_bottomRow) {
        for (NUAFlipswitchToggle *toggle in _bottomRow) {
            [bottomStackView addArrangedSubview:toggle];
        }
    }

    _startingWidth = containerWidth;
    _widthDifference = bottomWidth - containerWidth;

    _arranged = YES;
}

- (void)refreshToggleLayout {
    _arranged = NO;

    // Remove old views
    [_topContainerView removeFromSuperview];
    [_middleContainerView removeFromSuperview];
    [_bottomContainerView removeFromSuperview];

    _topContainerView = nil;
    _middleContainerView = nil;
    _bottomContainerView = nil;

    _topRow = nil;
    _middleRow = nil;
    _bottomRow = nil;

    // Populate and relayout
    [self _populateToggles];
    [self _layoutToggles];
}

#pragma mark - View creation

- (UIStackView *)_createHorizontalStackViewForView:(UIView *)superView {
    UIStackView *stackView = [[UIStackView alloc] initWithFrame:CGRectZero];
    stackView.axis = UILayoutConstraintAxisHorizontal;
    stackView.alignment = UIStackViewAlignmentFill;
    stackView.distribution = UIStackViewDistributionFillEqually;
    stackView.spacing = 0.0;
    [superView addSubview:stackView];

    // Constraints
    stackView.translatesAutoresizingMaskIntoConstraints = NO;

    [stackView.topAnchor constraintEqualToAnchor:superView.topAnchor].active = YES;
    [stackView.bottomAnchor constraintEqualToAnchor:superView.bottomAnchor].active = YES;
    [stackView.leadingAnchor constraintEqualToAnchor:superView.leadingAnchor].active = YES;
    [stackView.trailingAnchor constraintEqualToAnchor:superView.trailingAnchor].active = YES;

    return stackView;
}

#pragma mark - Rearrangement

- (void)rearrangeForPercent:(CGFloat)percent {
    CGFloat newWidth = _startingWidth + (_widthDifference * percent);
    CGFloat newHeight = 50 + (50 * percent);

    // Update first row
    _topContainerView.frame = CGRectMake(35 * percent, 0, newWidth, newHeight);

    // Shift middle row
    CGFloat originalX = _startingWidth;
    CGFloat targetX = (35 * percent);
    CGFloat newX = originalX - ((originalX - targetX) * percent);
    _middleContainerView.frame = CGRectMake(newX, 100 * percent, newWidth, newHeight);

    // Update bottom row
    CGRect oldFrame = _bottomContainerView.frame;
    CGFloat newY = ((CGRectGetHeight(self.frame) - (50 * percent)) / 3)  * 2;
    _bottomContainerView.alpha = percent;
    _bottomContainerView.frame = CGRectMake(35, newY, CGRectGetWidth(oldFrame), 100 * percent);
}

#pragma mark - Delegate

- (void)toggleWantsNotificationShadeDismissal:(NUAFlipswitchToggle *)toggle {
    [self.delegate contentViewWantsNotificationShadeDismissal:self];
}

#pragma mark - Properties

- (void)setExpandedPercent:(CGFloat)percent {
    _expandedPercent = percent;

    [self rearrangeForPercent:percent];

    for (NUAFlipswitchToggle *toggle in self.togglesArray) {
        toggle.toggleLabel.alpha = percent;
    }
}

@end