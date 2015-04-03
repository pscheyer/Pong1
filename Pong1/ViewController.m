//
//  ViewController.m
//  Pong1
//
//  Created by Peter Scheyer on 4/2/15.
//  Copyright (c) 2015 Peter Scheyer. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()
@property (nonatomic, strong) UIDynamicAnimator *animator;
@property (nonatomic, strong) UIView *ball;


@end

@implementation ViewController

- (void)viewDidLoad {
    self.ball = [[UIView alloc] initWithFrame:CGRectMake(100,100,40,40)];
    self.ball.backgroundColor = [UIColor redColor];
    [self.view addSubview:self.ball];
    
    self.animator = [UIDynamicAnimator new];
    
    UIGravityBehavior *gravity = [[UIGravityBehavior alloc] initWithItems:@[self.ball]];
    [self.animator addBehavior:gravity];
//    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
