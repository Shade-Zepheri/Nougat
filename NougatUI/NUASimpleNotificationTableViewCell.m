#import "NUASimpleNotificationTableViewCell.h"
#import "NUARippleButton.h"
#import <MobileCoreServices/LSApplicationProxy.h>
#import <UIKit/UIImage+Private.h>
#import <Macros.h>

@interface NUASimpleNotificationTableViewCell ()
@property (strong, nonatomic) UILabel *titleLabel;
@property (strong, nonatomic) UILabel *messageLabel;
@property (strong, nonatomic) NUARelativeDateLabel *dateLabel;
@property (strong, nonatomic) UIView *optionsBar;
@property (strong, nonatomic) NSLayoutConstraint *optionsHeightConstraint;
@property (strong, nonatomic) UIStackView *optionsButtonStack;

@end

@implementation NUASimpleNotificationTableViewCell

#pragma mark - Initialization

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Create everything
        [self _createTitleLabel];
        [self _createMessageLabel];
        [self _createOptionsBar];

        // Constraints
        [self setUpConstraints];
    }

    return self;
}

- (void)dealloc {
    // Reuse date label
    [self _recycleDateLabel];
}

#pragma mark - View Creation

- (void)_createTitleLabel {
    // Create
    self.titleLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    self.titleLabel.font = [UIFont preferredFontForTextStyle:UIFontTextStyleSubheadline];
    self.titleLabel.lineBreakMode = NSLineBreakByTruncatingTail;
    self.titleLabel.adjustsFontForContentSizeCategory = YES;
    self.titleLabel.translatesAutoresizingMaskIntoConstraints = NO;

    // Here we actually wanna use iOS 13's label color since the background will automatically change regardless of settings
    if (@available(iOS 13, *)) {
        // To silence warnings
        self.titleLabel.textColor = [UIColor labelColor];
    } else {
        self.titleLabel.textColor = [UIColor blackColor];
    }
    [self.contentView addSubview:self.titleLabel];
}

- (void)_createMessageLabel {
    // Create
    self.messageLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    self.messageLabel.font = [UIFont preferredFontForTextStyle:UIFontTextStyleFootnote];
    self.messageLabel.lineBreakMode = NSLineBreakByTruncatingTail;
    self.messageLabel.numberOfLines = 2;
    self.messageLabel.textColor = [UIColor grayColor];
    self.messageLabel.adjustsFontForContentSizeCategory = YES;
    self.messageLabel.translatesAutoresizingMaskIntoConstraints = NO;
    [self.contentView addSubview:self.messageLabel];
}

- (void)_createOptionsBar {
    // Create bar
    self.optionsBar = [[UIView alloc] initWithFrame:CGRectZero];
    self.optionsBar.translatesAutoresizingMaskIntoConstraints = NO;
    [self.contentView addSubview:self.optionsBar];

    if (@available(iOS 13, *)) {
        // Make options depend on light/dark
        BOOL inDarkMode = self.traitCollection.userInterfaceStyle == UIUserInterfaceStyleDark;
        self.optionsBar.backgroundColor = inDarkMode ? PixelBackgroundColor : OreoBackgroundColor;
    } else {
        // Always light
        self.optionsBar.backgroundColor = OreoBackgroundColor;
    }

    // Create stack
    _optionsButtonStack = [[UIStackView alloc] initWithFrame:CGRectZero];
    self.optionsButtonStack.axis = UILayoutConstraintAxisHorizontal;
    self.optionsButtonStack.alignment = UIStackViewAlignmentLastBaseline;
    self.optionsButtonStack.distribution = UIStackViewDistributionEqualSpacing;
    self.optionsButtonStack.spacing = 15.0;
    self.optionsButtonStack.translatesAutoresizingMaskIntoConstraints = NO;
    [self.contentView addSubview:self.optionsButtonStack];
}

