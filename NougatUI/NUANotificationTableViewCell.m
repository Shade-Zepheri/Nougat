#import "NUANotificationTableViewCell.h"
#import "NSDate+Elapsed.h"
#import "UIImage+Average.h"
#import <NougatServices/NUAPreferenceManager.h>
#import <SpringBoardServices/SpringBoardServices+Private.h>
#import <UIKit/UIImage+Private.h>
#import <Macros.h>

@interface NUANotificationTableViewCell ()
@property (strong, nonatomic) UIImageView *attachmentImageView;
@property (strong, nonatomic) UILabel *titleLabel;
@property (strong, nonatomic) UILabel *messageLabel;
@property (strong, nonatomic) UIView *optionsBar;
@property (strong, nonatomic) UIButton *openButton;
@property (strong, nonatomic) UIButton *clearButton;

@property (strong, nonatomic) NSLayoutConstraint *attachmentConstraint;
@property (strong, nonatomic) NSLayoutConstraint *optionsHeightConstraint;

@end

@implementation NUANotificationTableViewCell

#pragma mark - Init

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Create the things
        [self createViews];
        [self setupConstraints];
    }

    return self;
}

- (void)createViews {
    [self _createAttachmentImageViewIfNecessary];
    [self _createTitleLabelIfNecessary];
    [self _createMessageLabelIfNecessary];
    [self _createOptionsBar];
}

- (void)setupConstraints {
    [self.attachmentImageView.topAnchor constraintEqualToAnchor:self.headerLabel.bottomAnchor constant:6.0].active = YES;
    [self.attachmentImageView.trailingAnchor constraintEqualToAnchor:self.contentView.layoutMarginsGuide.trailingAnchor].active = YES;
    [self.attachmentImageView.heightAnchor constraintEqualToConstant:40.0].active = YES;
    self.attachmentConstraint = [self.attachmentImageView.widthAnchor constraintEqualToConstant:0.0];
    self.attachmentConstraint.active = YES;

    [self.titleLabel.topAnchor constraintEqualToAnchor:self.headerLabel.bottomAnchor constant:6.0].active = YES;
    [self.titleLabel.leadingAnchor constraintEqualToAnchor:self.glyphView.leadingAnchor].active = YES;
    [self.titleLabel.heightAnchor constraintEqualToConstant:20.0].active = YES;
    [self.titleLabel.trailingAnchor constraintEqualToAnchor:self.attachmentImageView.leadingAnchor constant:-10.0].active = YES;

    [self.messageLabel.topAnchor constraintEqualToAnchor:self.titleLabel.bottomAnchor constant:5.0].active = YES;
    [self.messageLabel.heightAnchor constraintEqualToConstant:18.0].active = YES;
    [self.messageLabel.leadingAnchor constraintEqualToAnchor:self.glyphView.leadingAnchor].active = YES;
    [self.messageLabel.trailingAnchor constraintEqualToAnchor:self.attachmentImageView.leadingAnchor constant:-10.0].active = YES;

    [self.optionsBar.leadingAnchor constraintEqualToAnchor:self.contentView.leadingAnchor].active = YES;
    [self.optionsBar.trailingAnchor constraintEqualToAnchor:self.contentView.trailingAnchor].active = YES;
    [self.optionsBar.topAnchor constraintEqualToAnchor:self.contentView.topAnchor constant:100.0].active = YES;
    self.optionsHeightConstraint = [self.optionsBar.heightAnchor constraintEqualToConstant:0.0];
    self.optionsHeightConstraint.active = YES;

    // Options buttons
    [self.openButton.leadingAnchor constraintEqualToAnchor:self.glyphView.leadingAnchor].active = YES;
    [self.openButton.topAnchor constraintEqualToAnchor:self.optionsBar.topAnchor].active = YES;
    [self.openButton.bottomAnchor constraintEqualToAnchor:self.optionsBar.bottomAnchor].active = YES;

    [self.clearButton.leadingAnchor constraintEqualToAnchor:self.openButton.trailingAnchor constant:30.0].active = YES;
    [self.clearButton.topAnchor constraintEqualToAnchor:self.optionsBar.topAnchor].active = YES;
    [self.clearButton.bottomAnchor constraintEqualToAnchor:self.optionsBar.bottomAnchor].active = YES;
}

#pragma mark - Label views

- (void)_createAttachmentImageViewIfNecessary {
    self.attachmentImageView = [[UIImageView alloc] initWithFrame:CGRectZero];
    self.attachmentImageView.translatesAutoresizingMaskIntoConstraints = NO;
    [self.contentView addSubview:self.attachmentImageView];
}

- (void)_createTitleLabelIfNecessary {
    self.titleLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    self.titleLabel.font = [UIFont preferredFontForTextStyle:UIFontTextStyleSubheadline];
    self.titleLabel.lineBreakMode = NSLineBreakByTruncatingTail;
    self.titleLabel.translatesAutoresizingMaskIntoConstraints = NO;

    // Here we actually wanna use iOS 13's label color since the background will automatically change regardless of settings
    if (@available(iOS 13, *)) {
        // To silence warnings
        self.titleLabel.textColor = UIColor.labelColor;
    } else {
        self.titleLabel.textColor = [NUAPreferenceManager sharedSettings].textColor;
    }
    [self.contentView addSubview:self.titleLabel];
}

- (void)_createMessageLabelIfNecessary {
    self.messageLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    self.messageLabel.font = [UIFont preferredFontForTextStyle:UIFontTextStyleSubheadline];
    self.messageLabel.lineBreakMode = NSLineBreakByTruncatingTail;
    self.messageLabel.textColor = [UIColor grayColor];
    self.messageLabel.translatesAutoresizingMaskIntoConstraints = NO;
    [self.contentView addSubview:self.messageLabel];
}

