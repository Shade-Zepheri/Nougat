#import "NUANotificationTableViewCell.h"
#import "NSDate+Elapsed.h"
#import "UIImage+Average.h"
#import <SpringBoardServices/SpringBoardServices+Private.h>
#import <HBLog.h>

@interface NUANotificationTableViewCell ()
@property (strong, nonatomic) UIImageView *glyphView;
@property (strong, nonatomic) UIImageView *attachmentImageView;
@property (strong, nonatomic) UILabel *headerLabel;
@property (strong, nonatomic) UILabel *titleLabel;
@property (strong, nonatomic) UILabel *messageLabel;
@property (strong, nonatomic) UIButton *expandButton;

@end

@implementation NUANotificationTableViewCell

#pragma mark - Init

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Create the things
        [self _createGlyphViewIfNecessary];
        [self _createHeaderLabelIfNecessary];
        [self _createAttachmentImageViewIfNecessary];
        [self _createTitleLabelIfNecessary];
        [self _createMessageLabelIfNecessary];
        [self _createExpandButtonIfNecessary];
    }

    return self;
}

#pragma mark - Label views

- (void)_createGlyphViewIfNecessary {
    self.glyphView = [[UIImageView alloc] initWithFrame:CGRectZero];
    self.glyphView.translatesAutoresizingMaskIntoConstraints = NO;
    [self addSubview:self.glyphView];

    [self.glyphView.topAnchor constraintEqualToAnchor:self.topAnchor constant:12.0].active = YES;
    [self.glyphView.leadingAnchor constraintEqualToAnchor:self.leadingAnchor constant:12.0].active = YES;
    [self.glyphView.heightAnchor constraintEqualToConstant:18.0].active = YES;
    [self.glyphView.widthAnchor constraintEqualToConstant:18.0].active = YES;
}

- (void)_createHeaderLabelIfNecessary {
    self.headerLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    self.headerLabel.font = [UIFont preferredFontForTextStyle:UIFontTextStyleSubheadline];
    self.headerLabel.textColor = [UIColor grayColor];
    self.headerLabel.translatesAutoresizingMaskIntoConstraints = NO;
    [self addSubview:self.headerLabel];

    [self.headerLabel.topAnchor constraintEqualToAnchor:self.glyphView.topAnchor].active = YES;
    [self.headerLabel.leadingAnchor constraintEqualToAnchor:self.glyphView.trailingAnchor constant:5.0].active = YES;
    [self.headerLabel.heightAnchor constraintEqualToConstant:18.0].active = YES;
}

- (void)_createAttachmentImageViewIfNecessary {
    self.attachmentImageView = [[UIImageView alloc] initWithFrame:CGRectZero];
    self.attachmentImageView.translatesAutoresizingMaskIntoConstraints = NO;
    [self addSubview:self.attachmentImageView];

    [self.attachmentImageView.topAnchor constraintEqualToAnchor:self.headerLabel.bottomAnchor constant:7.0].active = YES;
    [self.attachmentImageView.trailingAnchor constraintEqualToAnchor:self.trailingAnchor constant:-10.0].active = YES;
    [self.attachmentImageView.heightAnchor constraintEqualToConstant:35.0].active = YES;
}

- (void)_createTitleLabelIfNecessary {
    self.titleLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    self.titleLabel.font = [UIFont preferredFontForTextStyle:UIFontTextStyleHeadline];
    self.messageLabel.numberOfLines = 0;
    self.messageLabel.lineBreakMode = NSLineBreakByTruncatingTail;
    self.titleLabel.textColor = [UIColor blackColor];
    self.titleLabel.translatesAutoresizingMaskIntoConstraints = NO;
    [self addSubview:self.titleLabel];

    [self.titleLabel.topAnchor constraintEqualToAnchor:self.headerLabel.bottomAnchor constant:7.0].active = YES;
    [self.titleLabel.leadingAnchor constraintEqualToAnchor:self.glyphView.leadingAnchor].active = YES;
    [self.titleLabel.heightAnchor constraintEqualToConstant:18.0].active = YES;
    [self.titleLabel.trailingAnchor constraintEqualToAnchor:self.attachmentImageView.leadingAnchor constant:-10.0].active = YES;
}

- (void)_createMessageLabelIfNecessary {
    self.messageLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    self.messageLabel.font = [UIFont preferredFontForTextStyle:UIFontTextStyleSubheadline];
    self.messageLabel.numberOfLines = 0;
    self.messageLabel.lineBreakMode = NSLineBreakByTruncatingTail;
    self.messageLabel.textColor = [UIColor grayColor];
    self.messageLabel.translatesAutoresizingMaskIntoConstraints = NO;
    [self addSubview:self.messageLabel];

    [self.messageLabel.topAnchor constraintEqualToAnchor:self.titleLabel.bottomAnchor constant:5.0].active = YES;
    [self.messageLabel.heightAnchor constraintEqualToConstant:18.0].active = YES;
    [self.messageLabel.leadingAnchor constraintEqualToAnchor:self.glyphView.leadingAnchor].active = YES;
    [self.messageLabel.trailingAnchor constraintEqualToAnchor:self.attachmentImageView.leadingAnchor constant:-10.0].active = YES;
}

- (void)_createExpandButtonIfNecessary {
    if (self.expandButton) {
        return;
    }
}

#pragma mark - Properties

- (void)setNotification:(NUACoalescedNotification *)notification {
    if (_notification == notification) {
        return;
    }

    _notification = notification;

    // Configure stuffs
    _timestamp = notification.timestamp;
    self.glyphView.image = notification.icon;

    [self _configureAttachment];
    [self _configureHeaderText];
    [self _configureTitleText];
    [self _configureMessageText];
}

#pragma mark - Label management

- (void)_configureAttachment {
    if (!self.notification.attachmentImage) {
        return;
    }

    self.attachmentImageView.image = self.notification.attachmentImage;

    // Update constraints
    CGFloat constant = (self.attachmentImageView.image) ? 35.0 : 0.0;
    [self.attachmentImageView.widthAnchor constraintEqualToConstant:constant].active = YES;
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

@end