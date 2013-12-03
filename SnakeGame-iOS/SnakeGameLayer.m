//
//  SnakeGameLayer.m
//  SnakeGame-iOS
//
//  Created by Dilip Muthukrishnan on 13-05-14.
//  Copyright __MyCompanyName__ 2013. All rights reserved.
//


// Import the interfaces
#import "SnakeGameLayer.h"

@implementation SnakeGameLayer

+(CCScene *) scene
{
	CCScene *scene = [CCScene node];
	SnakeGameLayer *layer = [SnakeGameLayer node];
	[scene addChild: layer];
	return scene;
}

-(id) init
{
	if( (self=[super init]) )
    {
        [[SimpleAudioEngine sharedEngine] playBackgroundMusic:@"theme.wav"];
        [[SimpleAudioEngine sharedEngine] setBackgroundMusicVolume:0.2f];
        [[SimpleAudioEngine sharedEngine] setEffectsVolume:0.2f];
        [self setIsTouchEnabled:YES];
        alert = [[UIAlertView alloc] initWithTitle:@"Snake Game" message:nil
                                          delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
        game = [[SnakeGameModel alloc] initWithView:self];
        [self drawBrickWall];
        levelLabel = [CCLabelTTF labelWithString:@"Level Unknown" fontName:@"Marker Felt" fontSize:25];
        levelLabel.color = ccBLACK;
        levelLabel.position =  ccp(160.0, 460.0);
        [self addChild:levelLabel];
        pointsLabel = [CCLabelTTF labelWithString:@"Points Unknown" fontName:@"Marker Felt" fontSize:25];
        pointsLabel.color = ccBLUE;
        pointsLabel.position =  ccp(260.0, 460.0);
        [self addChild:pointsLabel];
        NSDictionary *dictionary = [NSDictionary dictionaryWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"config" ofType:@"plist"]];
        NSArray *array = (NSArray *)[dictionary valueForKey:@"bgcolors"];
        for (int i = 0; i < 6; i++)
        {
            NSString *color = (NSString *)[array objectAtIndex:i];
            NSArray *colorComponents = [color componentsSeparatedByString:@","];
            for (int j = 0; j < 4; j++)
            {
                bgcolors[i][j] = [[colorComponents objectAtIndex:j] floatValue];
            }
        }
        [game resetGame];
	}
	return self;
}

- (void) displayAlertWithMessage:(NSString *)message
{
    alert.message = message;
    [alert show];
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    [[SimpleAudioEngine sharedEngine] playEffect:@"button.wav"];
    [game resetGame];
}

- (void) refresh:(ccTime)t
{
    [game updateGameState];
}

- (void) updateLabels
{
    levelLabel.string = [NSString stringWithFormat:@"Level %i", game.level];
    pointsLabel.string = [NSString stringWithFormat:@"%i", game.points];
}

- (void) drawBackground
{
    float red = bgcolors[(game.level-1) % 6][0];
    float green = bgcolors[(game.level-1) % 6][1];
    float blue = bgcolors[(game.level-1) % 6][2];
    glColor4f(red, green, blue, 1.0);
    CGPoint start = CGPointMake(0.0, 480.0);
    CGPoint end = CGPointMake(320.0, 0.0);
    ccDrawSolidRect(start, end);
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
    for (int i = 0; i < game.lengthOfSnake; i++)
    {
        CGPoint start = [game getSnakePieceAtIndex:i];
        CGPoint end = CGPointMake(start.x + 20, start.y - 20);
        // Generates gradient color for snake tail
        glColor4f((game.lengthOfSnake-i)/(float)game.lengthOfSnake, 1.0, 0.0, 1.0);
        ccDrawSolidRect(start, end);
    }
}

- (void) drawItem
{
    CGPoint start = CGPointMake(game.item.x, game.item.y);
    CGPoint end = CGPointMake(game.item.x + 20, game.item.y - 20);
    glColor4f(1.0, 0.0, 0.0, 1.0);
    ccDrawSolidRect(start, end);
    glColor4f(1.0, 1.0, 1.0, 1.0);
    ccDrawRect(start, end);
}

- (void) drawBrickWall
{
    for (int j = 1; j < 25; j++)
    {
        for (int i = 0; i < 16; i++)
        {
            if (j == 1 || j > 22 || ((j > 0 && j < 23) && (i == 0 || i == 15)))
            {
                CCSprite *stone = [CCSprite spriteWithFile:@"stone.gif"];
                stone.position = CGPointMake(20*i + 10, 20*j - 10);
                [self addChild:stone];
            }
        }
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
    [self drawSnake];
    [self drawGrid];
    [self drawItem];
    // Tell OpenGL to reset the color (to avoid scene transition tint effect)
    glColor4f(1.0, 1.0, 1.0, 1.0);
    // Tell OpenGL that you have finished drawing
    glDisable(GL_LINE_SMOOTH);
}

- (void)ccTouchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    if (game.paused)
    {
        game.paused = NO;
        return;
    }
    // Choose one of the touches to work with
    UITouch *touch = [touches anyObject];
    CGPoint location = [self convertTouchToNodeSpace:touch];
    [game updateDirectionWithTouch:location];
}

- (void) dealloc
{
	[super dealloc];
}
@end
