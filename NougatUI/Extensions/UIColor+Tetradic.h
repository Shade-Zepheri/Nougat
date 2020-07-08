#import <UIKit/UIKit.h>

@interface UIColor (Tetradic)
@property (copy, readonly, nonatomic) NSArray<UIColor *> *tetradicColors;

- (BOOL)isSimilarToColor:(UIColor *)color;

@end