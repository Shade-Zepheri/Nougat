#import "NUADrawerController.h"

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
    }

    return self;
}

- (void)handleShowDrawerGesture:(UIGestureRecognizer*)recognizer {
    if (recognizer.state != UIGestureRecognizerStateBegan) {
        return;
    }

    
}

@end
