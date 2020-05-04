#import <UIKit/UIKit.h>

@interface SBReachabilityManager : NSObject
@property (readonly, nonatomic) UIPanGestureRecognizer *dismissPanGestureRecognizer; // iOS 12-13

+ (instancetype)sharedInstance;

@end