#import "NUADrawerController.h"
#import "NUANotificationCenterInhibitor.h"

@implementation NUADrawerController

+ (instancetype)sharedInstance {
    static NUADrawerController *sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[self alloc] init];
    });
    return sharedInstance;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        self.viewController = [[NUADrawerViewController alloc] init];
        [self.viewController view];
        _quickMenuVisible = NO;
        _mainPanelVisible = NO;
    }

    return self;
}

- (void)handleShowDrawerGesture:(UIGestureRecognizer*)recognizer {
    if (recognizer.state != UIGestureRecognizerStateBegan || _mainPanelVisible) {
        return;
    }

    [NUANotificationCenterInhibitor setInhibited:YES];
    if (!_quickMenuVisible && !_mainPanelVisible) {
        [self.viewController showQuickToggles];
        _quickMenuVisible = YES;
    } else if (_quickMenuVisible && !_mainPanelVisible) {
        [self.viewController showMainPanel];
        _mainPanelVisible = YES;
    }
    [NUANotificationCenterInhibitor setInhibited:NO];
}

@end
