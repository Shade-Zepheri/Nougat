#import "NUAMediaHeaderView.h"
#import <MediaRemote/MediaRemote.h>
#import <UIKit/UIImage+Private.h>

@interface NUAMediaHeaderView ()
@property (strong, nonatomic) UIStackView *stackView;
@property (strong, nonatomic) UILabel *songLabel;
@property (strong, nonatomic) UILabel *artistLabel;

@end

@implementation NUAMediaHeaderView

#pragma mark - Init

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        // Constraints
        self.translatesAutoresizingMaskIntoConstraints = NO;

        // Create the stuffs
        [self createArrangedSubviews];

        self.stackView = [[UIStackView alloc] initWithArrangedSubviews:@[self.songLabel, self.artistLabel]];
        self.stackView.axis = UILayoutConstraintAxisVertical;
        self.stackView.alignment = UIStackViewAlignmentFill;
        self.stackView.distribution = UIStackViewDistributionFill;
        self.stackView.spacing = 5.0;
        self.stackView.translatesAutoresizingMaskIntoConstraints = NO;
        [self addSubview:self.stackView];

        // Constraint this bad boi
        [self.stackView.topAnchor constraintEqualToAnchor:self.topAnchor].active = YES;
        [self.stackView.bottomAnchor constraintEqualToAnchor:self.bottomAnchor].active = YES;
        [self.stackView.leadingAnchor constraintEqualToAnchor:self.leadingAnchor].active = YES;
        [self.stackView.trailingAnchor constraintEqualToAnchor:self.trailingAnchor].active = YES;
    }

    return self;
}

- (void)createArrangedSubviews {
    // Create labels
    self.songLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    self.songLabel.adjustsFontSizeToFitWidth = NO;
    self.songLabel.font = [UIFont preferredFontForTextStyle:UIFontTextStyleHeadline];
    self.songLabel.lineBreakMode = NSLineBreakByTruncatingTail;
    self.songLabel.textColor = [UIColor blackColor];
    self.songLabel.translatesAutoresizingMaskIntoConstraints = NO;

    self.artistLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    self.artistLabel.adjustsFontSizeToFitWidth = NO;
    self.artistLabel.font = [UIFont preferredFontForTextStyle:UIFontTextStyleSubheadline];
    self.artistLabel.lineBreakMode = NSLineBreakByTruncatingTail;
    self.artistLabel.textColor = [UIColor grayColor];
    self.artistLabel.translatesAutoresizingMaskIntoConstraints = NO;
}

#pragma mark - Properties

- (void)setSong:(NSString *)song {
    _song = song;

    self.songLabel.text = song;
}

- (void)setArtist:(NSString *)artist {
    _artist = artist;

    self.artistLabel.text = artist;
}

#pragma mark - Color

- (void)updateWithPrimaryColor:(UIColor *)primaryColor accentColor:(UIColor *)accentColor {
    self.songLabel.textColor = primaryColor;
    self.artistLabel.textColor = accentColor;
}

@end