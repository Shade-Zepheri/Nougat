#import "NUANotificationTableViewCell.h"
#import <MobileCoreServices/LSApplicationProxy.h>
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

- (void)dealloc {
    // Reuse date label
    [self _recycleDateLabel];
}

#pragma mark - View Management

- (void)layoutSubviews {
    [super layoutSubviews];

    // Create views
    [self _configureAttachmentImageViewIfNecessary];
    [self _configureTitleLabelIfNecessary];
    [self _configureDateLabelIfNecessary];
    [self _configureMessageLabelIfNecessary];
    [self _configureOptionsBarIfNecessary];

    // Configure content
    [self _configureHeaderText];
}

- (void)_configureAttachmentImageViewIfNecessary {
    if (!self.attachmentImageView) {
        // Create view
        [self _createAttachmentImageView];
    }

    // Configure content
    [self _configureAttachment];
}

- (void)_configureTitleLabelIfNecessary {
    if (!self.titleLabel) {
        // Create view
        [self _createTitleLabel];
    }

    // Configure content
    [self _configureTitleText];
}

- (void)_configureDateLabelIfNecessary {
    if (self.dateLabel || !self.timestamp) {
        // View already exists, or no notification
        return;
    }

    [self _createDateLabel];
}

- (void)_configureMessageLabelIfNecessary {
    if (!self.messageLabel) {
        // Create view
        [self _createMessageLabel];
    }

    // Configure content
    [self _configureMessageText];
}

- (void)_configureOptionsBarIfNecessary {
    if (!self.optionsBar) {
        // Create view
        [self _createOptionsBar];
    }

    // Configure content
    [self _configureButtons];
}

#pragma mark - View Creation

- (void)_createAttachmentImageView {
    self.attachmentImageView = [[UIImageView alloc] initWithFrame:CGRectZero];
    self.attachmentImageView.translatesAutoresizingMaskIntoConstraints = NO;
    [self.contentView addSubview:self.attachmentImageView];

    // Constraints
    [self.attachmentImageView.topAnchor constraintEqualToAnchor:self.headerLabel.bottomAnchor constant:6.0].active = YES;
    [self.attachmentImageView.trailingAnchor constraintEqualToAnchor:self.contentView.layoutMarginsGuide.trailingAnchor].active = YES;
    [self.attachmentImageView.heightAnchor constraintEqualToConstant:40.0].active = YES;
    self.attachmentConstraint = [self.attachmentImageView.widthAnchor constraintEqualToConstant:0.0];
    self.attachmentConstraint.active = YES;
}

- (void)_createTitleLabel {
    self.titleLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    self.titleLabel.font = [UIFont preferredFontForTextStyle:UIFontTextStyleSubheadline];
    self.titleLabel.lineBreakMode = NSLineBreakByTruncatingTail;
    self.titleLabel.translatesAutoresizingMaskIntoConstraints = NO;

    // Here we actually wanna use iOS 13's label color since the background will automatically change regardless of settings
    if (@available(iOS 13, *)) {
        // To silence warnings
        self.titleLabel.textColor = UIColor.labelColor;
    } else {
        self.titleLabel.textColor = UIColor.blackColor;
    }
    [self.contentView addSubview:self.titleLabel];

    // Constraints
    [self.titleLabel.topAnchor constraintEqualToAnchor:self.headerLabel.bottomAnchor constant:6.0].active = YES;
    [self.titleLabel.leadingAnchor constraintEqualToAnchor:self.glyphView.leadingAnchor].active = YES;
    [self.titleLabel.heightAnchor constraintEqualToConstant:20.0].active = YES;
    [self.titleLabel.trailingAnchor constraintEqualToAnchor:self.attachmentImageView.leadingAnchor constant:-10.0].active = YES;
}

- (void)_createDateLabel {
    // Create date label
    _dateLabel = [NUADateLabelRepository.sharedRepository startLabelWithStartDate:self.timestamp timeZone:self.notification.timeZone];
    self.dateLabel.delegate = self;
    self.dateLabel.font = [UIFont preferredFontForTextStyle:UIFontTextStyleSubheadline];
    self.dateLabel.numberOfLines = 1;
    self.dateLabel.textColor = UIColor.grayColor;
    self.dateLabel.translatesAutoresizingMaskIntoConstraints = NO;
    [self.contentView addSubview:self.dateLabel];

    // Contraints
    [self.dateLabel.leadingAnchor constraintEqualToAnchor:self.headerLabel.trailingAnchor constant:3.0].active = YES;
    [self.dateLabel.topAnchor constraintEqualToAnchor:self.glyphView.topAnchor].active = YES;
    [self.dateLabel.bottomAnchor constraintEqualToAnchor:self.headerLabel.bottomAnchor].active = YES;

    // Change expand label constraints
    [self.expandButton.leadingAnchor constraintEqualToAnchor:self.dateLabel.trailingAnchor].active = YES;
}

