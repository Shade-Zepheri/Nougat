#import <SpringBoard/SBIconController.h>

@interface SBIconController (Private)
@property (assign, nonatomic) BOOL isEditing;

- (void)setIsEditing:(BOOL)editing withFeedbackBehavior:(id)behavior;

@end
