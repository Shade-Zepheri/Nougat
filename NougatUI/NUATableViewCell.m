#import "NUATableViewCell.h"
#import "NUARippleButton.h"
#import <UIKit/UIImage+Private.h>

@interface NUATableViewCell ()
@property (strong, nonatomic) UIImageView *glyphView;
@property (strong, nonatomic) UILabel *headerLabel;
@property (strong, nonatomic) NUARippleButton *expandButton;

@property (strong, nonatomic) UIPanGestureRecognizer *expandGestureRecognizer;

@end

@implementation NUATableViewCell

#pragma mark - Initialization

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Defaults
        _expandable = NO;
        _expanded = NO;

        // Finish setup
        [self _configureHeaderView];
    }

    return self;
}

- (void)_configureHeaderView {
    // Glyph view
    _glyphView = [[UIImageView alloc] initWithFrame:CGRectZero];
    self.glyphView.translatesAutoresizingMaskIntoConstraints = NO;

    [self.glyphView.heightAnchor constraintEqualToConstant:18.0].active = YES;
    [self.glyphView.widthAnchor constraintEqualToConstant:18.0].active = YES;

    // Create header label
    _headerLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    self.headerLabel.font = [UIFont preferredFontForTextStyle:UIFontTextStyleSubheadline];
    self.headerLabel.textColor = [UIColor grayColor];
    self.headerLabel.translatesAutoresizingMaskIntoConstraints = NO;

    [self.headerLabel.heightAnchor constraintEqualToConstant:18.0].active = YES;

    // Create "dummy" dot
    UILabel *dotLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    dotLabel.font = [UIFont preferredFontForTextStyle:UIFontTextStyleSubheadline];
    dotLabel.textColor = [UIColor grayColor];
    dotLabel.text = @"•";
    [dotLabel sizeToFit];
    dotLabel.translatesAutoresizingMaskIntoConstraints = NO;

    // Create expand button
    _expandButton = [[NUARippleButton alloc] init];
    [self.expandButton addTarget:self action:@selector(_handleExpandCell:) forControlEvents:UIControlEventTouchUpInside];
    self.expandButton.contentEdgeInsets = UIEdgeInsetsMake(0, 0, 0, 0);
    self.expandButton.hidden = YES;
    self.expandButton.touchAreaInsets = UIEdgeInsetsMake(-10.0, -10.0, -10.0, -10.0);
    self.expandButton.rippleStyle = NUARippleStyleUnbounded;
    self.expandButton.imageView.contentMode = UIViewContentModeScaleAspectFit;
    self.expandButton.translatesAutoresizingMaskIntoConstraints = NO;

    NSBundle *bundle = [NSBundle bundleForClass:self.class];
    UIImage *baseImage = [UIImage imageNamed:@"arrow-dark" inBundle:bundle];
    [self.expandButton setImage:baseImage forState:UIControlStateNormal];

    [self.expandButton.widthAnchor constraintEqualToConstant:18.0].active = YES;
    [self.expandButton.heightAnchor constraintEqualToConstant:18.0].active = YES;

    // Create stack view
    _headerStackView = [[UIStackView alloc] initWithFrame:CGRectZero];
    self.headerStackView.axis = UILayoutConstraintAxisHorizontal;
    self.headerStackView.alignment = UIStackViewAlignmentLastBaseline;
    self.headerStackView.distribution = UIStackViewDistributionEqualSpacing;
    self.headerStackView.spacing = 5.0;
    self.headerStackView.translatesAutoresizingMaskIntoConstraints = NO;
    [self.contentView addSubview:self.headerStackView];

    // Add arranged views
    [self.headerStackView addArrangedSubview:self.glyphView];
    [self.headerStackView addArrangedSubview:self.headerLabel];
    [self.headerStackView addArrangedSubview:dotLabel];
    [self.headerStackView addArrangedSubview:self.expandButton];

    // Create constraints
    [self.headerStackView.topAnchor constraintEqualToAnchor:self.contentView.layoutMarginsGuide.topAnchor constant:2.0].active = YES;
    [self.headerStackView.leadingAnchor constraintEqualToAnchor:self.contentView.layoutMarginsGuide.leadingAnchor].active = YES;
}

#pragma mark - Reuse

- (void)prepareForReuse {
    [super prepareForReuse];

    // Reset stuff
    self.expanded = NO;
}

#pragma mark - Properties

- (NSString *)headerText {
    return self.headerLabel.text;
}