- (void)setUpConstraints {
    // Title label
    [self.titleLabel.leadingAnchor constraintEqualToAnchor:self.contentView.layoutMarginsGuide.leadingAnchor].active = YES;
    [self.titleLabel.firstBaselineAnchor constraintEqualToAnchor:self.headerStackView.bottomAnchor constant:20.0].active = YES;

    // Message label
    [self.messageLabel.leadingAnchor constraintEqualToAnchor:self.titleLabel.leadingAnchor].active = YES;
    [self.messageLabel.firstBaselineAnchor constraintEqualToAnchor:self.titleLabel.lastBaselineAnchor constant:20.0].active = YES;

    [self _setUpTrailingConstraints];

    // Options bar
    [self.optionsBar.leadingAnchor constraintEqualToAnchor:self.contentView.leadingAnchor].active = YES;
    [self.optionsBar.trailingAnchor constraintEqualToAnchor:self.contentView.trailingAnchor].active = YES;
    [self.optionsBar.topAnchor constraintEqualToAnchor:self.messageLabel.lastBaselineAnchor constant:15.0].active = YES;
    self.optionsHeightConstraint = [self.optionsBar.heightAnchor constraintEqualToConstant:0.0];
    self.optionsHeightConstraint.active = YES;

    // Options stack
    [self.optionsButtonStack.leadingAnchor constraintEqualToAnchor:self.messageLabel.leadingAnchor].active = YES;
    [self.optionsButtonStack.topAnchor constraintEqualToAnchor:self.optionsBar.topAnchor].active = YES;
    [self.optionsButtonStack.bottomAnchor constraintEqualToAnchor:self.optionsBar.bottomAnchor].active = YES;

    // Cell height
    [self.contentView.bottomAnchor constraintEqualToAnchor:self.optionsBar.bottomAnchor].active = YES;
}

- (void)_setUpTrailingConstraints {
    // Setup here,so subclasses can override
    [self.titleLabel.trailingAnchor constraintEqualToAnchor:self.contentView.layoutMarginsGuide.trailingAnchor].active = YES;
    [self.messageLabel.trailingAnchor constraintEqualToAnchor:self.contentView.layoutMarginsGuide.trailingAnchor].active = YES;
}

#pragma mark - Properties

- (void)setUILocked:(BOOL)UILocked {
    if (_UILocked == UILocked) {
        // Nothing to change
        return;
    }

    _UILocked = UILocked;

    // Change and hide stuff
    NSBundle *bundle = [NSBundle bundleForClass:self.class];
    NSString *hiddenTitleText = [bundle localizedStringForKey:@"NOTIFICATION" value:@"Notification" table:@"Localizable"];
    NSString *realTitleText = self.notification.title ?: self.notification.message;
    self.titleText = UILocked ? hiddenTitleText : realTitleText;
    self.messageLabel.hidden = UILocked;
}

- (NSString *)titleText {
    return self.titleLabel.text;
}

- (void)setTitleText:(NSString *)titleText {
    if ([self.titleLabel.text isEqualToString:titleText]) {
        // Same string
        return;
    }

    // Update
    self.titleLabel.text = titleText;
}

- (NSString *)messageText {
    return self.messageLabel.text;
}

- (void)setMessageText:(NSString *)messageText {
    if ([self.messageLabel.text isEqualToString:messageText]) {
        // Same string
        return;
    }

    // Update
    self.messageLabel.text = messageText;

    // Determine if expandable
    CGSize boundingSize = CGSizeMake(CGRectGetWidth(self.messageLabel.bounds), CGFLOAT_MAX);
    CGRect requiredLabelBounds = [messageText boundingRectWithSize:boundingSize options:(NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading) attributes:@{NSFontAttributeName: self.messageLabel.font} context:nil];
    self.expandable = floor(CGRectGetHeight(requiredLabelBounds) / self.messageLabel.font.lineHeight) > 2;
}

