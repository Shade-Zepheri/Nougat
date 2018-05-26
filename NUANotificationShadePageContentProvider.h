#import <Foundation/Foundation.h>

@protocol NUANotificationShadePageContentProvider <NSObject>
@property (nonatomic) CGFloat presentedHeight;

@required
- (void)setPresentedHeight:(CGFloat)height;
- (CGFloat)presentedHeight;

@end