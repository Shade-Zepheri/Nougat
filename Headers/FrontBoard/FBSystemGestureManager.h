@class FBSDisplay;

@interface FBSystemGestureManager : NSObject <UIGestureRecognizerDelegate>

+ (instancetype)sharedInstance;

- (void)addGestureRecognizer:(id)recognizer toDisplay:(FBSDisplay *)display;

@end
