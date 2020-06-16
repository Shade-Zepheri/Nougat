#import <NougatServices/NougatServices.h>
#import "NUAToggleButton.h"

@interface NUAToggleInstance : NSObject
@property (strong, readonly, nonatomic) NUAToggleInfo *toggleInfo;
@property (strong, readonly, nonatomic) NUAToggleButton *toggle;

- (instancetype)initWithToggleInfo:(NUAToggleInfo *)toggleInfo toggle:(NUAToggleButton *)toggle;

@end