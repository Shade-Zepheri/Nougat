#import "NUATogglesContentView.h"
#import <NougatServices/NougatServices.h>
#import <Macros.h>

@interface NUATogglesContentView () {
    CGFloat _targetWidthConstant;

    NSArray<NUAToggleButton *> *_topRow;
    NSArray<NUAToggleButton *> *_middleRow;
    NSArray<NUAToggleButton *> *_bottomRow;
}
@property (strong, nonatomic) NSMutableArray<NSLayoutConstraint *> *heightConstraints;
@property (strong, nonatomic) NSMutableArray<NSLayoutConstraint *> *widthConstraints;
@property (strong, nonatomic) NSLayoutConstraint *topLeftInsetConstraint;
@property (strong, nonatomic) NSLayoutConstraint *middleTopInsetConstraint;
@property (strong, nonatomic) NSLayoutConstraint *middleRightInsetConstraint;

@property (strong, nonatomic) UIStackView *topStackView;
@property (strong, nonatomic) UIStackView *middleStackView;
@property (strong, nonatomic) UIStackView *bottomStackView;

@end

@implementation NUATogglesContentView

#pragma mark - Initialization

- (instancetype)initWithPreferences:(NUAPreferenceManager *)preferences {
    self = [super initWithPreferences:preferences];
    if (self) {
        // Set properties
        _arranged = NO;
        _heightConstraints = [NSMutableArray array];
        _widthConstraints = [NSMutableArray array];
    }

    return self;
}

#pragma mark - Toggles Population

- (void)populateWithToggles:(NSArray<NUAToggleButton *> *)toggleButtons {
    // Set array
    _toggleButtons = toggleButtons;

    // Set delegate
    for (NUAToggleButton *toggle in toggleButtons) {
        toggle.delegate = self;
    }

    // Construct subarrays
    if (toggleButtons.count > 6) {
        _topRow = [toggleButtons subarrayWithRange:NSMakeRange(0, 3)]; // First 3
        _middleRow = [toggleButtons subarrayWithRange:NSMakeRange(3 , 3)]; // Middle 3
        _bottomRow = [toggleButtons subarrayWithRange:NSMakeRange(6, toggleButtons.count - 6)];
    } else if (toggleButtons.count > 3) {
        _topRow = [toggleButtons subarrayWithRange:NSMakeRange(0, 3)]; // First 3
        _middleRow = [toggleButtons subarrayWithRange:NSMakeRange(3 , toggleButtons.count - 3)]; 
    } else {
        _topRow = toggleButtons;
    }

    // Layout
    [self _layoutToggles];
}

- (void)_layoutToggles {
    if (self.arranged) {
        return;
    }

    // Create containers
    self.topStackView = [[UIStackView alloc] initWithFrame:CGRectZero];
    self.topStackView.axis = UILayoutConstraintAxisHorizontal;
    self.topStackView.alignment = UIStackViewAlignmentFill;
    self.topStackView.distribution = UIStackViewDistributionFillEqually;
    self.topStackView.spacing = 0.0;
    self.topStackView.translatesAutoresizingMaskIntoConstraints = NO;
    [self addSubview:self.topStackView];

    [self.topStackView.topAnchor constraintEqualToAnchor:self.topAnchor].active = YES;

    self.topLeftInsetConstraint = [self.topStackView.leadingAnchor constraintEqualToAnchor:self.leadingAnchor];
    self.topLeftInsetConstraint.active = YES;

    NSLayoutConstraint *widthConstraint = [self.topStackView.widthAnchor constraintEqualToAnchor:self.widthAnchor multiplier:0.5];
    widthConstraint.active = YES;
    [self.widthConstraints addObject:widthConstraint];

    NSLayoutConstraint *heightConstraint = [self.topStackView.heightAnchor constraintEqualToConstant:50.0];
    heightConstraint.active = YES;
    [self.heightConstraints addObject:heightConstraint];

    for (NUAToggleButton *toggle in _topRow) {
        [self.topStackView addArrangedSubview:toggle];
    }

    if (_middleRow) {
        [self _createMiddleRow];
    }

    if (_bottomRow) {
        [self _createBottomRow];
    }

    _arranged = YES;
}

- (void)_createMiddleRow {
    self.middleStackView = [[UIStackView alloc] initWithFrame:CGRectZero];
    self.middleStackView.axis = UILayoutConstraintAxisHorizontal;
    self.middleStackView.alignment = UIStackViewAlignmentFill;
    self.middleStackView.distribution = UIStackViewDistributionFillEqually;
    self.middleStackView.spacing = 0.0;
    self.middleStackView.translatesAutoresizingMaskIntoConstraints = NO;
    [self addSubview:self.middleStackView];

    self.middleTopInsetConstraint = [self.middleStackView.topAnchor constraintEqualToAnchor:self.topAnchor];
    self.middleTopInsetConstraint.active = YES;

    self.middleRightInsetConstraint = [self.middleStackView.trailingAnchor constraintEqualToAnchor:self.trailingAnchor];
    self.middleRightInsetConstraint.active = YES;

    NSLayoutConstraint *widthConstraint = [self.middleStackView.widthAnchor constraintEqualToAnchor:self.widthAnchor multiplier:0.5];
    widthConstraint.active = YES;
    [self.widthConstraints addObject:widthConstraint];

    NSLayoutConstraint *heightConstraint = [self.middleStackView.heightAnchor constraintEqualToConstant:50.0];
    heightConstraint.active = YES;
    [self.heightConstraints addObject:heightConstraint];

    for (NUAToggleButton *toggle in _middleRow) {
        [self.middleStackView addArrangedSubview:toggle];
    }
}

