#import <UIKit/UIKit.h>
#include <sys/cdefs.h>

__BEGIN_DECLS

@class FBSDisplay;

@interface FBSystemGestureManager : NSObject <UIGestureRecognizerDelegate>

+ (instancetype)sharedInstance;

- (void)addGestureRecognizer:(UIGestureRecognizer *)recognizer toDisplay:(FBSDisplay *)display;
- (void)removeGestureRecognizer:(UIGestureRecognizer *)recognizer fromDisplay:(FBSDisplay *)display;

@end

// Minor but SB uses these functions to get location / translation / velocity
CGPoint FBSystemGestureLocationInView(UIGestureRecognizer *recognizer, UIView *view);
CGPoint FBSystemGestureVelocityInView(UIGestureRecognizer *recognizer, UIView *view);
CGPoint FBSystemGestureTranslationInView(UIGestureRecognizer *recognizer, UIView *view);

__END_DECLS