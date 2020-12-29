#import "NUAUserAuthenticationManager.h"
#import <SpringBoard/SpringBoard-Umbrella.h>
#import <SpringBoardFoundation/SpringBoardFoundation.h>

@interface NUAUserAuthenticationManager ()
@property (strong, nonatomic) NSHashTable<id<NUAUserAuthenticationObserver>> *observers;
@property (strong, nonatomic) SBFUserAuthenticationController *authenticationController;

@end

@implementation NUAUserAuthenticationManager

#pragma mark - Init

- (instancetype)init {
    self = [super init];
    if (self) {
        self.observers = [NSHashTable weakObjectsHashTable];
        self.authenticationController = ((SpringBoard *)[UIApplication sharedApplication]).authenticationController;

        // Register for updates
        NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
        [center addObserver:self selector:@selector(_evaluateLockState:) name:@"SBFUserAuthenticationStateDidChangeNotification" object:nil];
    }

    return self;
}

#pragma mark - Properties

- (BOOL)isAuthenticated {
    return [self.authenticationController isAuthenticated];
}

#pragma mark - Observers

- (void)addObserver:(id<NUAUserAuthenticationObserver>)observer {
    if ([self.observers containsObject:observer]) {
        return;
    }

    [self.observers addObject:observer];
}

- (void)removeObserver:(id<NUAUserAuthenticationObserver>)observer {
    if (![_observers containsObject:observer]) {
        return;
    }

    [self.observers removeObject:observer];
}

- (void)notifyObserversOfAuthenticationState:(BOOL)isAuthenticated {
    dispatch_async(dispatch_get_main_queue(), ^{
        for (id<NUAUserAuthenticationObserver> observer in self.observers) {
            [observer userAuthenticationStateChanged:isAuthenticated];
        }
    });
}

#pragma mark - Notifications

- (void)_evaluateLockState:(NSNotification *)notification {
    // Pass to observers
    [self notifyObserversOfAuthenticationState:self.authenticated];
}

@end