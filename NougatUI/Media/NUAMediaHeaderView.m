#import "NUAMediaHeaderView.h"
#import <MediaRemote/MediaRemote.h>
#import <SpringBoardServices/SpringBoardServices+Private.h>
#import <UIKit/UIImage+Private.h>

@interface NUAMediaHeaderView ()
@property (strong, nonatomic) UIImageView *appImage;
@property (strong, nonatomic) UILabel *infoLabel;
@property (strong, nonatomic) UILabel *songLabel;
@property (strong, nonatomic) UILabel *artistLabel;

@end

@implementation NUAMediaHeaderView

#pragma mark - Init

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        // Create top label
        self.appImage = [[UIImageView alloc] initWithFrame:CGRectZero];
        self.appImage.translatesAutoresizingMaskIntoConstraints = NO;
        [self addSubview:self.appImage];

        self.infoLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        self.infoLabel.font = [UIFont preferredFontForTextStyle:UIFontTextStyleSubheadline];
        self.infoLabel.textColor = [UIColor whiteColor];
        self.infoLabel.translatesAutoresizingMaskIntoConstraints = NO;
        [self addSubview:self.infoLabel];

        // Constraints (Massive mess but keeps things clean)
        [self.appImage.topAnchor constraintEqualToAnchor:self.topAnchor].active = YES;
        [self.appImage.leadingAnchor constraintEqualToAnchor:self.leadingAnchor].active = YES;
        [self.appImage.heightAnchor constraintEqualToConstant:18.0].active = YES;
        [self.appImage.widthAnchor constraintEqualToConstant:18.0].active = YES;

        [self.infoLabel.topAnchor constraintEqualToAnchor:self.topAnchor].active = YES;
        [self.infoLabel.leadingAnchor constraintEqualToAnchor:self.appImage.trailingAnchor constant:5.0].active = YES;
        [self.infoLabel.heightAnchor constraintEqualToConstant:18.0].active = YES;
        [self.infoLabel.trailingAnchor constraintEqualToAnchor:self.trailingAnchor].active = YES;

        self.songLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        self.songLabel.adjustsFontSizeToFitWidth = NO;
        self.songLabel.font = [UIFont preferredFontForTextStyle:UIFontTextStyleHeadline];
        self.songLabel.lineBreakMode = NSLineBreakByTruncatingTail;
        self.songLabel.textColor = [UIColor whiteColor];
        self.songLabel.translatesAutoresizingMaskIntoConstraints = NO;
        [self addSubview:self.songLabel];

        [self.songLabel.topAnchor constraintEqualToAnchor:self.infoLabel.bottomAnchor constant:5.0].active = YES;
        [self.songLabel.leadingAnchor constraintEqualToAnchor:self.leadingAnchor].active = YES;
        [self.songLabel.heightAnchor constraintEqualToConstant:18.0].active = YES;
        [self.songLabel.trailingAnchor constraintEqualToAnchor:self.trailingAnchor].active = YES;

        self.artistLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        self.artistLabel.font = [UIFont preferredFontForTextStyle:UIFontTextStyleSubheadline];
        self.artistLabel.textColor = [UIColor whiteColor];
        self.artistLabel.translatesAutoresizingMaskIntoConstraints = NO;
        [self addSubview:self.artistLabel];

        [self.artistLabel.topAnchor constraintEqualToAnchor:self.songLabel.bottomAnchor constant:5.0].active = YES;
        [self.artistLabel.leadingAnchor constraintEqualToAnchor:self.leadingAnchor].active = YES;
        [self.artistLabel.heightAnchor constraintEqualToConstant:18.0].active = YES;
        [self.artistLabel.trailingAnchor constraintEqualToAnchor:self.trailingAnchor].active = YES;

        // Set view height
        [self.bottomAnchor constraintEqualToAnchor:self.artistLabel.bottomAnchor constant:5.0].active = YES;
    }

    return self;
}

#pragma mark - Properties

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