- (void)setTimestamp:(NSDate *)timestamp {
    if ([_timestamp isEqualToDate:timestamp]) {
        // Same date
        return;
    }

    // Recreate
    _timestamp = timestamp;
    [self _tearDownDateLabel];
    [self _configureDateLabelIfNecessary];
}

- (void)setExpanded:(BOOL)expanded {
    [super setExpanded:expanded];

    // Configure message label
    self.messageLabel.numberOfLines = expanded ? 0 : 2;

    // Configure options bar
    self.optionsHeightConstraint.constant = (expanded && self.hasActions) ? 38.0 : 0.0;
    if (self.hasActions) {
        // Reveal the buttons
        for (UIView *view in self.optionsButtonStack.arrangedSubviews) {
            view.hidden = !expanded;
        }
    }
}

- (void)setNotification:(NUACoalescedNotification *)notification {
    // Configure content
    _notification = notification;
    NSBundle *bundle = [NSBundle bundleForClass:self.class];
    NSString *titleText = notification.title ?: notification.message;
    NSString *hiddenTitleText = [bundle localizedStringForKey:@"NOTIFICATION" value:@"Notification" table:@"Localizable"];
    NSString *fallbackMessage = [bundle localizedStringForKey:@"TAP_FOR_MORE_OPTIONS" value:@"Tap for more options." table:@"Localizable"];
    NSString *messageText = (notification.title) ? notification.message : fallbackMessage;
    self.titleText = self.UILocked ? hiddenTitleText : titleText;
    self.messageText = messageText;
    self.timestamp = notification.timestamp;

    // Add actions if necessary
    [self setupActionsFromNotification:notification];

    // // Update header text
    [self updateHeaderWithSectionID:notification.sectionID];

    // // Get our color info
    [self updateColorInfoFromNotification:notification];
}

#pragma mark - Notification Actions

