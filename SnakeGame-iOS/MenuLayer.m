//
//  MenuLayer.m
//  SnakeGame-iOS
//
//  Created by Dilip Muthukrishnan on 13-12-22.
//  Copyright 2013 __MyCompanyName__. All rights reserved.
//

#import "MenuLayer.h"


@implementation MenuLayer

+(CCScene *) scene
{
	CCScene *scene = [CCScene node];
	MenuLayer *layer = [MenuLayer node];
	[scene addChild: layer];
	return scene;
}

-(id) init
{
	if( (self=[super init]) )
    {
        [[SimpleAudioEngine sharedEngine] setBackgroundMusicVolume:0.2f];
        [[SimpleAudioEngine sharedEngine] setEffectsVolume:0.2f];
        bg = [CCSprite spriteWithFile:@"background.jpg"];
        bg.position = ccp(160.0, 240.0);
        [self addChild:bg];
        playgame = [CCMenuItemImage itemFromNormalImage:@"playgame.png" selectedImage:@"playgame.png" target:self selector:@selector(playGameSelected:)];
        playgame.position = ccp(160.0, 315.0);
        highscores = [CCMenuItemImage itemFromNormalImage:@"highscores.png" selectedImage:@"highscores.png" target:self selector:@selector(highScoresSelected:)];
        highscores.position = ccp(160.0, 240.0);
        tutorial = [CCMenuItemImage itemFromNormalImage:@"tutorial.png" selectedImage:@"tutorial.png" target:self selector:@selector(tutorialSelected:)];
        tutorial.position = ccp(160.0, 165.0);
        easy = [CCMenuItemImage itemFromNormalImage:@"easy.png" selectedImage:@"easy.png" target:self selector:@selector(easySelected:)];
        easy.position = ccp(-160.0, 315.0);
        normal = [CCMenuItemImage itemFromNormalImage:@"normal.png" selectedImage:@"normal.png" target:self selector:@selector(normalSelected:)];
        normal.position = ccp(-160.0, 240.0);
        hard = [CCMenuItemImage itemFromNormalImage:@"hard.png" selectedImage:@"hard.png" target:self selector:@selector(hardSelected:)];
        hard.position = ccp(-160.0, 165.0);
        CCMenu *menu = [CCMenu menuWithItems:playgame, highscores, tutorial, easy, normal, hard, nil];
        menu.position = CGPointZero;
        [self addChild:menu];
    }
    return self;
}

-(void) playGameSelected:(id)sender
{
    [[SimpleAudioEngine sharedEngine] playEffect:@"button.wav"];
    playgame.position = ccp(playgame.position.x+320.0, playgame.position.y);
    highscores.position = ccp(highscores.position.x+320.0, highscores.position.y);
    tutorial.position = ccp(tutorial.position.x+320.0, tutorial.position.y);
    easy.position = ccp(easy.position.x+320.0, easy.position.y);
    normal.position = ccp(normal.position.x+320.0, normal.position.y);
    hard.position = ccp(hard.position.x+320.0, hard.position.y);
}

-(void) highScoresSelected:(id)sender
{
    
}

-(void) tutorialSelected:(id)sender
{
    
}

-(void) easySelected:(id)sender
{
    [[SimpleAudioEngine sharedEngine] playEffect:@"button.wav"];
    [[CCDirector sharedDirector] replaceScene:[CCTransitionCrossFade transitionWithDuration:1.0 scene:[SnakeGameLayer sceneWithDifficulty:EASY]]];
}

-(void) normalSelected:(id)sender
{
    [[SimpleAudioEngine sharedEngine] playEffect:@"button.wav"];
    [[CCDirector sharedDirector] replaceScene:[CCTransitionCrossFade transitionWithDuration:1.0 scene:[SnakeGameLayer sceneWithDifficulty:NORMAL]]];
}

-(void) hardSelected:(id)sender
{
    [[SimpleAudioEngine sharedEngine] playEffect:@"button.wav"];
    [[CCDirector sharedDirector] replaceScene:[CCTransitionCrossFade transitionWithDuration:1.0 scene:[SnakeGameLayer sceneWithDifficulty:HARD]]];
}

@end