- (void)_createBottomRow {
    self.bottomStackView = [[UIStackView alloc] initWithFrame:CGRectZero];
    self.bottomStackView.axis = UILayoutConstraintAxisHorizontal;
    self.bottomStackView.alignment = UIStackViewAlignmentFill;
    self.bottomStackView.distribution = UIStackViewDistributionFillEqually;
    self.bottomStackView.spacing = 0.0;
    self.bottomStackView.translatesAutoresizingMaskIntoConstraints = NO;
    [self addSubview:self.bottomStackView];

    [self.bottomStackView.topAnchor constraintEqualToAnchor:self.middleStackView.bottomAnchor].active = YES;
    [self.bottomStackView.leadingAnchor constraintEqualToAnchor:self.leadingAnchor constant:35].active = YES;
    [self.bottomStackView.trailingAnchor constraintEqualToAnchor:self.trailingAnchor constant:-35].active = YES;

    NSLayoutConstraint *heightConstraint = [self.bottomStackView.heightAnchor constraintEqualToConstant:50.0];
    heightConstraint.active = YES;
    [self.heightConstraints addObject:heightConstraint];

    for (NUAToggleButton *toggle in _bottomRow) {
        [self.bottomStackView addArrangedSubview:toggle];
        toggle.alpha = 0.0;
    }
}

#pragma mark - Toggle Reset

- (void)_resetToggleState {
    // Reset alpha and remove
    for (NUAToggleButton *toggle in self.toggleButtons) {
        toggle.displayNameLabel.alpha = 0.0;
        toggle.alpha = 1.0;
        [toggle removeFromSuperview];
    }
}

- (void)tearDownCurrentToggles {
    _arranged = NO;

    // Reset toggles
    [self _resetToggleState];

    // Reset arrays and views
    _topRow = nil;
    _middleRow = nil;
    _bottomRow = nil;

    [self.topStackView removeFromSuperview];
    [self.middleStackView removeFromSuperview];
    [self.bottomStackView removeFromSuperview];

    self.topStackView = nil;
    self.middleStackView = nil;
    self.bottomStackView = nil;
}

#pragma mark - Positioning

static inline CGFloat easingXForT(CGFloat t) {
    return (3 * (1 - t) * t * t * 0.2) + (t * t * t);
}

static inline CGFloat easingYForT(CGFloat t) {
    return (3 * (1 - t) * t * t) + (t * t * t);
}

- (void)rearrangeForPercent:(CGFloat)percent {
    if (!_targetWidthConstant) {
        CGFloat viewWidth = CGRectGetWidth(self.bounds);
        CGFloat startingContainerWidth = viewWidth / 2;
        CGFloat targetWidth = viewWidth - 70;
        _targetWidthConstant = targetWidth - startingContainerWidth;
    }

    // Update top inset and ease
    CGFloat easedYPercent = easingYForT(percent);
    self.middleTopInsetConstraint.constant = 100 * easedYPercent;

    // Update left and ease right inset
    CGFloat easedXPercent = easingXForT(percent);
    self.topLeftInsetConstraint.constant = 35 * percent;
    self.middleRightInsetConstraint.constant = -35 * easedXPercent;

    // Update width
    for (NSLayoutConstraint *constraint in self.widthConstraints) {
        constraint.constant = _targetWidthConstant * easedXPercent;
    }

    // Update height
    for (NSLayoutConstraint *constraint in self.heightConstraints) {
        constraint.constant = 50 + (50 * percent);
    }
}

#pragma mark - Delegate

- (void)toggleWantsNotificationShadeDismissal:(NUAToggleButton *)toggleButton {
    [self.delegate contentViewWantsNotificationShadeDismissal:self];
}

#pragma mark - Properties

- (void)adjustToggleAlphaForPercent:(CGFloat)percent {
    // Delay appearance of labels
    CGFloat adjustedPercent = (percent - 0.75) * 4;
    for (NUAToggleButton *toggle in self.toggleButtons) {
        toggle.displayNameLabel.alpha = adjustedPercent;

        if (!_bottomRow || ![_bottomRow containsObject:toggle]) {
            continue;
        }

        toggle.alpha = adjustedPercent;
    }
}

- (void)setExpandedPercent:(CGFloat)percent {
    _expandedPercent = percent;

    // Rearrange and change alpaha
    [self rearrangeForPercent:percent];
    [self adjustToggleAlphaForPercent:percent];
}

@end