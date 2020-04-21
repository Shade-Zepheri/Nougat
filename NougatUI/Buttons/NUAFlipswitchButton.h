#import "NUAToggleButton.h"

@interface NUAFlipswitchButton : NUAToggleButton
@property (copy, readonly, nonatomic) NSString *switchIdentifier;

- (instancetype)initWithSwitchIdentifier:(NSString *)identifier;

@end