@interface NCNotificationListCell : UIView

- (void)_executeClearAction;
- (void)_executeDefaultAction;

// iOS 10.2
- (void)_executeDefaultActionIfCompleted;

- (void)cellOpenButtonPressed:(UIButton *)button;
- (void)cellClearButtonPressed:(UIButton *)button;

@end