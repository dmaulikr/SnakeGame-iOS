//
//  SnakeGameLayer.m
//  SnakeGame-iOS
//
//  Created by Dilip Muthukrishnan on 13-05-14.
//  Copyright __MyCompanyName__ 2013. All rights reserved.
//


#import "SnakeGameLayer.h"

@implementation SnakeGameLayer

+(CCScene *) sceneWithDifficulty:(Difficulty)difficulty
{
	CCScene *scene = [CCScene node];
	SnakeGameLayer *layer = [[[SnakeGameLayer alloc] initWithDifficulty:difficulty] autorelease];
	[scene addChild: layer];
	return scene;
}

-(id) initWithDifficulty:(Difficulty)difficulty
{
	if( (self=[super init]) )
    {
        [[SimpleAudioEngine sharedEngine] playBackgroundMusic:@"theme.wav"];
        [self setIsTouchEnabled:YES];
        alert = [[UIAlertView alloc] initWithTitle:@"Snake Game" message:nil
                                          delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
        game = [[SnakeGameModel alloc] initWithView:self difficulty:difficulty];
        [self drawBrickWall];
        levelLabel = [CCLabelTTF labelWithString:@"Level Unknown" fontName:@"Marker Felt" fontSize:25];
        levelLabel.color = ccBLACK;
        levelLabel.position =  ccp(160.0, 460.0);
        [self addChild:levelLabel];
        pointsLabel = [CCLabelTTF labelWithString:@"Points Unknown" fontName:@"Marker Felt" fontSize:18];
        pointsLabel.color = ccRED;
        pointsLabel.position =  ccp(260.0, 470.0);
        [self addChild:pointsLabel];
        livesLabel = [CCLabelTTF labelWithString:@"Lives Unknown" fontName:@"Marker Felt" fontSize:18];
        livesLabel.color = ccBLUE;
        livesLabel.position =  ccp(260.0, 450.0);
        [self addChild:livesLabel];
        up = [CCSprite spriteWithFile:@"up.png"];
        up.position = ccp(160.0, 240.0);
        up.scale = 2.0;
        up.visible = NO;
        [self addChild:up];
        down = [CCSprite spriteWithFile:@"down.png"];
        down.position = ccp(160.0, 240.0);
        down.scale = 2.0;
        down.visible = NO;
        [self addChild:down];
        left = [CCSprite spriteWithFile:@"left.png"];
        left.position = ccp(160.0, 240.0);
        left.scale = 2.0;
        left.visible = NO;
        [self addChild:left];
        right = [CCSprite spriteWithFile:@"right.png"];
        right.position = ccp(160.0, 240.0);
        right.scale = 2.0;
        right.visible = NO;
        [self addChild:right];
        pauseon = [CCMenuItemImage itemFromNormalImage:@"play.png" selectedImage:@"play.png"];
        pauseoff = [CCMenuItemImage itemFromNormalImage:@"pause.png" selectedImage:@"pause.png"];
        pauseButton = [CCMenuItemToggle itemWithBlock:^(id sender)
                      {
                          (game.paused = pauseButton.selectedItem == pauseon);
                          if (!game.mute)
                          {
                              [[SimpleAudioEngine sharedEngine] playEffect:@"button.wav"];
                          }
                      }
                                               items:pauseon, pauseoff, nil];
        pauseButton.selectedIndex = 0;
        pauseButton.position = ccp(35, 460);
        muteon = [CCMenuItemImage itemFromNormalImage:@"muteon.png" selectedImage:@"muteon.png"];
        muteoff = [CCMenuItemImage itemFromNormalImage:@"muteoff.png" selectedImage:@"muteoff.png"];
        muteButton = [CCMenuItemToggle itemWithBlock:^(id sender)
                      {
                          if ((game.mute = muteButton.selectedItem == muteon))
                          {
                              [[SimpleAudioEngine sharedEngine] stopAllEffects];
                              [[SimpleAudioEngine sharedEngine] pauseBackgroundMusic];
                          }
                          else
                          {
                              [[SimpleAudioEngine sharedEngine] playEffect:@"button.wav"];
                              [[SimpleAudioEngine sharedEngine] resumeBackgroundMusic];
                          }
                      }
                                               items:muteon, muteoff, nil];
        muteButton.selectedIndex = 1;
        muteButton.scale = 1.10;
        muteButton.position = ccp(75, 460);
        CCMenu *menu = [CCMenu menuWithItems:pauseButton, muteButton, nil];
        menu.position = CGPointZero;
        [self addChild:menu];
        // We need to pre-load a list of background colors from a p-list
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
        game.paused = YES;
        [game resetGame];
	}
	return self;
}

// Convenience method for displaying an alert with a message
- (void) displayAlertWithMessage:(NSString *)message
{
    alert.message = message;
    [alert show];
}

// Wait for the user to dismiss any dialog and then respond to it
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (!game.mute)
    {
        [[SimpleAudioEngine sharedEngine] playEffect:@"button.wav"];
    }
    if (game.lives)
    {
        [game revertToLastSnapshot];
    }
    else
    {
        [game resetGame];
    }
    game.paused = YES;
    pauseButton.selectedIndex = 0;
}

