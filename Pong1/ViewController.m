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
@property (nonatomic, assign, readwrite) id<UIDynamicAnimatorDelegate> dynamicAnimatorDelegate;
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

@property UILabel *player1ScoreLabel;
@property UILabel *aiPlayerScoreLabel;
@property CGFloat player1Score;
@property CGFloat aiPlayerScore;

@property (nonatomic, strong) UIButton *resetGameButton;

@property NSTimer *ballTimer;
@property NSTimer *scoreAndNewGameTimer;


@property (nonatomic,strong) UICollisionBehavior *collider;
@property (nonatomic, strong) UIPushBehavior *pusher;
@property (nonatomic, assign, readwrite) id<UICollisionBehaviorDelegate> collisionDelegate;





@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self allViewDidLoadExceptSuper];
}

-(void) allViewDidLoadExceptSuper {
    self.animator = [[UIDynamicAnimator alloc] initWithReferenceView:self.view];\
    self.animator.delegate = self.dynamicAnimatorDelegate;
    
    [self ballGenerator];
    [self scoreLabelGenerator];
    
    UIBezierPath *centerLine = [UIBezierPath bezierPath];
    [[UIColor blackColor] setStroke];
    
    [centerLine moveToPoint:CGPointMake(0.0, CGRectGetMaxY(self.view.frame) / 2)];
    [centerLine addLineToPoint:CGPointMake(CGRectGetMaxX(self.view.frame), CGRectGetMaxY(self.view.frame) / 2)];
    [centerLine closePath];
    
    
    CGFloat paddle1Y = 7 * CGRectGetMaxY(self.view.bounds) / 8;
    CGFloat paddle2Y = CGRectGetMaxY(self.view.bounds) / 8;
    
    self.paddle1 = [[Paddle alloc] init];
    self.paddle2 = [[Paddle alloc] init];
    
    
    self.paddle1.frame = CGRectMake(CGRectGetMaxX(self.view.bounds) / 2 - (CGRectGetMaxX(self.view.bounds) / 3) / 2, paddle1Y, CGRectGetMaxX(self.view.bounds) / 4, CGRectGetMaxY(self.view.bounds) / 16);
    [self.view addSubview:self.paddle1];
    self.paddle1.delegate = self;
    
    self.paddle2.frame = CGRectMake(CGRectGetMaxX(self.view.bounds) / 2 - (CGRectGetMaxX(self.view.bounds) / 3) / 2, paddle2Y, CGRectGetMaxX(self.view.bounds) / 4, CGRectGetMaxY(self.view.bounds) / 16);
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
    self.pusher.pushDirection = CGVectorMake(0.0, -0.75);
    self.pusher.active = YES;
    [self.animator addBehavior:self.pusher];
    
    //push is instantaneous, will only happen once
    
    
    
    
    // Do any additional setup after loading the view, typically from a nib.
    //
    _ballTimer = [NSTimer scheduledTimerWithTimeInterval:.2 target:self selector:@selector(reportBallPosition) userInfo:nil repeats:YES];
    
    _scoreAndNewGameTimer = [NSTimer scheduledTimerWithTimeInterval:.01 target:self selector:@selector(updateScoreAndNewGame) userInfo:nil repeats:YES];
    
//    _existentialTimer = [NSTimer scheduledTimerWithTimeInterval:10 target:self selector:@selector(existentialTimerMethod) userInfo:nil repeats:YES];
    
    _resetGameButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [_resetGameButton addTarget:self action:@selector(resetGameButtonPressed) forControlEvents:UIControlEventTouchUpInside];
    [_resetGameButton setTitle:@"Again?" forState:UIControlStateNormal];
    _resetGameButton.frame = CGRectMake(self.paddle1.frame.origin.x, self.paddle1.frame.origin.y, self.paddle1.bounds.size.width, self.paddle1.bounds.size.height);
}

#pragma mark - Ball Methods

- (void) ballGenerator {
    self.ball = [[Ball alloc] initWithFrame:CGRectMake(100,80,30,30)];
    self.ball.backgroundColor = [UIColor redColor];
    [self.view addSubview:self.ball];
}

#pragma mark - Paddle Methods incl AI Paddle w/ReportBallPosition

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

-(void) reportBallPosition {
    self.ballCenter = self.ball.center;
    self.ballCenters = [[NSMutableArray alloc] init];
    //    if (self.ballCenters.count < 10) {
    [self.ballCenters addObject:[NSValue valueWithCGPoint:self.ball.center]];
    //    } else {
    NSValue *val = [self.ballCenters objectAtIndex:0];
    self.ballCenterPast = [val CGPointValue];
    //        [self.ballCenters removeObject:0];
    
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

#pragma mark - Scoring and Pausing and NewGame functions

- (void) updateScoreAndNewGame{
    CGFloat p1PaddleY = CGRectGetMaxY(self.paddle1.frame);
    CGFloat aiPaddleY = CGRectGetMaxY(self.paddle2.frame);
    CGFloat ballCenterY = CGRectGetMaxY(self.ball.frame);
    if(ballCenterY != 0) {
        if (ballCenterY > p1PaddleY - 1) {
            _aiPlayerScore++;
            [self.animator removeAllBehaviors];
            [self.aiPlayerScoreLabel removeFromSuperview];
            [self scoreLabelGenerator];
            [self.view addSubview:_resetGameButton];
            [_scoreAndNewGameTimer invalidate];
        } else if (ballCenterY < aiPaddleY + 1) {
            _player1Score++;
            [self.animator removeAllBehaviors];
            [self.player1ScoreLabel removeFromSuperview];
            [self scoreLabelGenerator];
            [self.view addSubview:_resetGameButton];
            [_scoreAndNewGameTimer invalidate];
        }
    }
    //    _player1Score = _player1Score;
    //    _aiPlayerScore = _aiPlayerScore;
    
    [self.animator updateItemUsingCurrentState:self.ball];
    
    NSLog(@"Player1 Score: %f, AI Score: %f", _player1Score, _aiPlayerScore);
    
}


- (void) scoreLabelGenerator {
    
    UIView *centerLine = [[UIView alloc] initWithFrame:CGRectMake(0, self.view.bounds.size.height / 2, self.view.bounds.size.width, 1)];
    centerLine.backgroundColor = [UIColor blackColor];
    [self.view addSubview:centerLine];
    [self.view sendSubviewToBack:centerLine];
    
    CGFloat centerHeight = self.view.bounds.size.height / 2;
    
    _player1ScoreLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, centerHeight + 10, 100, 100)];
    _player1ScoreLabel.text = [[NSString alloc]initWithFormat:@"%.f",_player1Score];
    
    _aiPlayerScoreLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, centerHeight - 100, 100, 100)];
    _aiPlayerScoreLabel.text = [[NSString alloc]initWithFormat:@"%.f",_aiPlayerScore];
    
    
    [self.view addSubview:_player1ScoreLabel];
    [self.view addSubview:_aiPlayerScoreLabel];
    
    
}

-(void) resetGameButtonPressed{
    NSArray *viewsToRemove = [self.view subviews];
    for (UIView *v in viewsToRemove){
        [v removeFromSuperview];
    }
    [self allViewDidLoadExceptSuper];
}

- (void) existentialTimerMethod {
    
}

#pragma mark - Collision Behaviors

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
