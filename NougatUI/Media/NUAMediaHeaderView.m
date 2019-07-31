#import "NUAMediaHeaderView.h"
#import <MediaRemote/MediaRemote.h>
#import <SpringBoardServices/SpringBoardServices+Private.h>
#import <UIKit/UIImage+Private.h>

@interface NUAMediaHeaderView ()
@property (strong, nonatomic) UIStackView *stackView;
@property (strong, nonatomic) UIImageView *appImage;
@property (strong, nonatomic) UILabel *infoLabel;
@property (strong, nonatomic) UILabel *songLabel;
@property (strong, nonatomic) UILabel *artistLabel;
@property (strong, nonatomic) NSLayoutConstraint *songWidthConstraint;
@property (strong, nonatomic) NSLayoutConstraint *artistWidthConstraint;

@end

@implementation NUAMediaHeaderView

#pragma mark - Init

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        // Defaults
        _expanded = NO;

        // Create the stuffs
        [self createArrangedSubviews];

        // Create dummy container for header and image
        UIView *containerView = [[UIView alloc] initWithFrame:CGRectZero];
        containerView.translatesAutoresizingMaskIntoConstraints = NO;
        [containerView addSubview:self.appImage];
        [containerView addSubview:self.infoLabel];

        [containerView.heightAnchor constraintEqualToConstant:18.0].active = YES;

        // Constrain header accorindly
        [self.appImage.topAnchor constraintEqualToAnchor:containerView.topAnchor].active = YES;
        [self.appImage.leadingAnchor constraintEqualToAnchor:containerView.leadingAnchor].active = YES;
        [self.appImage.heightAnchor constraintEqualToAnchor:containerView.heightAnchor].active = YES;
        [self.appImage.widthAnchor constraintEqualToAnchor:containerView.heightAnchor].active = YES;

        [self.infoLabel.topAnchor constraintEqualToAnchor:containerView.topAnchor].active = YES;
        [self.infoLabel.leadingAnchor constraintEqualToAnchor:self.appImage.trailingAnchor constant:5.0].active = YES;
        [self.infoLabel.trailingAnchor constraintEqualToAnchor:containerView.trailingAnchor].active = YES;
        [self.infoLabel.heightAnchor constraintEqualToAnchor:containerView.heightAnchor].active = YES;

        self.stackView = [[UIStackView alloc] initWithArrangedSubviews:@[containerView, self.songLabel, self.artistLabel]];
        self.stackView.axis = UILayoutConstraintAxisVertical;
        self.stackView.alignment = UIStackViewAlignmentLeading;
        self.stackView.distribution = UIStackViewDistributionFill;
        self.stackView.spacing = 5.0;
        self.stackView.translatesAutoresizingMaskIntoConstraints = NO;
        [self addSubview:self.stackView];

        // Constraint this bad boi
        [self.stackView.topAnchor constraintEqualToAnchor:self.topAnchor].active = YES;
        [self.stackView.bottomAnchor constraintEqualToAnchor:self.bottomAnchor].active = YES;
        [self.stackView.leadingAnchor constraintEqualToAnchor:self.leadingAnchor].active = YES;
        [self.stackView.trailingAnchor constraintEqualToAnchor:self.trailingAnchor].active = YES;

        // Additional constraints
        self.songWidthConstraint = [self.songLabel.widthAnchor constraintEqualToAnchor:self.widthAnchor constant:0.0];
        self.songWidthConstraint.active = YES;

        self.artistWidthConstraint = [self.artistLabel.widthAnchor constraintEqualToAnchor:self.widthAnchor constant:0.0];
        self.artistWidthConstraint.active = YES;
    }

    return self;
}

- (void)createArrangedSubviews {
    // Create top label
    self.appImage = [[UIImageView alloc] initWithFrame:CGRectZero];
    self.appImage.translatesAutoresizingMaskIntoConstraints = NO;

    self.infoLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    self.infoLabel.font = [UIFont preferredFontForTextStyle:UIFontTextStyleSubheadline];
    self.infoLabel.textColor = [UIColor grayColor];
    self.infoLabel.translatesAutoresizingMaskIntoConstraints = NO;

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

- (void)setExpanded:(BOOL)expanded {
    _expanded = expanded;

    // Adjust constraints
}

- (void)setTintColor:(UIColor *)color {
    _tintColor = color;

    // Update image tint
    UIImage *appIcon = [UIImage _applicationIconImageForBundleIdentifier:self.nowPlayingApp format:0 scale:[UIScreen mainScreen].scale];
    self.appImage.image = appIcon;

    // Update label tint
    self.infoLabel.textColor = color;
    self.songLabel.textColor = color;
    self.artistLabel.textColor = color;
}

- (void)setAlbum:(NSString *)album {
    _album = album;

    [self _updateInfoLabelText];
}

- (void)setSong:(NSString *)song {
    _song = song;

    self.songLabel.text = song;
    [self.songLabel sizeToFit];
}

- (void)setArtist:(NSString *)artist {
    _artist = artist;

    self.artistLabel.text = artist;
    [self.artistLabel sizeToFit];
}

- (void)setNowPlayingApp:(NSString *)bundleIdentifier {
    _nowPlayingApp = bundleIdentifier;

    // Update imageview
    [self _updateInfoLabelText];
    UIImage *appIcon = [UIImage _applicationIconImageForBundleIdentifier:bundleIdentifier format:0 scale:[UIScreen mainScreen].scale];
    self.appImage.image = appIcon;
}

- (void)_updateInfoLabelText {
    // Construct strings
    NSString *displayID = self.nowPlayingApp ?: @"com.apple.Music";
    NSString *appDisplayName = SBSCopyLocalizedApplicationNameForDisplayIdentifier(displayID);
    NSString *baseText = [NSString stringWithFormat:@"%@ • %@", appDisplayName, self.album];

    NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] initWithString:baseText];
    NSRange boldedRange = NSMakeRange(0, appDisplayName.length);
    UIFont *boldFont = [UIFont preferredFontForTextStyle:UIFontTextStyleHeadline];

    // Add attributes
    [attributedString beginEditing];
    [attributedString addAttribute:NSFontAttributeName value:boldFont range:boldedRange];
    [attributedString endEditing];

    self.infoLabel.attributedText = [attributedString copy];
    [self.infoLabel sizeToFit];
}

@end