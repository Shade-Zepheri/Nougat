#import <UIKit/UIKit.h>

// Private header to get and set state
@interface UIUserInterfaceStyleArbiter : NSObject
@property (readonly, nonatomic) UIUserInterfaceStyle currentStyle NS_AVAILABLE_IOS(13.0); 

+ (instancetype)sharedInstance;

- (void)toggleCurrentStyle;

@end