- (void)_createMessageLabel {
    self.messageLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    self.messageLabel.font = [UIFont preferredFontForTextStyle:UIFontTextStyleSubheadline];
    self.messageLabel.lineBreakMode = NSLineBreakByTruncatingTail;
    self.messageLabel.textColor = UIColor.grayColor;
    self.messageLabel.translatesAutoresizingMaskIntoConstraints = NO;
    [self.contentView addSubview:self.messageLabel];

    // Constraints
    [self.messageLabel.topAnchor constraintEqualToAnchor:self.titleLabel.bottomAnchor constant:5.0].active = YES;
    [self.messageLabel.heightAnchor constraintEqualToConstant:18.0].active = YES;
    [self.messageLabel.leadingAnchor constraintEqualToAnchor:self.glyphView.leadingAnchor].active = YES;
    [self.messageLabel.trailingAnchor constraintEqualToAnchor:self.attachmentImageView.leadingAnchor constant:-10.0].active = YES;
}

- (void)_createOptionsBar {
    self.optionsBar = [[UIView alloc] initWithFrame:CGRectZero];
    self.optionsBar.backgroundColor = self.notificationShadePreferences.backgroundColor;
    self.optionsBar.translatesAutoresizingMaskIntoConstraints = NO;
    [self.contentView addSubview:self.optionsBar];

    // Constraints
    [self.optionsBar.leadingAnchor constraintEqualToAnchor:self.contentView.leadingAnchor].active = YES;
    [self.optionsBar.trailingAnchor constraintEqualToAnchor:self.contentView.trailingAnchor].active = YES;
    [self.optionsBar.topAnchor constraintEqualToAnchor:self.contentView.topAnchor constant:100.0].active = YES;
    self.optionsHeightConstraint = [self.optionsBar.heightAnchor constraintEqualToConstant:self.expanded ? 50.0 : 0.0];
    self.optionsHeightConstraint.active = YES;

    // Create buttons
    self.openButton = [UIButton buttonWithType:UIButtonTypeSystem];
    [self.openButton addTarget:self action:@selector(didTapOpenButton:) forControlEvents:UIControlEventTouchUpInside];
    [self.openButton setTitle:@"Open" forState:UIControlStateNormal];
    self.openButton.hidden = !self.expanded;
    self.openButton.titleLabel.font = [UIFont preferredFontForTextStyle:UIFontTextStyleHeadline];
    self.openButton.translatesAutoresizingMaskIntoConstraints = NO;
    [self.openButton sizeToFit];
    [self.optionsBar addSubview:self.openButton];

    self.clearButton = [UIButton buttonWithType:UIButtonTypeSystem];
    [self.clearButton addTarget:self action:@selector(didTapClearButton:) forControlEvents:UIControlEventTouchUpInside];
    [self.clearButton setTitle:@"Clear" forState:UIControlStateNormal];
    self.clearButton.hidden = !self.expanded;
    self.clearButton.titleLabel.font = [UIFont preferredFontForTextStyle:UIFontTextStyleHeadline];
    self.clearButton.translatesAutoresizingMaskIntoConstraints = NO;
    [self.clearButton sizeToFit];
    [self.optionsBar addSubview:self.clearButton];

    // Constraints
    [self.openButton.leadingAnchor constraintEqualToAnchor:self.glyphView.leadingAnchor].active = YES;
    [self.openButton.topAnchor constraintEqualToAnchor:self.optionsBar.topAnchor].active = YES;
    [self.openButton.bottomAnchor constraintEqualToAnchor:self.optionsBar.bottomAnchor].active = YES;

    [self.clearButton.leadingAnchor constraintEqualToAnchor:self.openButton.trailingAnchor constant:30.0].active = YES;
    [self.clearButton.topAnchor constraintEqualToAnchor:self.optionsBar.topAnchor].active = YES;
    [self.clearButton.bottomAnchor constraintEqualToAnchor:self.optionsBar.bottomAnchor].active = YES;
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

    // Force layout
    [self setNeedsLayout];
}

- (void)setNotification:(NUACoalescedNotification *)notification {
    if ([notification isEqual:_notification]) {
        // Same notification
        return;
    }

    // Configure stuffs
    _notification = notification;
    _timestamp = notification.timestamp;
    self.glyphView.image = notification.icon;

    // Get our color info
    [self generateColorInfo];

    // Create views if needed
    [self _tearDownDateLabel];
    [self setNeedsLayout];
}

#pragma mark - Date Label

- (void)dateLabelDidChange:(NUARelativeDateLabel *)dateLabel {
    // Resize and reload
    [self.dateLabel sizeToFit];
    [self setNeedsLayout];
}

