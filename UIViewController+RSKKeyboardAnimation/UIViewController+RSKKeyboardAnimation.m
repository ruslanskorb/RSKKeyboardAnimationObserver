//
// UIViewController+RSKKeyboardAnimation.m
//
// Copyright (c) 2015 Anton Gaenko
// Copyright (c) 2015-present Ruslan Skorb, http://ruslanskorb.com/
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
// THE SOFTWARE.
//

#import "UIViewController+RSKKeyboardAnimation.h"
#import <objc/runtime.h>

static void * RKSAnimationsBlockAssociationKey = &RKSAnimationsBlockAssociationKey;
static void * RKSBeforeAnimationsBlockAssociationKey = &RKSBeforeAnimationsBlockAssociationKey;
static void * RKSAnimationsCompletionBlockAssociationKey = &RKSAnimationsCompletionBlockAssociationKey;

@implementation UIViewController (RSKKeyboardAnimation)

#pragma mark - Public API

- (void)rsk_subscribeKeyboardWithAnimations:(RKSAnimationsWithKeyboardBlock)animations
                                 completion:(RKSCompletionKeyboardAnimations)completion
{
    [self rsk_subscribeKeyboardWithBeforeAnimations:nil animations:animations completion:completion];
}

- (void)rsk_subscribeKeyboardWithBeforeAnimations:(RKSBeforeAnimationsWithKeyboardBlock)beforeAnimations
                                       animations:(RKSAnimationsWithKeyboardBlock)animations
                                       completion:(RKSCompletionKeyboardAnimations)completion
{
    // we shouldn't check for nil because it does nothing with nil
    objc_setAssociatedObject(self, RKSBeforeAnimationsBlockAssociationKey, beforeAnimations, OBJC_ASSOCIATION_COPY_NONATOMIC);
    objc_setAssociatedObject(self, RKSAnimationsBlockAssociationKey, animations, OBJC_ASSOCIATION_COPY_NONATOMIC);
    objc_setAssociatedObject(self, RKSAnimationsCompletionBlockAssociationKey, completion, OBJC_ASSOCIATION_COPY_NONATOMIC);
    
    // subscribe to keyboard animations
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(rsk_handleWillShowKeyboardNotification:)
                                                 name:UIKeyboardWillShowNotification
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(rsk_handleWillHideKeyboardNotification:)
                                                 name:UIKeyboardWillHideNotification
                                               object:nil];
}

- (void)rsk_unsubscribeKeyboard
{
    // remove assotiated blocks
    objc_setAssociatedObject(self, RKSAnimationsBlockAssociationKey, nil, OBJC_ASSOCIATION_COPY_NONATOMIC);
    objc_setAssociatedObject(self, RKSAnimationsCompletionBlockAssociationKey, nil, OBJC_ASSOCIATION_COPY_NONATOMIC);
    
    // unsubscribe from keyboard animations
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillHideNotification object:nil];
}

#pragma mark - Helper Methods

- (void)rsk_handleWillShowKeyboardNotification:(NSNotification *)notification
{
    [self rsk_keyboardWillShowHide:notification isShowing:YES];
}

- (void)rsk_handleWillHideKeyboardNotification:(NSNotification *)notification
{
    [self rsk_keyboardWillShowHide:notification isShowing:NO];
}

- (void)rsk_keyboardWillShowHide:(NSNotification *)notification isShowing:(BOOL)isShowing
{
    // getting keyboard animation attributes
    CGRect keyboardRect = [[notification.userInfo objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue];
    UIViewAnimationCurve curve = [[notification.userInfo objectForKey:UIKeyboardAnimationCurveUserInfoKey] integerValue];
    NSTimeInterval duration = [[notification.userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey] doubleValue];
    
    // getting passed blocks
    RKSAnimationsWithKeyboardBlock animationsBlock = objc_getAssociatedObject(self, RKSAnimationsBlockAssociationKey);
    RKSBeforeAnimationsWithKeyboardBlock beforeAnimationsBlock = objc_getAssociatedObject(self, RKSBeforeAnimationsBlockAssociationKey);
    RKSCompletionKeyboardAnimations completionBlock = objc_getAssociatedObject(self, RKSAnimationsCompletionBlockAssociationKey);
    
    if (beforeAnimationsBlock) beforeAnimationsBlock(keyboardRect, duration, isShowing);
    
    [UIView animateWithDuration:duration
                          delay:0
                        options:UIViewAnimationOptionBeginFromCurrentState
                     animations:^{
                         [UIView setAnimationCurve:curve];
                         if (animationsBlock) animationsBlock(keyboardRect, duration, isShowing);
                     }
                     completion:completionBlock];
}

@end
