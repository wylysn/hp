//
//  UIView+Additions.m
//  hp
//
//  Created by wangyilu on 16/6/15.
//  Copyright © 2016年 ___PURANG___. All rights reserved.
//

#import "UIView+Additions.h"
static __weak id currentFirstResponder;
@implementation UIView (Additions)
+ (id)currentFirstResponder {
    currentFirstResponder = nil;
    // This will invoke on first responder when target is nil
    [[UIApplication sharedApplication] sendAction:@selector(findFirstResponder:)
                                               to:nil
                                             from:nil
                                         forEvent:nil];
    return currentFirstResponder;
}

- (void)findFirstResponder:(id)sender {
    // First responder will set the static variable to itself
    currentFirstResponder = self;
}
@end