- (void)_tearDownDateLabel {
    [UIView performWithoutAnimation:^{
        if (!self.dateLabel) {
            // No label
            return;
        }

        // Recycle
        [self.dateLabel removeFromSuperview];
        [self _recycleDateLabel];
        _dateLabel = nil;
    }];
}

- (void)_recycleDateLabel {
    // Recycle
    self.dateLabel.delegate = nil;
    [NUADateLabelRepository.sharedRepository recycleLabel:self.dateLabel];
}

#pragma mark - Color Info

- (void)generateColorInfo {
    // Check if info is cached or not
    NUAImageColorCache *colorCache = NUAImageColorCache.sharedCache;
    UIImage *iconImage = self.notification.icon;
    if ([colorCache hasColorDataForImage:iconImage type:NUAImageColorInfoTypeAppIcon]) {
        // Has data
        _colorInfo = [colorCache cachedColorInfoForImage:iconImage type:NUAImageColorInfoTypeAppIcon];
    } else {
        // Generate
        [colorCache cacheColorInfoForImage:iconImage type:NUAImageColorInfoTypeAppIcon completion:^(NUAImageColorInfo *colorInfo) {
            _colorInfo = colorInfo;

            // Refresh
            [self setNeedsLayout];
        }];
    }
}

#pragma mark - Content Management

- (void)_configureAttachment {
    if (!self.notification) {
        // No notification to configure from
        return;
    }

    self.attachmentImageView.image = self.notification.attachmentImage;

    // Update constraints
    CGFloat constant = (self.attachmentImageView.image) ? 40.0 : 0.0;
    self.attachmentConstraint.constant = constant;
}

- (void)_configureHeaderText {
    if (!self.notification || !self.colorInfo) {
        // No notification to configure from
        return;
    }

    NSString *displayName;
    if ([self.notification.sectionID isEqualToString:@"Screen Recording"] || [self.notification.sectionID isEqualToString:@"com.apple.ReplayKitNotifications"]) {
        // Exception for screen recording, since it doesnt use a conventional bundle id
        // Get translation from CC bundle
        NSBundle *screenRecordingBundle = [NSBundle bundleWithPath:@"/System/Library/ControlCenter/Bundles/ReplayKitModule.bundle"];
        displayName = [screenRecordingBundle localizedStringForKey:@"CFBundleDisplayName" value:@"Screen Recording" table:@"InfoPlist"];
    } else {
        // Too lazy/complicated to link against (Mobile)CoreServices
        LSApplicationProxy *applicationProxy = [NSClassFromString(@"LSApplicationProxy") applicationProxyForIdentifier:self.notification.sectionID];
        displayName = applicationProxy.localizedName;
    }

    // Attribute up
    NSString *baseHeaderText = [NSString stringWithFormat:@"%@ •", displayName];
    NSMutableAttributedString *mutableAttributedString = [[NSMutableAttributedString alloc] initWithString:baseHeaderText];
    NSDictionary<NSAttributedStringKey, id> *attributes = @{NSForegroundColorAttributeName: self.colorInfo.primaryColor};
    [mutableAttributedString setAttributes:attributes range:NSMakeRange(0, displayName.length)];

    self.headerLabel.attributedText = [mutableAttributedString copy];
}

- (void)_configureTitleText {
    if (!self.notification) {
        // No notification to configure from
        return;
    }

    // Get info from first entry
    NSString *title = (self.notification.title) ? self.notification.title : self.notification.message;
    self.titleLabel.text = title;
}

- (void)_configureMessageText {
    if (!self.notification) {
        // No notification to configure from
        return;
    }

    // Get info from first entry
    NSBundle *bundle = [NSBundle bundleForClass:self.class];
    NSString *fallbackMessage = [bundle localizedStringForKey:@"TAP_FOR_MORE_OPTIONS" value:@"Tap for more options." table:@"Localizable"];
    NSString *message = (self.notification.title) ? self.notification.message : fallbackMessage;
    self.messageLabel.text = message;
}

- (void)_configureButtons {
    if (!self.colorInfo) {
        // No color info
        return;
    }

    // Get image
    NSBundle *bundle = [NSBundle bundleForClass:self.class];
    UIImage *baseImage = [UIImage imageNamed:@"arrow-dark" inBundle:bundle];

    // Tint and set
    UIImage *tintedImage = [baseImage _flatImageWithColor:self.colorInfo.primaryColor];
    [self.expandButton setImage:tintedImage forState:UIControlStateNormal];

    // Text buttons
    [self.openButton setTitleColor:self.colorInfo.primaryColor forState:UIControlStateNormal];
    [self.clearButton setTitleColor:self.colorInfo.primaryColor forState:UIControlStateNormal];

    // Show/hide
    self.openButton.hidden = !self.expanded;
    self.clearButton.hidden = !self.expanded;

    // Update options menu
    self.optionsHeightConstraint.constant = self.expanded ? 50.0 : 0.0;
}

@end