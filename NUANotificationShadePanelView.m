#import "NUANotificationShadePanelView.h"
#import "NUAPreferenceManager.h"
#import "Macros.h"

@implementation NUANotificationShadePanelView

+ (CGFloat)baseHeight {
    return 150.0;
}

#pragma mark - Initialization

- (instancetype)initWithDefaultSize {
    // Create with base height but hidden at top of screen
    CGRect frame = CGRectMake(0, -[self.class baseHeight], kScreenWidth, [self.class baseHeight]);
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [NUAPreferenceManager sharedSettings].backgroundColor;

        NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
        [center addObserver:self selector:@selector(backgroundColorDidChange:) name:@"NUANotificationShadeChangedBackgroundColor" object:nil];
    }

    return self;
}

#pragma mark - Notifications

- (void)backgroundColorDidChange:(NSNotification *)notification {
    NSDictionary *colorInfo = notification.userInfo;
    self.backgroundColor = colorInfo[@"backgroundColor"];
}

#pragma mark - View management

- (void)expandHeight:(CGFloat)height {
    CGFloat baseHeight = [self.class baseHeight];

    // Determine if should expand or pan
    if (height < baseHeight) {
        // Move down
        CGRect newFrame = CGRectMake(0, height - baseHeight, CGRectGetWidth(self.bounds), baseHeight);
        self.frame = newFrame;
    } else {
        // Actually expand view
        CGRect newFrame = CGRectMake(0, 0, CGRectGetWidth(self.bounds), height);
        self.frame = newFrame;
    }
}

- (void)setContentView:(UIView *)contentView {
    if (self.contentView == contentView) {
        return;
    }

    if ([self.contentView superview] == self) {
        [self.contentView removeFromSuperview];
    }

    _contentView = contentView;

    if ([self.contentView superview] == self) {
        return;
    }

    [self addSubview:contentView];

    // Constraints
    self.contentView.translatesAutoresizingMaskIntoConstraints = NO;

    [self.contentView.topAnchor constraintEqualToAnchor:self.topAnchor].active = YES;
    [self.contentView.bottomAnchor constraintEqualToAnchor:self.bottomAnchor].active = YES;
    [self.contentView.leadingAnchor constraintEqualToAnchor:self.leadingAnchor].active = YES;
    [self.contentView.trailingAnchor constraintEqualToAnchor:self.trailingAnchor].active = YES;
}

@end