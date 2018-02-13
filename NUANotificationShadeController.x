#import "NUANotificationShadeController.h"
#import "NUANotificationCenterInhibitor.h"
#import "NUAPreferenceManager.h"

extern BOOL quickMenuVisible;
extern BOOL mainPanelVisible;
#import "Macros.h"
#import <FrontBoard/FBDisplayManager.h>
#import <FrontBoard/FBSystemGestureManager.h>
#import <SpringBoard/SBBacklightController.h>

@implementation NUANotificationShadeController

+ (instancetype)defaultNotificationShade {
    static NUANotificationShadeController *sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[self alloc] init];
    });
    return sharedInstance;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        _viewController = [[NUADrawerViewController alloc] init];
        [self.viewController view];

        // Registering for same notifications that NC does
        NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
        [center addObserver:self selector:@selector(_handleBacklightFadeFinished:) name:@"SBBacklightFadeFinishedNotification" object:nil];
        [center addObserver:self selector:@selector(_handleUIDidLock:) name:@"SBLockScreenUIDidLockNotification" object:nil];

        SBScreenEdgePanGestureRecognizer *recognizer = [[%c(SBScreenEdgePanGestureRecognizer) alloc] initWithTarget:self action:@selector(handleShowDrawerGesture:) type:SBSystemGestureTypeShowNotificationCenter];
        recognizer.edges = UIRectEdgeTop;
        [[%c(SBSystemGestureManager) mainDisplayManager] addGestureRecognizer:recognizer withType:50];
    }

    return self;
}

- (void)_handleBacklightFadeFinished:(NSNotification *)notification {
    BOOL screenIsOn = [[%c(SBBacklightController) sharedInstance] screenIsOn];

    if (!screenIsOn) {
        [self dismissDrawer:NO];
    }
}

- (void)_handleUIDidLock:(NSNotification *)notification {
    BOOL screenIsOn = [[%c(SBBacklightController) sharedInstance] screenIsOn];

    if (screenIsOn) {
        [self dismissDrawer:YES];
    }
}

- (void)dismissDrawer:(BOOL)animated {
    if (!animated) {
        [UIView performWithoutAnimation:^{
            [self.viewController dismissDrawer];
        }];
        return;
    }

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

- (void)handleShowDrawerGesture:(SBScreenEdgePanGestureRecognizer *)recognizer {
    //TODO rework whole gesture 
    if (recognizer.state != UIGestureRecognizerStateBegan || quickMenuVisible || mainPanelVisible || ![NUAPreferenceManager sharedSettings].enabled) {
        return;
    }

    CGPoint touchLocation = [recognizer locationInView:self.viewController.view];
    if (touchLocation.x < kScreenWidth / 3) {
        [[%c(SBNotificationCenterController) sharedInstance] presentAnimated:YES completion:nil];
        return;
    }

    NUANotificationCenterInhibitor.inhibited = YES;

    if (touchLocation.x > kScreenWidth / 1.5) {
        [self.viewController showMainPanel];
    } else {
        [self.viewController showQuickToggles:NO];
    }

    [[UIApplication sharedApplication] setStatusBarHidden:YES];
}

@end
