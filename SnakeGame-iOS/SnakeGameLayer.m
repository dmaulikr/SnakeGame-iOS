//
//  SnakeGameLayer.m
//  SnakeGame-iOS
//
//  Created by Dilip Muthukrishnan on 13-05-14.
//  Copyright __MyCompanyName__ 2013. All rights reserved.
//


// Import the interfaces
#import "SnakeGameLayer.h"

// HelloWorldLayer implementation
@implementation SnakeGameLayer

+(CCScene *) scene
{
	// 'scene' is an autorelease object.
	CCScene *scene = [CCScene node];
	
	// 'layer' is an autorelease object.
	SnakeGameLayer *layer = [SnakeGameLayer node];
	
	// add layer as a child to scene
	[scene addChild: layer];
	
	// return the scene
	return scene;
}

// on "init" you need to initialize your instance
-(id) init
{
	// always call "super" init
	// Apple recommends to re-assign "self" with the "super" return value
	if( (self=[super initWithColor:ccc4(255, 255, 255, 255)])) {
		
		
	}
	return self;
}

- (void) drawGrid
{
    // Tell OpenGL which color to use
    glColor4f(0.3, 0.3, 0.3, 1.0);
    for (int i = 0; i < 16; i++)
    {
        float x = 20 * i;
        ccDrawLine(CGPointMake(x, 0.0), CGPointMake(x, 480.0));
    }
    for (int j = 0; j < 24; j++)
    {
        float y = 20 * j;
        ccDrawLine(CGPointMake(0.0, y), CGPointMake(320.0, y));
    }
}

- (void) drawSnake
{
    // Tell OpenGL which color to use
    glColor4f(1.0, 1.0, 0.0, 1.0);
    
}

// Drawing the graph and the axes
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
    [self drawGrid];
    [self drawSnake];
    // Tell OpenGL to reset the color (to avoid scene transition tint effect)
    glColor4f(1.0, 1.0, 1.0, 1.0);
    // Tell OpenGL that you have finished drawing
    glDisable(GL_LINE_SMOOTH);
}

// on "dealloc" you need to release all your retained objects
- (void) dealloc
{
	// in case you have something to dealloc, do it in this method
	// in this particular example nothing needs to be released.
	// cocos2d will automatically release all the children (Label)
	
	// don't forget to call "super dealloc"
	[super dealloc];
}
@end
