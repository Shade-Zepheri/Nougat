#import <objc/runtime.h>
#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>
#import <version.h>

@interface SBScreenEdgePanGestureRecognizer : UIScreenEdgePanGestureRecognizer
- (id)initWithTarget:(id)arg1 action:(SEL)arg2;
@end

@interface SBSystemGestureManager : NSObject
+ (id)mainDisplayManager;
- (void)addGestureRecognizer:(id)arg1 withType:(unsigned long long)arg2;
@end

@interface FBSystemGestureManager : NSObject <UIGestureRecognizerDelegate>
+ (instancetype)sharedInstance;
- (void)addGestureRecognizer:(id)arg1 toDisplay:(id)arg2;
@end

@interface FBDisplayManager : NSObject
+ (instancetype)sharedInstance;
+ (id)mainDisplay;
@end
