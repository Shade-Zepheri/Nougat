#import "NSArray+Map.h"

@implementation NSArray (Map)

- (NSArray *)map:(id (^)(id obj))block {
    NSMutableArray *array = [NSMutableArray array];
    [self enumerateObjectsUsingBlock:^(id obj, NSUInteger index, BOOL *stop) {
        [array addObject:block(obj)];
    }];

    return [array copy];
}

@end