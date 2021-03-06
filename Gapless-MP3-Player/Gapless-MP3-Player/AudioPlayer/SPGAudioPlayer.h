//
//  SPGAudioPlayer.h
//  Fix The Leaks
//
//  Created by Kostya Teterin on 20.05.12.
//  Copyright (c) 2012 Emotion Rays. All rights reserved.
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

// Change volume over time
- (void)fadeFrom:(float)s_vol to:(float)e_vol duration:(float)seconds;
- (void)fadeTo:(float)e_vol duration:(float)seconds;

-(void)setMasterVolume:(float)_volume;
-(float)getMasterVolume;

@end
