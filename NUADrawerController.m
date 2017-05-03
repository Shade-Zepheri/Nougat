#import "NUADrawerController.h"
#import "NUANotificationCenterInhibitor.h"
#import "NUAPreferenceManager.h"

extern BOOL quickMenuVisible;
extern BOOL mainPanelVisible;

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
    }

    return self;
}

- (void)handleShowDrawerGesture:(UIGestureRecognizer*)recognizer {
    if (recognizer.state != UIGestureRecognizerStateBegan || quickMenuVisible || mainPanelVisible || ![NUAPreferenceManager sharedSettings].enabled) {
        return;
    }

    [NUANotificationCenterInhibitor setInhibited:YES];

    [self.viewController showQuickToggles:NO];
    quickMenuVisible = YES;

    [NUANotificationCenterInhibitor setInhibited:NO];
}

@end
