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
	if( (self=[super init]) )
    {
        [[SimpleAudioEngine sharedEngine] playBackgroundMusic:@"theme.wav"];
        [self resetGame];
        [self setIsTouchEnabled:YES];
        alert = [[UIAlertView alloc] initWithTitle:@"Snake Game" message:nil
                                          delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
	}
	return self;
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    [[SimpleAudioEngine sharedEngine] playEffect:@"button.wav"];
    [self resetGame];
}

- (void) resetGame
{
    startX = 20 * 5;
    startY = 20 * 2;
    direction = @"Forward";
    lengthOfSnake = 4;
    numberOfItems = 15;
    [self initializeSnakeArray];
    [self initializeItemsArray];
    [self schedule:@selector(refresh:) interval:0.175];
}

- (void) refresh: (ccTime)t
{
    [self updateSnakeArray];
    if (snake[0].x == -20 || snake[0].x == 320)
    {
        [[SimpleAudioEngine sharedEngine] playEffect:@"gameover.wav"];
        [self unschedule:@selector(refresh:)];
        alert.message = @"Boundary Reached!";
        [alert show];
    }
    else if (snake[0].y == 0 || snake[0].y == 480)
    {
        [[SimpleAudioEngine sharedEngine] playEffect:@"gameover.wav"];
        [self unschedule:@selector(refresh:)];
        alert.message = @"Boundary Reached!";
        [alert show];
    }
    for (int i = 1; i < lengthOfSnake; i++)
    {
        if (snake[0].x == snake[i].x && snake[0].y == snake[i].y)
        {
            [[SimpleAudioEngine sharedEngine] playEffect:@"gameover.wav"];
            [self unschedule:@selector(refresh:)];
            alert.message = @"Self-intersection detected!";
            [alert show];
        }
    }
    for (int i = 0; i < numberOfItems; i++)
    {
        if (snake[0].x == items[i].x && snake[0].y == items[i].y)
        {
            NSLog(@"Item collected!");
            [[SimpleAudioEngine sharedEngine] playEffect:@"collect.wav"];
            snake[lengthOfSnake] = CGPointMake(-20.0, -20.0);
            lengthOfSnake++;
            items[i] = CGPointMake(-20.0, -20.0);
        }
    }
}

- (void) drawBackground
{
    glColor4f(0.0, 0.0, 0.5, 1.0);
    CGPoint startPoint = CGPointMake(0.0, 480.0);
    CGPoint endPoint = CGPointMake(320.0, 0.0);
    ccFilledRect(startPoint, endPoint);
}

- (void) drawGrid
{
    // Tell OpenGL which color to use
    glColor4f(0.5, 0.5, 0.5, 1.0);
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
    for (int i = 0; i < lengthOfSnake; i++)
    {
        CGPoint startPoint = CGPointMake(snake[i].x, snake[i].y);
        CGPoint endPoint = CGPointMake(snake[i].x + 20, snake[i].y - 20);
        ccFilledRect(startPoint, endPoint);
    }
}

- (void) drawItems
{
    glColor4f(1.0, 0.0, 0.0, 1.0);
    for (int i = 0; i < numberOfItems; i++)
    {
        CGPoint startPoint = CGPointMake(items[i].x, items[i].y);
        CGPoint endPoint = CGPointMake(items[i].x + 20, items[i].y - 20);
        ccFilledRect(startPoint, endPoint);
    }
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
    [self drawBackground];
    [self drawGrid];
    [self drawSnake];
    [self drawItems];
    // Tell OpenGL to reset the color (to avoid scene transition tint effect)
    glColor4f(1.0, 1.0, 1.0, 1.0);
    // Tell OpenGL that you have finished drawing
    glDisable(GL_LINE_SMOOTH);
}

- (void) updateSnakeArray
{
    for (int i = lengthOfSnake-1; i > 0; i--)
    {
        snake[i] = snake[i-1];
    }
    if ([direction isEqualToString:@"Forward"])
    {
        float x = snake[0].x+20;
        float y = snake[0].y;
        snake[0] = CGPointMake(x, y);
    }
    else if ([direction isEqualToString:@"Backward"])
    {
        float x = snake[0].x-20;
        float y = snake[0].y;
        snake[0] = CGPointMake(x, y);
    }
    else if ([direction isEqualToString:@"Downward"])
    {
        float x = snake[0].x;
        float y = snake[0].y-20;
        snake[0] = CGPointMake(x, y);
    }
    else if ([direction isEqualToString:@"Upward"])
    {
        float x = snake[0].x;
        float y = snake[0].y+20;
        snake[0] = CGPointMake(x, y);
    }
}

- (void) initializeSnakeArray
{
    for (int i = 0; i < lengthOfSnake; i++)
    {
        snake[i] = CGPointMake(startX-20*i, startY);
    }
}

- (void) initializeItemsArray
{
    for (int i = 0; i < numberOfItems; i++)
    {
        CGPoint position;
        BOOL validPosition = NO;
        while (!validPosition)
        {
            int x = arc4random() % 16;
            int y = arc4random() % 24;
            position = CGPointMake(20.0 * x, 20.0 * y);
            for (int j = 0; j < lengthOfSnake; j++)
            {
                if (position.x == snake[j].x && position.y == snake[j].y)
                {
                    continue;
                }
                else if (j == lengthOfSnake-1)
                {
                    items[i] = position;
                    validPosition = YES;
                }
            }
        }
    }
}

- (void)ccTouchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    
    // Choose one of the touches to work with
    UITouch *touch = [touches anyObject];
    CGPoint location = [self convertTouchToNodeSpace:touch];
    // Update direction of snake motion based on touch location
    if ([direction isEqualToString:@"Forward"] || [direction isEqualToString:@"Backward"])
    {
        if (location.y > snake[0].y)
        {
            direction = @"Upward";
        }
        else if (location.y < snake[0].y - 20.0)
        {
            direction = @"Downward";
        }
    }
    else if ([direction isEqualToString:@"Upward"] || [direction isEqualToString:@"Downward"])
    {
        if (location.x > snake[0].x + 20.0)
        {
            direction = @"Forward";
        }
        else if (location.x < snake[0].x)
        {
            direction = @"Backward";
        }
    }
}

// Using this custom function from the website -> http://www.cocos2d-iphone.org/forum/topic/7511
void ccFilledRect(CGPoint v1, CGPoint v2)
{
	CGPoint poli[]={v1,CGPointMake(v1.x,v2.y),v2,CGPointMake(v2.x,v1.y)};
    
	// Default GL states: GL_TEXTURE_2D, GL_VERTEX_ARRAY, GL_COLOR_ARRAY, GL_TEXTURE_COORD_ARRAY
	// Needed states: GL_VERTEX_ARRAY,
	// Unneeded states: GL_TEXTURE_2D, GL_TEXTURE_COORD_ARRAY, GL_COLOR_ARRAY
	glDisable(GL_TEXTURE_2D);
	glDisableClientState(GL_TEXTURE_COORD_ARRAY);
	glDisableClientState(GL_COLOR_ARRAY);
    
	glVertexPointer(2, GL_FLOAT, 0, poli);
	glDrawArrays(GL_TRIANGLE_FAN, 0, 4);
    
	// restore default state
	glEnableClientState(GL_COLOR_ARRAY);
	glEnableClientState(GL_TEXTURE_COORD_ARRAY);
	glEnable(GL_TEXTURE_2D);
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
