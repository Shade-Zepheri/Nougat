#import <objc/runtime.h>
#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>
#import <version.h>

#define kScreenWidth CGRectGetMaxX([UIScreen mainScreen].bounds)
#define kScreenHeight CGRectGetMaxY([UIScreen mainScreen].bounds)
#define NougatDarkColor [UIColor colorWithRed:0.15 green:0.20 blue:0.22 alpha:1.0]
#define NougatLightColor [UIColor colorWithRed:0.93 green:0.94 blue:0.95 alpha:1.0]

@interface SBScreenEdgePanGestureRecognizer : UIScreenEdgePanGestureRecognizer
- (instancetype)initWithTarget:(id)arg1 action:(SEL)arg2;
@end

@interface SBSystemGestureManager : NSObject
+ (instancetype)mainDisplayManager;
- (void)addGestureRecognizer:(id)arg1 withType:(unsigned long long)arg2;
- (void)_disableSystemGesture:(id)arg1 withType:(unsigned long long)arg2 ;
- (void)_enableSystemGesture:(id)arg1 withType:(unsigned long long)arg2 ;
@end

@interface FBSystemGestureManager : NSObject <UIGestureRecognizerDelegate>
+ (instancetype)sharedInstance;
- (void)addGestureRecognizer:(id)arg1 toDisplay:(id)arg2;
@end

@interface FBSDisplay : NSObject
@end

@interface FBDisplayManager : NSObject
+ (instancetype)sharedInstance;
+ (FBSDisplay*)mainDisplay;
@end

@interface SBHomeScreenWindow : UIWindow
@end

@interface SBUIController : NSObject
+ (instancetype)sharedInstance;
- (id)window;
@end

@interface UIApplication (Private)
- (void)launchApplicationWithIdentifier:(NSString*)identifier suspended:(BOOL)suspended;
@end
