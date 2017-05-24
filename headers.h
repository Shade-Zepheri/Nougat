#import <objc/runtime.h>
#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>
#import <BackBoardServices/BKSDisplayBrightness.h>
#import <version.h>

#define kScreenWidth CGRectGetMaxX([UIScreen mainScreen].bounds)
#define kScreenHeight CGRectGetMaxY([UIScreen mainScreen].bounds)

#define NexusDarkColor [UIColor colorWithRed:0.15 green:0.20 blue:0.22 alpha:1.0]
#define NexusTintColor [UIColor colorWithRed:0.39 green:1.00 blue:0.85 alpha:1.0]
#define PixelDarkColor [UIColor colorWithRed:0.13 green:0.13 blue:0.13 alpha:1.0]
#define PixelTintColor [UIColor colorWithRed:0.27 green:0.54 blue:1.00 alpha:1.0]
#define NougatLabelColor [UIColor colorWithRed:0.33 green:0.43 blue:0.48 alpha:1.0]

@interface SBScreenEdgePanGestureRecognizer : UIScreenEdgePanGestureRecognizer
- (instancetype)initWithTarget:(id)arg1 action:(SEL)arg2;
@end

@interface SBSystemGestureManager : NSObject
+ (instancetype)mainDisplayManager;
- (void)addGestureRecognizer:(id)arg1 withType:(unsigned long long)arg2;
- (void)_disableSystemGesture:(id)arg1 withType:(unsigned long long)arg2 ;
- (void)_enableSystemGesture:(id)arg1 withType:(unsigned long long)arg2 ;
@end

@interface SBWiFiManager : NSObject
- (NSString*)currentNetworkName;
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

@interface _UIBackdropView : UIView
- (instancetype)initWithPrivateStyle:(long long)arg1;
@end
