// Since the one that comes with thoes causes linking errors

@interface UIPanGestureRecognizer (Internal)

@property (setter=_setHysteresis:) CGFloat _hysteresis;
@property (assign, nonatomic) BOOL failsPastMaxTouches;

@end
