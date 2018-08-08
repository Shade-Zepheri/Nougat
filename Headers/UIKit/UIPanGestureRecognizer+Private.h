@interface UIPanGestureRecognizer (Private)
@property (assign, nonatomic) BOOL failsPastMaxTouches;
@property (setter=_setHysteresis:) BOOL _hysteresis;

@end
