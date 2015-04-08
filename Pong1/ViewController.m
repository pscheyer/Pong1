//
//  ViewController.m
//  Pong1
//
//  Created by Peter Scheyer on 4/2/15.
//  Copyright (c) 2015 Peter Scheyer. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ViewController.h"
#import "Paddle.h"
#import "Ball.h"

@interface ViewController () <PaddleDelegate>
@property (nonatomic, strong) UIDynamicAnimator *animator;
@property (nonatomic, strong) Ball *ball;
@property (nonatomic, strong) Paddle *paddle1;
@property (nonatomic, strong) Paddle *paddle2;

@property CGPoint paddle1Center;
@property CGFloat paddle1Y;
@property CGPoint paddle2Center;
@property CGFloat paddle2Y;
@property CGFloat paddleDensity;


@property CGPoint ballCenterPast;
@property CGPoint ballCenter;
@property NSMutableArray *ballCenters;
@property int counter;
@property CGPoint aiPaddleCenter;


@property (nonatomic,strong) UICollisionBehavior *collider;
@property (nonatomic, strong) UIPushBehavior *pusher;
@property (nonatomic, assign, readwrite) id<UICollisionBehaviorDelegate> collisionDelegate;



@end

@implementation ViewController

- (void)viewDidLoad {
    self.animator = [[UIDynamicAnimator alloc] initWithReferenceView:self.view];
    
    [self ballGenerator];
    
    UIBezierPath *centerLine = [UIBezierPath bezierPath];
    [[UIColor blackColor] setStroke];
    
    [centerLine moveToPoint:CGPointMake(0.0, CGRectGetMaxY(self.view.frame) / 2)];
    [centerLine addLineToPoint:CGPointMake(CGRectGetMaxX(self.view.frame), CGRectGetMaxY(self.view.frame) / 2)];
    [centerLine closePath];
    
    
    CGFloat paddle1Y = 7 * CGRectGetMaxY(self.view.bounds) / 8;
    CGFloat paddle2Y = CGRectGetMaxY(self.view.bounds) / 8;
    
    self.paddle1 = [[Paddle alloc] init];
    self.paddle2 = [[Paddle alloc] init];
    
    
    self.paddle1.frame = CGRectMake(CGRectGetMaxX(self.view.bounds) / 2 - (CGRectGetMaxX(self.view.bounds) / 3) / 2, paddle1Y, CGRectGetMaxX(self.view.bounds) / 3, CGRectGetMaxY(self.view.bounds) / 16);
    [self.view addSubview:self.paddle1];
    self.paddle1.delegate = self;
    
    self.paddle2.frame = CGRectMake(CGRectGetMaxX(self.view.bounds) / 2 - (CGRectGetMaxX(self.view.bounds) / 3) / 2, paddle2Y, CGRectGetMaxX(self.view.bounds) / 3, CGRectGetMaxY(self.view.bounds) / 16);
    [self.view addSubview:self.paddle2];
    self.paddle2.delegate = self;
    
    //adding dynamic properties to paddles
    UIDynamicItemBehavior *paddleDynamicProperties = [[UIDynamicItemBehavior alloc] initWithItems:@[self.paddle1, self.paddle2]];
    paddleDynamicProperties.density = 10000.0f;
    paddleDynamicProperties.allowsRotation = NO;
    [self.animator addBehavior:paddleDynamicProperties];
    
    
    //collision behaviors
    
    
    self.collider = [[UICollisionBehavior alloc] initWithItems:@[self.paddle1, self.paddle2, self.ball]];
    self.collider.collisionDelegate = self.collisionDelegate;
    self.collider.collisionMode = UICollisionBehaviorModeEverything;
    self.collider.translatesReferenceBoundsIntoBoundary = YES;
    
    NSLog(@"%hhd",self.collider.translatesReferenceBoundsIntoBoundary);
    
    [self.animator addBehavior:self.collider];
    
    //adding dynamic properties to ball
    UIDynamicItemBehavior *ballDynamicProperties = [[UIDynamicItemBehavior alloc] initWithItems:@[self.ball]];
    ballDynamicProperties.elasticity = 1.0;
    ballDynamicProperties.friction = 0.0;
    ballDynamicProperties.resistance = 0.0;
    [self.animator addBehavior:ballDynamicProperties];
    
    
    //mover for paddle2
    //methodology is: log ball position .1 seconds ago and move to match. Will tweak arbitrary .1 when testing game.
//    [Ball addObserver:self forKeyPath:@"ballCenterPast" options:0 context:nil];
    
    
    //pusher for starting ball
    self.pusher = [[UIPushBehavior alloc] initWithItems:@[self.ball] mode:UIPushBehaviorModeInstantaneous];
    self.pusher.pushDirection = CGVectorMake(0.5, 1.0);
    self.pusher.active = YES;
    
    //push is instantaneous, will only happen once
    
    
    [self.animator addBehavior:self.pusher];
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
//    
    NSTimer *ballTimer = [NSTimer scheduledTimerWithTimeInterval:.1 target:self selector:@selector(reportBallPosition) userInfo:nil repeats:YES];
    
}

