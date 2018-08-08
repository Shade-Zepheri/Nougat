@interface UIPanGestureRecognizer (Private)
@property (assign, nonatomic) BOOL failsPastMaxTouches;
@property (setter=_setHysteresis:) CGFloat _hysteresis;

@end
