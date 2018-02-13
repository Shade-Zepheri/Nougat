@interface SBBacklightController : NSObject

+ (SBBacklightController *)sharedInstance;

@property (readonly, nonatomic) BOOL screenIsOn;

@end
