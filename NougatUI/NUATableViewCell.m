#import "NUATableViewCell.h"
#import <UIKit/UIImage+Private.h>

@interface NUATableViewCell ()
@property (strong, nonatomic) NSLayoutConstraint *heightConstraint;

@end

@implementation NUATableViewCell

#pragma mark - Init

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Defaults
        self.expanded = NO;

        // Do height constraint
        self.heightConstraint = [self.contentView.heightAnchor constraintEqualToConstant:100.0];
        self.heightConstraint.active = YES;

        // Finish setup
        [self setupViewsAndConstraints];
    }

    return self;
}

- (void)setupViewsAndConstraints {
    // Glyph view
    _glyphView = [[UIImageView alloc] initWithFrame:CGRectZero];
    self.glyphView.translatesAutoresizingMaskIntoConstraints = NO;
    [self.contentView addSubview:self.glyphView];

    // Create header label
    _headerLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    self.headerLabel.font = [UIFont preferredFontForTextStyle:UIFontTextStyleSubheadline];
    self.headerLabel.textColor = [UIColor grayColor];
    self.headerLabel.translatesAutoresizingMaskIntoConstraints = NO;
    [self.contentView addSubview:self.headerLabel];

    // Create expand button
    // Manually layout by subclasses
    _expandButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.expandButton addTarget:self action:@selector(_expandCell:) forControlEvents:UIControlEventTouchUpInside];
    self.expandButton.translatesAutoresizingMaskIntoConstraints = NO;

    // Set image
    NSBundle *bundle = [NSBundle bundleForClass:[self class]];
    UIImage *baseImage = [UIImage imageNamed:@"arrow-dark" inBundle:bundle];
    [self.expandButton setImage:baseImage forState:UIControlStateNormal];
    [self.contentView addSubview:self.expandButton];

    // Constraints
    [self.glyphView.topAnchor constraintEqualToAnchor:self.contentView.layoutMarginsGuide.topAnchor constant:5.0].active = YES;
    [self.glyphView.leadingAnchor constraintEqualToAnchor:self.contentView.layoutMarginsGuide.leadingAnchor constant:5.0].active = YES;
    [self.glyphView.heightAnchor constraintEqualToConstant:18.0].active = YES;
    [self.glyphView.widthAnchor constraintEqualToConstant:18.0].active = YES;

    [self.headerLabel.topAnchor constraintEqualToAnchor:self.glyphView.topAnchor].active = YES;
    [self.headerLabel.leadingAnchor constraintEqualToAnchor:self.glyphView.trailingAnchor constant:5.0].active = YES;
    [self.headerLabel.heightAnchor constraintEqualToConstant:18.0].active = YES;

    [self.expandButton.topAnchor constraintEqualToAnchor:self.glyphView.topAnchor].active = YES;
    [self.expandButton.leadingAnchor constraintEqualToAnchor:self.headerLabel.trailingAnchor constant:5.0].active = YES;
    [self.expandButton.heightAnchor constraintEqualToConstant:18.0].active = YES;
    [self.expandButton.widthAnchor constraintEqualToConstant:18.0].active = YES;
}

#pragma mark - Reuse

- (void)prepareForReuse {
    [super prepareForReuse];

    // Reset stuff
    self.expanded = NO;
}

#pragma mark - Properties

- (void)setExpanded:(BOOL)expanded {
    _expanded = expanded;

    // Chnage constraints
    self.heightConstraint.constant = expanded ? 150.0 : 100.0;

    // Flip image
    CGFloat angle = M_PI * [@(expanded) intValue];
    [UIView transitionWithView:self.expandButton.imageView duration:0.2 options:UIViewAnimationOptionTransitionCrossDissolve animations:^{
        self.expandButton.imageView.transform = CGAffineTransformMakeRotation(angle);
    } completion:nil];
}

#pragma mark - Button

- (void)_expandCell:(UIButton *)sender {
    // Notify table
    [self.delegate tableViewCell:self wantsExpand:!self.expanded];
}

@end