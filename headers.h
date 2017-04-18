#import <objc/runtime.h>
#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>
#import <version.h>

#define NougatDarkColor [UIColor colorWithRed:0.15 green:0.20 blue:0.22 alpha:1.0]
#define NougatLightColor [UIColor colorWithRed:0.93 green:0.94 blue:0.95 alpha:1.0]

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
