@class FBSDisplayIdentity;

@interface _UISystemGestureManager : NSObject

+ (instancetype)sharedInstance;

- (void)addGestureRecognizer:(UIGestureRecognizer *)gestureRecognizer toDisplayWithIdentity:(FBSDisplayIdentity *)identity;
- (void)removeGestureRecognizer:(UIGestureRecognizer *)gestureRecognizer fromDisplayWithIdentity:(FBSDisplayIdentity *)identity;

@end