#import "headers.h"
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

- (void)dismissDrawer {
    [self.viewController dismissDrawer];
}

- (void)showQuickToggles {
    [self.viewController showQuickToggles:YES];
}

- (void)showMainToggles {
    [self.viewController showMainPanel];
}

- (BOOL)mainTogglesVisible {
    return mainPanelVisible;
}

- (void)handleShowDrawerGesture:(UIGestureRecognizer*)recognizer {
    if (recognizer.state != UIGestureRecognizerStateBegan || quickMenuVisible || mainPanelVisible || ![NUAPreferenceManager sharedSettings].enabled) {
        return;
    }

    CGPoint touchLocation = [recognizer locationInView:self.viewController.view];
    if (touchLocation.x < kScreenWidth / 3) {
        return;
    }

    [NUANotificationCenterInhibitor setInhibited:YES];

    if (touchLocation.x > kScreenWidth / 1.5) {
        [self.viewController showMainPanel];
    } else {
        [self.viewController showQuickToggles:NO];
    }


    [NUANotificationCenterInhibitor setInhibited:NO];
}

@end