- (void) paddle:(Paddle *)paddle didTryToPanWithOffset:(CGPoint)offset {
    CGPoint startingPoint = paddle.frame.origin;
    
    CGPoint newPoint = CGPointMake(startingPoint.x + offset.x, startingPoint.y);
    
    CGRect potentialNewPaddleFrame = CGRectMake(newPoint.x, newPoint.y, CGRectGetWidth(paddle.frame), CGRectGetHeight(paddle.frame));
    
    if(CGRectContainsRect(self.view.bounds, potentialNewPaddleFrame)) {
        paddle.frame = potentialNewPaddleFrame;
    }
    self.paddle1Center = paddle.frame.origin;
    
    [self.animator updateItemUsingCurrentState:self.paddle1];
}

//- (void) paddle:(Paddle *)paddle aiControlledPaddleMove:(CGPoint)offset {
//    CGPoint startingPoint = paddle.frame.origin;
//    CGPoint new
//}

- (void) ballGenerator {
    self.ball = [[Ball alloc] initWithFrame:CGRectMake(100,200,40,40)];
    self.ball.backgroundColor = [UIColor redColor];
    [self.view addSubview:self.ball];
}

-(void) reportBallPosition {
    self.ballCenter = self.ball.center;
    self.ballCenters = [[NSMutableArray alloc] init];
//    if (self.ballCenters.count < 10) {
        [self.ballCenters addObject:[NSValue valueWithCGPoint:self.ball.center]];
//    } else {
        NSValue *val = [self.ballCenters objectAtIndex:0];
        self.ballCenterPast = [val CGPointValue];
//        [self.ballCenters removeObject:0];
    
    CGPoint startingPoint = _paddle2.frame.origin;
    
    CGFloat ballCenterX = self.ballCenterPast.x;
    
    CGRect potentialNewPaddleFrame = CGRectMake(ballCenterX, CGRectGetMaxY(self.view.bounds) / 8, CGRectGetWidth(_paddle2.frame), CGRectGetHeight(_paddle2.frame));
    
    if(CGRectContainsRect(self.view.bounds, potentialNewPaddleFrame)) {
        _paddle2.frame = potentialNewPaddleFrame;
    }
//    self.paddle2.Center = paddle2.frame.origin;
    
    [self.animator updateItemUsingCurrentState:self.paddle2];
    
//        NSLog(@"Current Ball Center: %@", [self.ballCenters objectAtIndex:9]);
        NSLog(@"Ball Center Sent to AI Paddle: %@", [self.ballCenters objectAtIndex:0]);
//    }
    
    NSLog(@"Ball Counter: %lu", (unsigned long)self.ballCenters.count);
}

#pragma mark - Key/Value Observing

- (void)collisionBehavior:(UICollisionBehavior *)behavior beganContactForItem:(id<UIDynamicItem>)item withBoundaryIdentifier:(id<NSCopying>)identifier atPoint:(CGPoint)p{
    
    NSLog(@"Boundary contact occurred - %@", identifier);
    
    //    UIView* view = (UIView*)item;
    self.ball.backgroundColor = [UIColor yellowColor];
    [UIView animateWithDuration:0.3 animations:^{
        self.ball.backgroundColor = [UIColor grayColor];
    }];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
