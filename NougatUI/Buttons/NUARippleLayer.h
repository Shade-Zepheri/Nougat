// Copyright 2019-present the Material Components for iOS authors. All Rights Reserved.
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
// http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.
// Modifications copyright (C) 2020 Alfonso Gonzalez

#import <QuartzCore/QuartzCore.h>
#import <UIKit/UIKit.h>

@class NUARippleLayer;

typedef void (^NUARippleCompletionBlock)(void);

@interface NUARippleLayer : CAShapeLayer
@property (getter=isStartAnimationActive, readonly, nonatomic) BOOL startAnimationActive;
@property (assign, nonatomic) CFTimeInterval rippleTouchDownStartTime;
@property (assign, nonatomic) CGFloat maximumRadius;

- (void)startRippleAtPoint:(CGPoint)point animated:(BOOL)animated;
- (void)endRippleAnimated:(BOOL)animated completion:(NUARippleCompletionBlock)completion;

- (void)fadeInRippleAnimated:(BOOL)animated;
- (void)fadeOutRippleAnimated:(BOOL)animated;

@end