//
//  Paddle.m
//  Pong1
//
//  Created by Peter Scheyer on 4/3/15.
//  Copyright (c) 2015 Peter Scheyer. All rights reserved.
//


#import "Paddle.h"

@interface Paddle ()

@property (nonatomic, strong) UIPanGestureRecognizer *panGesture;

@end

@implementation Paddle


- (instancetype) init{
    
    self = [super init];
    
    self.backgroundColor = [UIColor blueColor];
    self.panGesture = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(panFired:)];
    [self addGestureRecognizer:self.panGesture];
    
    return self;
}


#pragma Mark - Touch Handling

- (UIView *) viewFromTouches:(NSSet *)touches withEvent:(UIEvent *)event {
    
    UITouch *touch = [touches anyObject];
    CGPoint location = [touch locationInView:self];
    UIView *subview = [self hitTest:location withEvent:event];
    return (UIView *)subview;
}

- (void) panFired:(UIPanGestureRecognizer *)recognizer {
    if (recognizer.state == UIGestureRecognizerStateChanged) {
        CGPoint translation = [recognizer translationInView:self];
        
        NSLog(@"New Paddle Movement: %@", NSStringFromCGPoint(translation));
        
        if ([self.delegate respondsToSelector:@selector(paddle:didTryToPanWithOffset:)]) {
            [self.delegate paddle:self didTryToPanWithOffset:translation];
        }
        
        [recognizer setTranslation:CGPointZero inView:self];
    }
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
