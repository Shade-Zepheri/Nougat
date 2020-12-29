#import <UIKit/UIKit.h>

@protocol NUAUserAuthenticationObserver <NSObject>

- (void)userAuthenticationStateChanged:(BOOL)isAuthenticated;

@end

@protocol NUAUserAuthenticationProvider <NSObject>
@property (getter=isAuthenticated, readonly, nonatomic) BOOL authenticated;

@required;

- (void)addObserver:(id<NUAUserAuthenticationObserver>)observer;
- (void)removeObserver:(id<NUAUserAuthenticationObserver>)observer;

- (BOOL)isAuthenticated;

@end