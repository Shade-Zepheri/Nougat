#import <UIKit/UIKit.h>
#import <NougatUI/NougatUI.h>

@interface NUAUserAuthenticationManager : NSObject <NUAUserAuthenticationProvider>
@property (getter=isAuthenticated, readonly, nonatomic) BOOL authenticated;

- (void)addObserver:(id<NUAUserAuthenticationObserver>)observer;
- (void)removeObserver:(id<NUAUserAuthenticationObserver>)observer;

@end