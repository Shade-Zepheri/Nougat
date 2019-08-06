#import "NUANotificationTableViewCell.h"
#import "NSDate+Elapsed.h"
#import "UIImage+Average.h"
#import <SpringBoardServices/SpringBoardServices+Private.h>
#import <UIKit/UIImage+Private.h>
#import <Macros.h>

@interface NUANotificationTableViewCell ()
@property (strong, nonatomic) UIImageView *attachmentImageView;
@property (strong, nonatomic) UILabel *titleLabel;
@property (strong, nonatomic) UILabel *messageLabel;
@property (strong, nonatomic) UIView *optionsBar;

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
    [self.attachmentImageView.trailingAnchor constraintEqualToAnchor:self.contentView.layoutMarginsGuide.trailingAnchor constant:-10.0].active = YES;
    [self.attachmentImageView.heightAnchor constraintEqualToConstant:35.0].active = YES;
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
}

#pragma mark - Label views

- (void)_createAttachmentImageViewIfNecessary {
    self.attachmentImageView = [[UIImageView alloc] initWithFrame:CGRectZero];
    self.attachmentImageView.translatesAutoresizingMaskIntoConstraints = NO;
    [self.contentView addSubview:self.attachmentImageView];
}

- (void)_createTitleLabelIfNecessary {
    self.titleLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    self.titleLabel.font = [UIFont preferredFontForTextStyle:UIFontTextStyleBody];
    self.titleLabel.lineBreakMode = NSLineBreakByTruncatingTail;
    self.titleLabel.textColor = [UIColor blackColor];
    self.titleLabel.translatesAutoresizingMaskIntoConstraints = NO;
    [self.contentView addSubview:self.titleLabel];
}

- (void)_createMessageLabelIfNecessary {
    self.messageLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    self.messageLabel.font = [UIFont preferredFontForTextStyle:UIFontTextStyleBody];
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
}

#pragma mark - Properties

- (void)setExpanded:(BOOL)expanded {
    [super setExpanded:expanded];

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
    [self _configureExpandButton];
}

#pragma mark - Label management

- (void)_configureAttachment {
    self.attachmentImageView.image = self.notification.attachmentImage;

    // Update constraints
    CGFloat constant = (self.attachmentImageView.image) ? 35.0 : 0.0;
    self.attachmentConstraint.constant = constant;
}

- (void)_configureHeaderText {
    // Attribute up
    NSString *displayName = SBSCopyLocalizedApplicationNameForDisplayIdentifier(self.notification.sectionID);
    NSString *elapsedTime = [self.notification.timestamp getElapsedTime];
    NSString *baseHeaderText = [NSString stringWithFormat:@"%@ • %@", displayName, elapsedTime];

    NSMutableAttributedString *mutableAttributedString = [[NSMutableAttributedString alloc] initWithString:baseHeaderText];

    UIColor *textColor = self.notification.icon.averageColor;
    NSDictionary<NSAttributedStringKey, id> *attributes = @{NSForegroundColorAttributeName: textColor};
    [mutableAttributedString setAttributes:attributes range:NSMakeRange(0, displayName.length)];
    _tintColor = textColor;

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

- (void)_configureExpandButton {
    // Get image
    NSBundle *bundle = [NSBundle bundleForClass:[self class]];
    UIImage *baseImage = [UIImage imageNamed:@"arrow-dark" inBundle:bundle];

    // Tint and set
    UIImage *tintedImage = [baseImage _flatImageWithColor:_tintColor];
    [self.expandButton setImage:tintedImage forState:UIControlStateNormal];
}

@end