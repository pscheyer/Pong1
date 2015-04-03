//
//  Paddle.h
//  Pong1
//
//  Created by Peter Scheyer on 4/3/15.
//  Copyright (c) 2015 Peter Scheyer. All rights reserved.
//

#import <UIKit/UIKit.h>

@class Paddle;

@protocol PaddleDelegate <NSObject>


@optional

- (void) paddle:(Paddle *)paddle;
- (void) paddle:(Paddle *)paddle didTryToPanWithOffset:(CGPoint)offset;

@end

@interface Paddle : UIView

@property (nonatomic, weak) id <PaddleDelegate> delegate;



@end
