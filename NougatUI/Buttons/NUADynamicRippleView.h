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

#import "NUARippleViewBase.h"

typedef NS_OPTIONS(NSUInteger, NUARippleState) {
    NUARippleStateNormal = 0,
    NUARippleStateHighlighted = 1 << 0,
    NUARippleStateSelected = 1 << 1,
    NUARippleStateDragged = 1 << 2
};

@interface NUADynamicRippleView : NUARippleViewBase
@property (getter=isSelected, nonatomic) BOOL selected;
@property (getter=isRippleHighlighted, nonatomic) BOOL rippleHighlighted;
@property (getter=isDragged, nonatomic) BOOL dragged;

@property (assign, nonatomic) BOOL allowsSelection;

- (UIColor *)rippleColorForState:(NUARippleState)state;
- (void)setRippleColor:(UIColor *)rippleColor forState:(NUARippleState)state;

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event;
- (void)touchesMoved:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event;
- (void)touchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event;
- (void)touchesCancelled:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event;

@end
