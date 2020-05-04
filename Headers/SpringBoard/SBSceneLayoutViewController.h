#import <UIKit/UIKit.h>

@class SBMainDisplaySceneLayoutViewController;

@interface SBSceneLayoutViewController : UIViewController

+ (SBMainDisplaySceneLayoutViewController *)mainDisplaySceneLayoutViewController; // iOS 11-13
+ (SBMainDisplaySceneLayoutViewController *)mainDisplayLayoutViewController; // iOS 10

@end