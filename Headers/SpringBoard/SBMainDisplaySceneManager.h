#import "SBSceneManager.h"
#import "SBMainDisplayPolicyAggregator.h"

@interface SBMainDisplaySceneManager : SBSceneManager
@property (readonly, nonatomic) SBMainDisplayPolicyAggregator *policyAggregator;

@end