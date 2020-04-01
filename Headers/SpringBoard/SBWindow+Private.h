#import <SpringBoard/SBWindow.h>

@interface SBWindow ()

// Technically this method is in SBFWindow, but I dont wanna mess up inheritance and stuffs
- (void)resignAsKeyWindow API_AVAILABLE(ios(12));


@end