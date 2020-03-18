#import <SpringBoard/SBIconController.h>

@class SBRootFolderController;

@interface SBIconController (Private)
// iOS 10-12
@property (assign, nonatomic) BOOL isEditing;

- (void)setIsEditing:(BOOL)editing withFeedbackBehavior:(id)behavior;

// iOS 13
@property (getter=_rootFolderController, readonly, nonatomic) SBRootFolderController *rootFolderController;

@end
