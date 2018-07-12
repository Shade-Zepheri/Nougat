#import <UIKit/UIKit.h>

@interface NUANotificationShadeModuleViewController : UIViewController {
    NSLayoutConstraint *_heightConstraint;
}

@property (copy, readonly, nonatomic) NSString *moduleIdentifier;

+ (Class)viewClass;

@end