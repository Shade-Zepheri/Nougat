#import <objc/runtime.h>
#import <BackBoardServices/BKSDisplayBrightness.h>
#import <QuartzCore/QuartzCore.h>
#import <SpringBoard/SBNotificationCenterController.h>
#import <SpringBoard/SBMainDisplaySystemGestureManager.h>
#import <SpringBoard/SBScreenEdgePanGestureRecognizer.h>
#import <SpringBoard/SBUIController.h>
#import <SpringBoard/SBWiFiManager.h>
#import <SpringBoard/SpringBoard.h>
#import <UIKit/UIKit.h>
#import <UIKit/_UIBackdropView.h>
#import <version.h>

#define kScreenWidth CGRectGetMaxX([UIScreen mainScreen].bounds)
#define kScreenHeight CGRectGetMaxY([UIScreen mainScreen].bounds)

#define NexusDarkColor [UIColor colorWithRed:0.15 green:0.20 blue:0.22 alpha:1.0]
#define NexusTintColor [UIColor colorWithRed:0.39 green:1.00 blue:0.85 alpha:1.0]
#define PixelDarkColor [UIColor colorWithRed:0.13 green:0.13 blue:0.13 alpha:1.0]
#define PixelTintColor [UIColor colorWithRed:0.27 green:0.54 blue:1.00 alpha:1.0]
#define NougatLabelColor [UIColor colorWithRed:0.33 green:0.43 blue:0.48 alpha:1.0]

@interface SBScreenEdgePanGestureRecognizer ()
- (instancetype)initWithTarget:()target action:(SEL)action;
@end

@interface SBSystemGestureManager ()
@property (assign,getter=areSystemGesturesDisabledForAccessibility,nonatomic) BOOL systemGesturesDisabledForAccessibility;
- (void)_disableSystemGesture:(UIGestureRecognizer *)gesture withType:(SBSystemGestureType)type;
- (void)_enableSystemGesture:(UIGestureRecognizer *)gesture withType:(SBSystemGestureType)type;
@end

@interface _UIBackdropView : UIView
- (instancetype)initWithPrivateStyle:(NSUInteger)style;
@end

@interface UIWindow (Private)
- (void)_setSecure:(BOOL)secure;
@end
