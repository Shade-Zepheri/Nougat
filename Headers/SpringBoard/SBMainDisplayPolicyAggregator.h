#import "SBPolicyAggregator.h"

typedef NS_ENUM(NSUInteger, SBPolicyCapability) {
    SBPolicyCapabilityNone,
    SBPolicyCapabilitySuggestedApplication,
    SBPolicyCapabilityLockScreenBulletin,
    SBPolicyCapabilityUnlockToPluginSpecifiedApplication,
    SBPolicyCapabilityAssistantEnabled,
    SBPolicyCapabilityAssistant,
    SBPolicyCapabilitySendMediaCommand,
    SBPolicyCapabilitySystemGesture,
    SBPolicyCapabilityVoiceControl,
    SBPolicyCapabilitySpotlight,
    SBPolicyCapabilityLockScreenCameraSupported,
    SBPolicyCapabilityLockScreenCamera,
    SBPolicyCapabilityCoverSheet,
    SBPolicyCapabilityDismissCoverSheet,
    SBPolicyCapabilityControlCenter,
    SBPolicyCapabilityLogout,
    SBPolicyCapabilityLoginWindow,
    SBPolicyCapabilityHomeScreenEditing,
    SBPolicyCapabilityScreenshot,
    SBPolicyCapabilityCommandTab,
    SBPolicyCapabilityLockScreenControlCenter,
    SBPolicyCapabilityLockScreenNotificationCenter,
    SBPolicyCapabilityLockScreenTodayView,
    SBPolicyCapabilityTodayView,
    SBPolicyCapabilityLiftToWake,
    SBPolicyCapabilityQuickNote
};

@interface SBMainDisplayPolicyAggregator : SBPolicyAggregator

- (BOOL)allowsCapability:(SBPolicyCapability)capability;
- (BOOL)allowsCapability:(SBPolicyCapability)capability explanation:(NSString **)explanation;

@end