//
//  SPGAudioPlayer.h
//  Fix The Leaks
//
//  Created by Kostya Teterin on 20.05.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "Sparrow.h"
#import "AudioPlayer.h"

#define SP_EVENT_GAUDIO_DONE @"sparrowGAudioDone"
#define SP_EVENT_GAUDIO_NEXT_SOUND @"sparrowGAudioNextFragment"

@interface SPGAudioPlayer : SPEventDispatcher {
    AudioPlayer *player;
    float volume;
}
@property (nonatomic, assign) float volume;

// Manage audio queue

- (void)addSoundFromFile:(NSString*)filename;
- (void)addSoundFromFile:(NSString*)filename loop:(int)loop;

- (void)clearQueue;

// Control player
- (void)playQueue;
- (void)stop;

- (void)pause;

- (void)breakLoop;

- (bool)isPlaying;
@end
