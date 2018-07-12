#import <Foundation/Foundation.h>

@protocol NUANotificationShadePageContentProvider <NSObject>
@property (assign, nonatomic) CGFloat presentedHeight;

@required
- (void)setPresentedHeight:(CGFloat)height;
- (CGFloat)presentedHeight;

@end