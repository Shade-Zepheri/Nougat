@interface NCNotificationListCell : UIView

- (void)_executeClearAction;
- (void)_executeDefaultAction;

- (void)cellOpenButtonPressed:(UIButton *)button;
- (void)cellClearButtonPressed:(UIButton *)button;

@end