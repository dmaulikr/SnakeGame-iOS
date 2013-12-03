//
//  SnakeGameModel.m
//  SnakeGame-iOS
//
//  Created by Dilip Muthukrishnan on 13-11-25.
//  Copyright 2013 __MyCompanyName__. All rights reserved.
//

#import "SnakeGameModel.h"

@implementation SnakeGameModel

@synthesize level = _level;
@synthesize points = _points;
@synthesize speed = _speed;
@synthesize startPoint = _startPoint;
@synthesize item = _item;
@synthesize lengthOfSnake = _lengthOfSnake;
@synthesize direction = _direction;
@synthesize paused = _paused;

- (id) initWithView:(id)layer
{
    if (self = [super init])
    {
        _view = layer;
    }
    return self;
}

// Reset the game back to square one
- (void) resetGame
{
    self.level = 1;
    self.points = 0;
    [_view updateLabels];
    _speed = 0.275;
    self.startPoint = CGPointMake(20.0*5.0, 20.0*2.0);
    self.direction = FORWARD;
    self.lengthOfSnake = 4;
    [self initializeSnakeArray];
    [self createItem];
    _paused = YES;
}

// Pauses/continues the game
- (void) setPaused:(BOOL)option
{
    _paused = option;
    if (option)
    {
        [_view unschedule:@selector(refresh:)];
    }
    else
    {
        [_view schedule:@selector(refresh:) interval:_speed];
    }
}

// Change the speed of the snake's motion
- (void) setSpeed:(float)s
{
    _speed = s;
    [_view unschedule:@selector(refresh:)];
    [_view schedule:@selector(refresh:) interval:s];
}

- (CGPoint) getSnakePieceAtIndex:(int)i
{
    return snake[i];
}

// Figure out where to position the snake and then build it there
- (void) initializeSnakeArray
{
    for (int i = 0; i < self.lengthOfSnake; i++)
    {
        snake[i] = CGPointMake(self.startPoint.x-20.0*i, self.startPoint.y);
    }
}

- (void) createItem
{
    CGPoint position;
    BOOL validPosition = NO;
    while (!validPosition)
    {
        int x = arc4random() % 14 + 1;
        int y = arc4random() % 21 + 2;
        position = CGPointMake(20.0 * x, 20.0 * y);
        for (int j = 0; j < self.lengthOfSnake; j++)
        {
            if (position.x == snake[j].x && position.y == snake[j].y)
            {
                break;
            }
            else if (j == self.lengthOfSnake-1)
            {
                self.item = position;
                validPosition = YES;
            }
        }
    }
}

// Moves the snake one tile ahead in the current direction
- (void) updateSnakeArray
{
    for (int i = self.lengthOfSnake-1; i > 0; i--)
    {
        snake[i] = snake[i-1];
    }
    if (self.direction == FORWARD)
    {
        float x = snake[0].x + 20;
        float y = snake[0].y;
        snake[0] = CGPointMake(x, y);
    }
    else if (self.direction == BACKWARD)
    {
        float x = snake[0].x - 20;
        float y = snake[0].y;
        snake[0] = CGPointMake(x, y);
    }
    else if (self.direction == DOWNWARD)
    {
        float x = snake[0].x;
        float y = snake[0].y - 20;
        snake[0] = CGPointMake(x, y);
    }
    else if (self.direction == UPWARD)
    {
        float x = snake[0].x;
        float y = snake[0].y + 20;
        snake[0] = CGPointMake(x, y);
    }
}

// Update direction of snake motion based on touch location
- (void) updateDirectionWithTouch:(CGPoint)location
{
    if (self.direction == FORWARD || self.direction == BACKWARD)
    {
        if (location.y > snake[0].y)
        {
            self.direction = UPWARD;
        }
        else if (location.y < snake[0].y - 20.0)
        {
            self.direction = DOWNWARD;
        }
    }
    else if (self.direction == UPWARD || self.direction == DOWNWARD)
    {
        if (location.x > snake[0].x + 20.0)
        {
            self.direction = FORWARD;
        }
        else if (location.x < snake[0].x)
        {
            self.direction = BACKWARD;
        }
    }
}

// Update the state of the game at this moment
- (void) updateGameState
{
    [self updateSnakeArray];
    if (snake[0].x == 0 || snake[0].x == 300)
    {
        [[SimpleAudioEngine sharedEngine] playEffect:@"gameover.wav"];
        [_view unschedule:@selector(refresh:)];
        [_view displayAlertWithMessage:@"Boundary Reached"];
    }
    else if (snake[0].y == 20 || snake[0].y == 460)
    {
        [[SimpleAudioEngine sharedEngine] playEffect:@"gameover.wav"];
        [_view unschedule:@selector(refresh:)];
        [_view displayAlertWithMessage:@"Boundary Reached"];
    }
    for (int i = 1; i < self.lengthOfSnake; i++)
    {
        if (snake[0].x == snake[i].x && snake[0].y == snake[i].y)
        {
            [[SimpleAudioEngine sharedEngine] playEffect:@"gameover.wav"];
            [_view unschedule:@selector(refresh:)];
            [_view displayAlertWithMessage:@"Self-intersection detected"];
        }
    }
    if (snake[0].x == self.item.x && snake[0].y == self.item.y)
    {
        NSLog(@"Item collected!");
        self.points++;
        if (self.points > 0 && self.points % 5 == 0)
        {
            [[SimpleAudioEngine sharedEngine] playEffect:@"success.wav"];
            self.level++;
            [self setSpeed:self.speed-0.020];
        }
        else
        {
            [[SimpleAudioEngine sharedEngine] playEffect:@"collect.wav"];
        }
        snake[self.lengthOfSnake] = CGPointMake(-20.0, -20.0);
        self.lengthOfSnake++;
        [self createItem];
        [_view updateLabels];
    }
}

@end