- (void)setupActionsFromNotification:(NUACoalescedNotification *)notification {
    // Reset old buttons
    if (self.optionsButtonStack.arrangedSubviews.count > 0) {
        // Remove old actions
        for (UIView *view in self.optionsButtonStack.arrangedSubviews) {
            [view removeFromSuperview];
        }
    }

    if (!notification.hasCustomActions) {
        // No actions
        self.hasActions = NO;
        return;
    }

    self.expandable = YES;
    self.hasActions = YES;

    // Add supplemental minimal actions
    for (NCNotificationAction *action in notification.customActions) {
        // Create button
        NUARippleButton *rippleButton = [[NUARippleButton alloc] init];
        [rippleButton addTarget:self action:@selector(cellActionButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
        [rippleButton setTitle:action.title forState:UIControlStateNormal];
        rippleButton.contentEdgeInsets = UIEdgeInsetsMake(5, 0, 5, 0);
        rippleButton.hidden = YES;
        rippleButton.maxRippleRadius = 20.0;
        rippleButton.rippleStyle = NUARippleStyleUnbounded;
        rippleButton.titleLabel.font = [UIFont preferredFontForTextStyle:UIFontTextStyleHeadline];

        // Add to stack
        [self.optionsButtonStack addArrangedSubview:rippleButton];
    }
}

- (void)cellActionButtonPressed:(NUARippleButton *)button {
    // Get actions
    NCNotificationRequest *request = self.notification.leadingNotificationEntry.request;
    NSArray<NCNotificationAction *> *minimalActions = self.notification.customActions;

    // Get index or button
    NSUInteger actionIndex = [self.optionsButtonStack.arrangedSubviews indexOfObject:button];
    NCNotificationAction *action = minimalActions[actionIndex];

    // Call delegate
    [self.actionsDelegate notificationTableViewCell:self requestsExecuteAction:action fromNotificationRequest:request];
}

#pragma mark - Header Text

- (void)updateHeaderWithSectionID:(NSString *)sectionID {
    NSString *displayName;
    if ([sectionID isEqualToString:@"Screen Recording"] || [sectionID isEqualToString:@"com.apple.ReplayKitNotifications"]) {
        // Exception for screen recording, since it doesnt use a conventional bundle id
        // Get translation from CC bundle
        NSBundle *screenRecordingBundle = [NSBundle bundleWithPath:@"/System/Library/ControlCenter/Bundles/ReplayKitModule.bundle"];
        displayName = [screenRecordingBundle localizedStringForKey:@"CFBundleDisplayName" value:@"Screen Recording" table:@"InfoPlist"];
    } else {
        // Too lazy/complicated to link against (Mobile)CoreServices
        LSApplicationProxy *applicationProxy = [NSClassFromString(@"LSApplicationProxy") applicationProxyForIdentifier:sectionID];
        displayName = applicationProxy.localizedName;
    }

    self.headerText = displayName;

    // Get header icon
    UIImage *appIconImage = [UIImage _applicationIconImageForBundleIdentifier:sectionID format:0 scale:[UIScreen mainScreen].scale];
    self.headerGlyph = appIconImage;
}

#pragma mark - Date Label

- (void)_configureDateLabelIfNecessary {
    if (self.dateLabel) {
        // View already exists, or no notification
        return;
    }

    // Create date label
    self.dateLabel = [[NUADateLabelRepository sharedRepository] startLabelWithStartDate:self.timestamp timeZone:self.notification.timeZone];
    self.dateLabel.delegate = self;
    self.dateLabel.font = [UIFont preferredFontForTextStyle:UIFontTextStyleSubheadline];
    self.dateLabel.textColor = [UIColor grayColor];
    self.dateLabel.translatesAutoresizingMaskIntoConstraints = NO;

    // Add to header stack
    [self.headerStackView insertArrangedSubview:self.dateLabel atIndex:3];
}

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
    [[NUADateLabelRepository sharedRepository] recycleLabel:self.dateLabel];
}

#pragma mark - Color Info

- (void)updateColorInfoFromNotification:(NUACoalescedNotification *)notification {
    // Check if info is cached or not
    NUAImageColorCache *colorCache = [NUAImageColorCache sharedCache];
    NSString *identifier = notification.sectionID;
    if ([colorCache hasColorDataForImageIdentifier:identifier type:NUAImageColorInfoTypeAppIcon]) {
        // Use cached info
        NUAImageColorInfo *colorInfo = [colorCache cachedColorInfoForImageIdentifier:identifier type:NUAImageColorInfoTypeAppIcon];
        [self _updateWithColorInfo:colorInfo];
    } else {
        // Generate colorinfo
        [colorCache cacheColorInfoForImage:self.headerGlyph identifier:identifier type:NUAImageColorInfoTypeAppIcon completion:^(NUAImageColorInfo *colorInfo) {
            [self _updateWithColorInfo:colorInfo];
        }];
    }
}

- (void)_updateWithColorInfo:(NUAImageColorInfo *)colorInfo {
    // Update header
    self.headerTint = colorInfo.textColor;

    // Update buttons
    NSArray<NUARippleButton *> *actionButtons = self.optionsButtonStack.arrangedSubviews;
    for (NUARippleButton *button in actionButtons) {
        [button setTitleColor:colorInfo.textColor forState:UIControlStateNormal];
    }
}

#pragma mark - Appearance Updates

- (void)traitCollectionDidChange:(UITraitCollection *)previousTraitCollection {
    [super traitCollectionDidChange:previousTraitCollection];

    // Check if appearance changed
    if (@available(iOS 13, *)) {
        if (![self.traitCollection hasDifferentColorAppearanceComparedToTraitCollection:previousTraitCollection]) {
            return;
        }

        // Change option bar color to match system
        BOOL inDarkMode = self.traitCollection.userInterfaceStyle == UIUserInterfaceStyleDark;
        UIColor *optionsBackgroundColor = inDarkMode ? PixelBackgroundColor : OreoBackgroundColor;
        self.optionsBar.backgroundColor = optionsBackgroundColor;
    }
}

@end