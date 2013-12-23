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
        playgame.position = ccp(160.0, 240.0);
        CCMenu *menu = [CCMenu menuWithItems:playgame, nil];
        menu.position = CGPointZero;
        [self addChild:menu];
    }
    return self;
}

-(void) playGameSelected:(id)sender
{
    [[SimpleAudioEngine sharedEngine] playEffect:@"button.wav"];
    [[CCDirector sharedDirector] pushScene:[CCTransitionCrossFade transitionWithDuration:1.0 scene:[SnakeGameLayer scene]]];
}

@end
