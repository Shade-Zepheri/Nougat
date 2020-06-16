#import <UIKit/UIKit.h>

@interface NUAToggleDescription : NSObject
@property (copy, readonly, nonatomic) NSString *identifier;
@property (copy, readonly, nonatomic) NSString *displayName;
@property (readonly, nonatomic) UIImage *iconImage;

+ (instancetype)descriptionWithIdentifier:(NSString *)identifier displayName:(NSString *)displayName iconImage:(UIImage *)iconImage;

@end