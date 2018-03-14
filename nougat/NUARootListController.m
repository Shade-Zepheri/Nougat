#include "NUARootListController.h"

@implementation NUARootListController

+ (NSString *)hb_specifierPlist {
    return @"Root";
}

- (void)sendEmail {
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"mailto:ziroalpha@gmail.com?subject=Nougat"]];
}

@end
