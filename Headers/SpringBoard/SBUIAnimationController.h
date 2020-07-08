#import "SBTransaction.h"

@interface SBUIAnimationController : SBTransaction

- (void)_noteAnimationDidFinish;
- (void)_noteAnimationDidFail;
- (void)_noteAnimationDidRevealApplication;

@end