#import "NUAAttachmentNotificationTableViewCell.h"
#import <UIKit/UIView+Internal.h>

@interface NUASimpleNotificationTableViewCell ()
@property (strong, nonatomic) UILabel *titleLabel;
@property (strong, nonatomic) UILabel *messageLabel;

@end

@interface NUAAttachmentNotificationTableViewCell ()
@property (strong, nonatomic) UIImageView *attachmentImageView;

@end

@implementation NUAAttachmentNotificationTableViewCell

#pragma mark - View Management

- (void)_createAttachmentView {
    // Create
    self.attachmentImageView = [[UIImageView alloc] initWithFrame:CGRectZero];
    self.attachmentImageView.clipsToBounds = YES;
    self.attachmentImageView._continuousCornerRadius = 3.0;
    self.attachmentImageView.translatesAutoresizingMaskIntoConstraints = NO;
    [self.contentView addSubview:self.attachmentImageView];

    // Constraints
    [self.attachmentImageView.topAnchor constraintEqualToAnchor:self.headerStackView.bottomAnchor].active = YES;
    [self.attachmentImageView.trailingAnchor constraintEqualToAnchor:self.contentView.layoutMarginsGuide.trailingAnchor].active = YES;
    [self.attachmentImageView.heightAnchor constraintEqualToConstant:40.0].active = YES;
    [self.attachmentImageView.widthAnchor constraintEqualToConstant:40.0].active = YES;
}

- (void)_setUpTrailingConstraints {
    if (!self.attachmentImageView) {
        // Create attachment
        [self _createAttachmentView];
    }

    // Have trailing be to attachment
    [self.titleLabel.trailingAnchor constraintEqualToAnchor:self.attachmentImageView.leadingAnchor constant:-10.0].active = YES;
    [self.messageLabel.trailingAnchor constraintEqualToAnchor:self.attachmentImageView.leadingAnchor constant:-10.0].active = YES;
}

#pragma mark - Properties

- (void)setUILocked:(BOOL)UILocked {
    [super setUILocked:UILocked];

    // Hide attachment
    self.attachmentImageView.hidden = UILocked;
}

- (UIImage *)attachmentImage {
    return self.attachmentImageView.image;
}

- (void)setAttachmentImage:(UIImage *)attachmentImage {
    if (self.attachmentImageView.image == attachmentImage) {
        // Same image
        return;
    }

    // Update image
    self.attachmentImageView.image = attachmentImage;
}

- (void)setNotification:(NUACoalescedNotification *)notification {
    [super setNotification:notification];

    // Set attachment
    self.attachmentImage = notification.attachmentImage;
}

@end