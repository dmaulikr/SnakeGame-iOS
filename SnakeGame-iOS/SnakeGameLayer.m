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
        bg = [CCSprite spriteWithFile:@"greybg.jpg"];
        bg.position = ccp(160.0, 240.0);
        [self addChild:bg];
        item = [CCSprite spriteWithFile:@"egg.png"];
        [self addChild:item];
        CustomDrawNode *node = [[CustomDrawNode alloc] initWithGame:game];
        node.position = ccp(0.0, 0.0);
        [self addChild:node];
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
        [game resetGame];
        game.paused = YES;
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
        [game spawnSnakeFromBoundary];
    }
    else
    {
        [game resetGame];
    }
    pauseButton.selectedIndex = 0;
}

// This is the main engine that drives the game animation
- (void) update:(ccTime)t
{
    if (!game.paused)
    {
        [game updateGameState];
    }
}

// Convenience method for updating labels
- (void) updateLabels
{
    levelLabel.string = [NSString stringWithFormat:@"Level %i", game.level];
    pointsLabel.string = [NSString stringWithFormat:@"%i points", game.points];
    livesLabel.string = [NSString stringWithFormat:@"%i lives", game.lives];
}

// Convenience method for updating the background color
- (void) updateBackground
{
    // Use greyscale if the game has been paused.
    if (game.paused)
    {
        bg.color = ccc3(102, 102, 102);
    }
    // Use one of the pre-loaded background colors.
    else
    {
        GLubyte red = (GLubyte) ((bgcolors[(game.level-1) % 6][0] + 0.4) * 255);
        GLubyte green = (GLubyte) ((bgcolors[(game.level-1) % 6][1] + 0.4) * 255);
        GLubyte blue = (GLubyte) ((bgcolors[(game.level-1) % 6][2] + 0.4) * 255);
        bg.color = ccc3(red, green, blue);
    }
}

// Convenience method for updating the locations of the items
- (void) updateItems
{
    item.position = ccp(game.item.x + 12.0, game.item.y - 10.0);
    if (game.paused)
    {
        item.color = ccc3(140, 140, 140);
    }
    else
    {
        item.color = ccc3(255, 255, 255);
    }
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

- (void)ccTouchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    // Choose one of the touches to work with
    UITouch *touch = [touches anyObject];
    CGPoint location = [self convertTouchToNodeSpace:touch];
    // Discard any touches that occur on the boundaries
    if (location.x < 20.0 || location.x > 300.0 || location.y < 20.0 || location.y > 440.0)
    {
        return;
    }
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
