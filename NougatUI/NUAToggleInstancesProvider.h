#import <NougatServices/NougatServices.h>
#import "NUAToggleInstance.h"

@class NUAToggleInstancesProvider;
@protocol NUAToggleInstancesProviderObserver <NSObject>

@required
- (void)toggleInstancesChangedForToggleInstancesProvider:(NUAToggleInstancesProvider *)toggleInstancesProvider;

@end

typedef void (^NUAToggleInstancesProviderObserverBlock)(id<NUAToggleInstancesProviderObserver> observer);

@interface NUAToggleInstancesProvider : NSObject
@property (readonly, nonatomic) NSArray<NUAToggleInstance *> *toggleInstances;

- (instancetype)initWithPreferences:(NUAPreferenceManager *)preferences;

- (void)addObserver:(id<NUAToggleInstancesProviderObserver>)observer;
- (void)removeObserver:(id<NUAToggleInstancesProviderObserver>)observer;

@end