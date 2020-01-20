@interface FBSDisplayIdentity : NSObject
@property (getter=isSecure, readonly, nonatomic) BOOL secure;
@property (readonly, nonatomic) NSInteger pid;
@property (readonly, nonatomic) BOOL isRootIdentity; 
@property (getter=isMainDisplay, readonly, nonatomic) BOOL mainDisplay; 
@property (getter=isExternal, readonly, nonatomic) BOOL external;
@property (getter=isCarDisplay, readonly, nonatomic) BOOL carDisplay; 
@property (getter=isCarInstrumentsDisplay, readonly, nonatomic) BOOL carInstrumentsDisplay; 

@end