// This is the main engine that drives the game animation
- (void) update:(ccTime)t
{
    [game updateGameState];
}

// Convenience method for updating labels
- (void) updateLabels
{
    levelLabel.string = [NSString stringWithFormat:@"Level %i", game.level];
    pointsLabel.string = [NSString stringWithFormat:@"%i points", game.points];
    livesLabel.string = [NSString stringWithFormat:@"%i lives", game.lives];
}

// Displays/hides the direction arrows if paused/running
- (void) toggleDirectionArrows
{
    if (game.paused)
    {
        switch (game.direction)
        {
            case UPWARD:
                up.visible = YES;
                down.visible = NO;
                right.visible = NO;
                left.visible = NO;
                break;
            case DOWNWARD:
                up.visible = NO;
                down.visible = YES;
                right.visible = NO;
                left.visible = NO;
                break;
            case FORWARD:
                up.visible = NO;
                down.visible = NO;
                right.visible = YES;
                left.visible = NO;
                break;
            case BACKWARD:
                up.visible = NO;
                down.visible = NO;
                right.visible = NO;
                left.visible = YES;
                break;
            default:
                break;
        }
    }
    else
    {
        up.visible = down.visible = right.visible = left.visible = NO;
    }
}

// This is the only way that I know how to implement a timed
// slow down pill.  Ideally, I would have liked to have this
// in the model but that won't respond to Cocos2d schedule calls.
- (void) removeSlowDownPill
{
    game.pill = ccp(-20.0, -20.0);
    [self unschedule:@selector(removeSlowDownPill)];
}

- (void) drawBackground
{
    // Use greyscale if the game has been paused.
    if (game.paused)
    {
       glColor4f(0.1, 0.1, 0.1, 1.0);
    }
    // Use the pre-loaded background colors.
    else
    {
        float red = bgcolors[(game.level-1) % 6][0];
        float green = bgcolors[(game.level-1) % 6][1];
        float blue = bgcolors[(game.level-1) % 6][2];
        glColor4f(red, green, blue, 1.0);
    }
    CGPoint start = ccp(0.0, 480.0);
    CGPoint end = ccp(320.0, 0.0);
    ccDrawSolidRect(start, end);
}

- (void) drawGrid
{
    glColor4f(0.5, 0.5, 0.5, 1.0);
    for (int i = 0; i < 16; i++)
    {
        float x = 20 * i;
        ccDrawLine(ccp(x, 0.0), ccp(x, 480.0));
    }
    for (int j = 0; j < 24; j++)
    {
        float y = 20 * j;
        ccDrawLine(ccp(0.0, y), ccp(320.0, y));
    }
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

- (void) drawItem
{
    CGPoint start = ccp(game.item.x, game.item.y);
    CGPoint end = ccp(game.item.x + 20.0, game.item.y - 20.0);
    // Use greyscale if the game has been paused.
    if (game.paused)
    {
        glColor4f(0.3, 0.3, 0.3, 1.0);
    }
    // Use the red color
    else
    {
        glColor4f(1.0, 0.0, 0.0, 1.0);
    }
    ccDrawSolidRect(start, end);
    glColor4f(1.0, 1.0, 1.0, 1.0);
    ccDrawRect(start, end);
}

- (void) drawSlowDownPill
{
    CGPoint start = ccp(game.pill.x, game.pill.y);
    CGPoint end = ccp(game.pill.x + 20.0, game.pill.y - 20.0);
    // Use the black color
    glColor4f(0.0, 0.0, 0.0, 1.0);
    ccDrawSolidRect(start, end);
    glColor4f(1.0, 1.0, 1.0, 1.0);
    ccDrawRect(start, end);
}

// Draws a barrier around the circumferance of the game area
- (void) drawBrickWall
{
    for (int j = 1; j < 25; j++)
    {
        for (int i = 0; i < 16; i++)
        {
            if (j == 1 || j > 22 || ((j > 0 && j < 23) && (i == 0 || i == 15)))
            {
                CCSprite *stone = [CCSprite spriteWithFile:@"stone.gif"];
                stone.position = ccp(20*i + 10.0, 20*j - 10.0);
                [self addChild:stone];
            }
        }
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
    [self drawBackground];
    [self drawSnake];
    [self drawGrid];
    [self drawItem];
    [self drawSlowDownPill];
    // Tell OpenGL to reset the color (to avoid scene transition tint effect)
    glColor4f(1.0, 1.0, 1.0, 1.0);
    // Tell OpenGL that you have finished drawing
    glDisable(GL_LINE_SMOOTH);
}

- (void)ccTouchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    // Choose one of the touches to work with
    UITouch *touch = [touches anyObject];
    CGPoint location = [self convertTouchToNodeSpace:touch];
    [game updateDirectionWithTouch:location];
    if (game.paused)
    {
        [self toggleDirectionArrows];
    }
}

- (void) dealloc
{
	[super dealloc];
}
@end
