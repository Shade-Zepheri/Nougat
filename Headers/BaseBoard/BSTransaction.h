#import <Foundation/Foundation.h>

@interface BSTransaction : NSObject
@property (readonly, nonatomic) NSUInteger state;
@property (getter=isAborted, readonly, nonatomic) BOOL aborted;
@property (getter=isAuditHistoryEnabled, nonatomic) BOOL auditHistoryEnabled;
@property (readonly, nonatomic) NSSet<NSString *> *milestones; 
@property (getter=hasStarted, readonly, nonatomic) BOOL started;
@property (getter=isRunning, readonly, nonatomic) BOOL running;
@property (getter=isComplete, readonly, nonatomic) BOOL complete;
@property (getter=isFinishedWorking, readonly, nonatomic) BOOL finishedWorking;
@property (getter=isInterrupted, readonly, nonatomic) BOOL interrupted;
@property (getter=isInterruptible, readonly, nonatomic) BOOL interruptible;
@property (getter=isFailed, readonly, nonatomic) BOOL failed;
@property (readonly, nonatomic) NSError *error;
@property (readonly, nonatomic) NSArray<NSError *> *allErrors; 

- (void)addMilestone:(NSString *)milestone;
- (BOOL)removeMilestone:(NSString *)milestone;

- (void)addMilestones:(NSSet<NSString *> *)milestone;
- (BOOL)removeMilestones:(NSSet<NSString *> *)milestone;
- (void)removeAllMilestones;

@end