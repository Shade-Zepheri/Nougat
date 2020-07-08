#import <UIKit/UIKit.h>

@interface NUAMediaHeaderView : UIView
@property (copy, nonatomic) NSString *song;
@property (copy, nonatomic) NSString *artist;

- (void)updateWithPrimaryColor:(UIColor *)primaryColor accentColor:(UIColor *)accentColor;

@end