//
//  Ball.m
//  Pong1
//
//  Created by Peter Scheyer on 4/7/15.
//  Copyright (c) 2015 Peter Scheyer. All rights reserved.
//

#import "Ball.h"

@interface Ball () {
    CGPoint ballCenterPast;
}

@property CGPoint ballCenter;
@property NSMutableArray *ballCenters;
//@property CGPoint ballCenterPast;

@end


@implementation Ball

-(void) viewDidLoad{
//       NSTimer *ballPresenceTimer = [NSTimer scheduledTimerWithTimeInterval:.1 invocation:alertAIPaddle repeats:YES];
//    
//
//    self.ballCenter = self.center;
//    self.ballCenters = [[NSMutableArray alloc] init];
//    if (self.ballCenters.count < 10) {
//        [self.ballCenters addObject:[NSValue valueWithCGPoint:self.center]];
//    } else {
//        NSValue *val = [self.ballCenters objectAtIndex:0];
//        ballCenterPast = [val CGPointValue];
//        [self.ballCenters removeObject:0];
//        
//        NSLog(@"Current Ball Center: %@", [self.ballCenters objectAtIndex:9]);
//        NSLog(@"Ball Center Sent to AI Paddle: %@", [self.ballCenters objectAtIndex:0]);
//    }
//
//    NSLog(@"Ball Counter: %lu", (unsigned long)self.ballCenters.count);
}

//- (void) alertAIPaddle {
//    self.ballCenter = self.center;
//}

//- (CGPoint) pointBallCenterPast{
//    return self.ballCenterPast;
//}


@end
