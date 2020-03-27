#import "NUADateLabelRepository.h"

@interface NUADateLabelRepository () {
    NSMutableSet<NUARelativeDateLabel *> *_recycledLabels;
}

@end

@implementation NUADateLabelRepository

#pragma mark - Singleton

+ (instancetype)sharedRepository {
    static NUADateLabelRepository *sharedRepository = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedRepository = [[self alloc] init];
    });

    return sharedRepository;
}

#pragma mark - Initialization

- (instancetype)init {
    self = [super init];
    if (self) {
        // Set defaults
        _recycledLabels = [NSMutableSet set];

        // Register for notifications
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_purgeRecycledLabels) name:UIApplicationDidReceiveMemoryWarningNotification object:nil];
    }

    return self;
}

- (void)dealloc {
    // Deregister for notifications
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIApplicationDidReceiveMemoryWarningNotification object:nil];
}

#pragma mark - Label Management

- (NUARelativeDateLabel *)startLabelWithStartDate:(NSDate *)startDate timeZone:(NSTimeZone *)timeZone {
    NUARelativeDateLabel *dateLabel = _recycledLabels.anyObject;
    if (!dateLabel) {
        // Set is empty, init
        dateLabel = [[NUARelativeDateLabel alloc] init];
    } else {
        // Remove object from set
        [_recycledLabels removeObject:dateLabel];
    }

    // Configure label
    [dateLabel startCollectingUpdates];
    [dateLabel setStartDate:startDate withTimeZone:timeZone];
    [dateLabel endCollectingUpdates];

    return dateLabel;
}

- (void)recycleLabel:(NUARelativeDateLabel *)label {
    // Recycle and add to set
    [label prepareForReuse];

    if (_recycledLabels.count > 10) {
        // Dont add if there are already 9 labels
        return;
    }

    // Add to set
    [_recycledLabels addObject:label];
}

#pragma mark - Purging

- (void)_purgeRecycledLabels {
    // Remove all objects
    [_recycledLabels removeAllObjects];
}

@end