- (void)setHeaderText:(NSString *)headerText {
    if ([self.headerLabel.text isEqualToString:headerText]) {
        // Same text
        return;
    }

    self.headerLabel.text = headerText;
}

- (UIImage *)headerGlyph {
    return self.glyphView.image;
}

- (void)setHeaderGlyph:(UIImage *)headerGlyph {
    if (self.glyphView.image == headerGlyph) {
        // Same image
        return;
    }

    self.glyphView.image = headerGlyph;
}

- (void)setHeaderTint:(UIColor *)headerTint {
    if ([_headerTint isEqual:headerTint]) {
        // Same color
        return;
    }

    // Actually store this one
    _headerTint = headerTint;

    // Set the text color
    self.headerLabel.textColor = headerTint;

    // Since tinting doesnt wanna work
    NSBundle *bundle = [NSBundle bundleForClass:self.class];
    UIImage *baseImage = [UIImage imageNamed:@"arrow-dark" inBundle:bundle];

    // Tint and set
    UIImage *tintedImage = [baseImage _flatImageWithColor:headerTint];
    [self.expandButton setImage:tintedImage forState:UIControlStateNormal];
}

- (void)setExpandable:(BOOL)expandable {
    if (expandable == _expandable) {
        // Nothing to change
        return;
    }

    _expandable = expandable;

    // Hide button
    self.expandButton.hidden = !expandable;

    if (expandable && !self.expandGestureRecognizer) {
        // Add gesture
        self.expandGestureRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(_handlePanGesture:)];
        self.expandGestureRecognizer.delegate = self;
        [self.contentView addGestureRecognizer:self.expandGestureRecognizer];
    } else if (!expandable && self.expandGestureRecognizer) {
        // Remove gesture
        [self.contentView removeGestureRecognizer:self.expandGestureRecognizer];
        self.expandGestureRecognizer.delegate = nil;
        self.expandGestureRecognizer = nil;
    }
}

- (void)setExpanded:(BOOL)expanded {
    if (expanded == _expanded) {
        // No change, or not allowed
        return;
    }

    _expanded = expanded;

    // Flip button image
    CGFloat angle = M_PI * [@(expanded) intValue];
    [UIView transitionWithView:self.expandButton.imageView duration:0.2 options:UIViewAnimationOptionTransitionCrossDissolve animations:^{
        self.expandButton.imageView.transform = CGAffineTransformMakeRotation(angle);
    } completion:nil];
}

#pragma mark - Button

- (void)_handleExpandCell:(NUARippleButton *)button {
    if (!self.expandable) {
        // Do nothing
        return;
    }

    // Notify table
    [self.delegate tableViewCell:self wantsExpansion:!self.expanded];
}

#pragma mark - Gesture Recognizer

- (void)_handlePanGesture:(UIPanGestureRecognizer *)gestureRecognizer {
    if (gestureRecognizer.state != UIGestureRecognizerStateEnded || !self.expandable) {
        // Only trigger on end, or not expandable
        return;
    }

    // Determine if up or down
    CGPoint velocity = [gestureRecognizer velocityInView:self.contentView];
    BOOL expand = velocity.y > 0;
    [self.delegate tableViewCell:self wantsExpansion:expand];
}

- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer {
    if (![gestureRecognizer isKindOfClass:[UIPanGestureRecognizer class]]) {
        // Not dealing with pans
        return NO;
    }

    // Only expand under certain criteria
    UIPanGestureRecognizer *panGestureRecognizer = (UIPanGestureRecognizer *)gestureRecognizer;
    CGPoint velocity = [panGestureRecognizer velocityInView:self.contentView];
    if (fabs(velocity.x) > fabs(velocity.y)) {
        // Horizontal pan, don't do anything
        return NO;
    }

    CGPoint location = [panGestureRecognizer locationInView:self.contentView];
    CGFloat labelHeight = CGRectGetHeight(self.contentView.bounds);
    CGFloat projectedY = location.y + [self project:velocity.y decelerationRate:0.998];
    return (fabs(projectedY) < (labelHeight * 1.69));
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldBeRequiredToFailByGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer {
    // Conflict with table scroll
    return (gestureRecognizer == self.expandGestureRecognizer) && [otherGestureRecognizer isKindOfClass:[UIPanGestureRecognizer class]];
}

- (CGFloat)project:(CGFloat)initialVelocity decelerationRate:(CGFloat)decelerationRate {
    // From WWDC (UIScrollView.decelerationRate = 0.998)
    return (initialVelocity / 1000.0) * decelerationRate / (1.0 - decelerationRate);
}

@end