- (void)_createOptionsBar {
    self.optionsBar = [[UIView alloc] initWithFrame:CGRectZero];
    self.optionsBar.backgroundColor = OreoBackgroundColor;
    self.optionsBar.translatesAutoresizingMaskIntoConstraints = NO;
    [self.contentView addSubview:self.optionsBar];

    // Create buttons
    self.openButton = [UIButton buttonWithType:UIButtonTypeSystem];
    [self.openButton addTarget:self action:@selector(didTapOpenButton:) forControlEvents:UIControlEventTouchUpInside];
    [self.openButton setTitle:@"Open" forState:UIControlStateNormal];
    self.openButton.hidden = YES;
    self.openButton.titleLabel.font = [UIFont preferredFontForTextStyle:UIFontTextStyleHeadline];
    self.openButton.translatesAutoresizingMaskIntoConstraints = NO;
    [self.openButton sizeToFit];
    [self.optionsBar addSubview:self.openButton];

    self.clearButton = [UIButton buttonWithType:UIButtonTypeSystem];
    [self.clearButton addTarget:self action:@selector(didTapClearButton:) forControlEvents:UIControlEventTouchUpInside];
    [self.clearButton setTitle:@"Clear" forState:UIControlStateNormal];
    self.clearButton.hidden = YES;
    self.clearButton.titleLabel.font = [UIFont preferredFontForTextStyle:UIFontTextStyleHeadline];
    self.clearButton.translatesAutoresizingMaskIntoConstraints = NO;
    [self.clearButton sizeToFit];
    [self.optionsBar addSubview:self.clearButton];
}

#pragma mark - Buttons

- (void)didTapOpenButton:(UIButton *)sender {
    // Just send to delegate
    [self.actionsDelegate notificationTableViewCellRequestsExecuteDefaultAction:self];
}

- (void)didTapClearButton:(UIButton *)sender {
    // Just send to delegate
    [self.actionsDelegate notificationTableViewCellRequestsExecuteAlternateAction:self];
}

#pragma mark - Properties

- (void)setExpanded:(BOOL)expanded {
    [super setExpanded:expanded];

    // Show buttons
    self.openButton.hidden = !expanded;
    self.clearButton.hidden = !expanded;

    // Update options menu
    self.optionsHeightConstraint.constant = expanded ? 50.0 : 0.0;
}

- (void)setNotification:(NUACoalescedNotification *)notification {
    _notification = notification;

    // Configure stuffs
    _timestamp = notification.timestamp;
    self.glyphView.image = notification.icon;

    [self _configureAttachment];
    [self _configureHeaderText];
    [self _configureTitleText];
    [self _configureMessageText];
    [self _configureButtons];
}

#pragma mark - Appearance Updates

- (void)traitCollectionDidChange:(UITraitCollection *)previousTraitCollection {
    [super traitCollectionDidChange:previousTraitCollection];

    // Check if appearance changed
    if (@available(iOS 13, *)) {
        if (![self.traitCollection hasDifferentColorAppearanceComparedToTraitCollection:previousTraitCollection]) {
            return;
        }

        self.titleLabel.textColor = [NUAPreferenceManager sharedSettings].textColor;
    }
}

#pragma mark - Label management

- (void)_configureAttachment {
    self.attachmentImageView.image = self.notification.attachmentImage;

    // Update constraints
    CGFloat constant = (self.attachmentImageView.image) ? 40.0 : 0.0;
    self.attachmentConstraint.constant = constant;
}

- (void)_configureHeaderText {
    NSString *displayName;
    if ([self.notification.sectionID isEqualToString:@"Screen Recording"] || [self.notification.sectionID isEqualToString:@"com.apple.ReplayKitNotifications"]) {
        // Exception for screen recording, since it doesnt use a conventional bundle id
        displayName = @"Screen Recording";
    } else {
        displayName = SBSCopyLocalizedApplicationNameForDisplayIdentifier(self.notification.sectionID);
    }

    // Attribute up
    NSString *elapsedTime = [self.notification.timestamp getElapsedTime];
    NSString *baseHeaderText = [NSString stringWithFormat:@"%@ • %@", displayName, elapsedTime];

    NSMutableAttributedString *mutableAttributedString = [[NSMutableAttributedString alloc] initWithString:baseHeaderText];

    UIColor *textColor = self.notification.icon.averageColor;
    _tintColor = textColor;

    NSDictionary<NSAttributedStringKey, id> *attributes = @{NSForegroundColorAttributeName: textColor};
    [mutableAttributedString setAttributes:attributes range:NSMakeRange(0, displayName.length)];

    self.headerLabel.attributedText = [mutableAttributedString copy];
}

- (void)_configureTitleText {
    // Get info from first entry
    NSString *title = (self.notification.title) ? self.notification.title : self.notification.message;
    self.titleLabel.text = title;
}

- (void)_configureMessageText {
    // Get info from first entry
    NSString *message = (self.notification.title) ? self.notification.message : @"Tap for more options.";
    self.messageLabel.text = message;
}

- (void)_configureButtons {
    // Get image
    NSBundle *bundle = [NSBundle bundleForClass:[self class]];
    UIImage *baseImage = [UIImage imageNamed:@"arrow-dark" inBundle:bundle];

    // Tint and set
    UIImage *tintedImage = [baseImage _flatImageWithColor:_tintColor];
    [self.expandButton setImage:tintedImage forState:UIControlStateNormal];

    // Text buttons
    [self.openButton setTitleColor:_tintColor forState:UIControlStateNormal];
    [self.clearButton setTitleColor:_tintColor forState:UIControlStateNormal];
}

@end