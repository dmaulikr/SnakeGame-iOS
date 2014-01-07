//
//  CustomDrawNode.m
//  SnakeGame-iOS
//
//  Created by Dilip Muthukrishnan on 14-01-03.
//  Copyright 2014 __MyCompanyName__. All rights reserved.
//

#import "CustomDrawNode.h"

@implementation CustomDrawNode

- (id) initWithGame:(SnakeGameModel *)g
{
    if (self = [super init])
    {
        game = g;
    }
    return self;
}

// Generates a gradient color for the snake's tail.
- (void) drawSnake
{
    for (int i = 0; i < game.lengthOfSnake; i++)
    {
        CGPoint start = [game getSnakePieceAtIndex:i];
        CGPoint end = ccp(start.x + 20.0, start.y - 20.0);
        // Use greyscale if the game has been paused.
        if (game.paused)
        {
            float greyValue = (game.lengthOfSnake-i)/(float)game.lengthOfSnake;
            glColor4f(greyValue, greyValue, greyValue, 1.0);
        }
        // Use a greenish color
        else
        {
            glColor4f((game.lengthOfSnake-i)/(float)game.lengthOfSnake, 1.0, 0.0, 1.0);
        }
        ccDrawSolidRect(start, end);
    }
}

// Draw's everything!
- (void) draw
{
    // Tell OpenGL that you intend to draw a line segment
    glEnable(GL_LINE_SMOOTH);
    // Determine if retina display is enabled and tell OpenGL to set the line width accordingly
    if (CC_CONTENT_SCALE_FACTOR() == 1.0)
    {
        glLineWidth(1.0f);
    }
    else
    {
        glLineWidth(2.0f);
    }
    [self drawSnake];
    //[self drawSlowDownPill];
    // Tell OpenGL to reset the color (to avoid scene transition tint effect)
    glColor4f(1.0, 1.0, 1.0, 1.0);
    // Tell OpenGL that you have finished drawing
    glDisable(GL_LINE_SMOOTH);
}

@end
