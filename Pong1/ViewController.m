//
//  ViewController.m
//  Pong1
//
//  Created by Peter Scheyer on 4/2/15.
//  Copyright (c) 2015 Peter Scheyer. All rights reserved.
//

#import "ViewController.h"
#import "Paddle.h"

@interface ViewController ()
@property (nonatomic, strong) UIDynamicAnimator *animator;
@property (nonatomic, strong) UIView *ball;
@property (nonatomic, strong) Paddle *paddle;
@property CGFloat paddle1Y;


@end

@implementation ViewController

- (void)viewDidLoad {
    self.ball = [[UIView alloc] initWithFrame:CGRectMake(100,100,40,40)];
    self.ball.backgroundColor = [UIColor redColor];
    [self.view addSubview:self.ball];
    
    
    CGFloat paddle1Y = CGRectGetMaxY(self.view.bounds) / 16;
    
    self.paddle = [[Paddle alloc] initWithFrame:CGRectMake(CGRectGetMaxX(self.view.bounds) / 2 - (CGRectGetMaxX(self.view.bounds) / 3) / 2, CGRectGetMaxY(self.view.bounds) / 8, CGRectGetMaxX(self.view.bounds) / 3, paddle1Y)];
    self.paddle.backgroundColor = [UIColor blueColor];
    [self.view addSubview:self.paddle];
    
    self.animator = [UIDynamicAnimator new];
    
    UIGravityBehavior *gravity = [[UIGravityBehavior alloc] initWithItems:@[self.ball]];
    [self.animator addBehavior:gravity];
//    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
}


- (void) paddle:(Paddle *)paddle didTryToPanWithOffset:(CGPoint)offset {
    CGPoint startingPoint = self.view.frame.origin;
    CGPoint newPoint = CGPointMake(startingPoint.x + offset.x, self.paddle1Y);
    
    CGRect potentialNewPaddleFrame = CGRectMake(newPoint.x, newPoint.y, CGRectGetMaxX(self.view.bounds) / 3, self.paddle1Y);
    
    if(CGRectContainsRect(self.view.bounds, potentialNewPaddleFrame)) {
        paddle.frame = potentialNewPaddleFrame;
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
