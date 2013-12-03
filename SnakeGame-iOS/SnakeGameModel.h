//
//  SnakeGameModel.h
//  SnakeGame-iOS
//
//  Created by Dilip Muthukrishnan on 13-11-25.
//  Copyright 2013 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"
#import "SimpleAudioEngine.h"

typedef enum directionTypes
{
    FORWARD,
    BACKWARD,
    UPWARD,
    DOWNWARD
    
} Direction;

@protocol SnakeGameDelegate

- (void) unschedule:(SEL)selector;
- (void) schedule:(SEL)selector interval:(ccTime)interval;
- (void) updateLabels;
- (void) displayAlertWithMessage:(NSString *)message;

@end

@interface SnakeGameModel : NSObject
{
    id<SnakeGameDelegate> _view;
    CGPoint snake[350];
}

@property (nonatomic, assign) int level;
@property (nonatomic, assign) int points;
@property (nonatomic, assign) float speed;
@property (nonatomic, assign) CGPoint startPoint;
@property (nonatomic, assign) CGPoint item;
@property (nonatomic, assign) int lengthOfSnake;
@property (nonatomic, assign) Direction direction;
@property (nonatomic, assign) BOOL paused;

- (id) initWithView:(id)layer;
- (void) resetGame;
- (void) setSpeed:(float)s;
- (CGPoint) getSnakePieceAtIndex:(int)i;
- (void) initializeSnakeArray;
- (void) createItem;
- (void) updateSnakeArray;
- (void) updateDirectionWithTouch:(CGPoint)location;
- (void) updateGameState;

@end
