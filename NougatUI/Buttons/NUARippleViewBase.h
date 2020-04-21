#import <UIKit/UIKit.h>

typedef NS_ENUM(NSUInteger, NUARippleStyle) {
    NUARippleStyleBounded,
    NUARippleStyleUnbounded
};

@interface NUARippleViewBase : UIView
@property (assign, nonatomic) NUARippleStyle rippleStyle;
@property (strong, nonatomic) UIColor *rippleColor;
@property (strong, nonatomic) UIColor *activeRippleColor;

- (void)cancelAllRipplesAnimated:(BOOL)animated;

- (void)fadeInRippleAnimated:(BOOL)animated;
- (void)fadeOutRippleAnimated:(BOOL)animated;

- (void)beginRippleTouchDownAtPoint:(CGPoint)point animated:(BOOL)animated;
- (void)beginRippleTouchUpAnimated:(BOOL)animated;

@end

