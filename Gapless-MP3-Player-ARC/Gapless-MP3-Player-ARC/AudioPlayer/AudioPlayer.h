//
//  AudioPlayer.h
//  Gapless-MP3-Player-ARC
//
//  Created by Kostya Teterin on 8/24/13.
//  Copyright (c) 2013 Kostya Teterin. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreFoundation/CoreFoundation.h>
#import <AudioToolbox/AudioToolbox.h>

#import "AudioPlayerUtilities.h"
#import "AudioSound.h"
#import <OpenAL/al.h>
#import <OpenAL/alc.h>

#define AUDIO_PLAYER_EVENT_SOUND_DONE @"eventAudioPlayerSoundDone"]

// There are some limitations on sound that should be played in a queue:
//    - They should have the same format
//    - Their internal structure should be the same

@interface AudioPlayer : NSObject {
    SoundQueue *soundQueue;
    NSMutableArray *sounds;
    bool isPaused;
    float volume;
    
    AudioQueueRef queue;
    
    // Fade parameters
    NSTimer *mFadeTimer;
    float mFadeSVol, mFadeEVol, mFadeSeconds;
    NSTimeInterval mTimestamp;
    float mMasterVolume;
}
@property (nonatomic, assign) float volume;
@property (nonatomic, readonly) bool isPaused;

// Create queue
+ (AudioPlayer*)defaultPlayer;

// Manage audio queue

- (void)addSoundFromFile:(NSString*)filename;
- (void)addSoundFromFile:(NSString*)filename loop:(int)loop;

// You can create AudioSound by yourself, but the player will not manage their release. It will be up to you.
- (void)addSound:(AudioSound*)sound;
- (void)addSound:(AudioSound*)sound loop:(int)loop;

- (void)clearQueue;

// Control player
- (void)playQueue;
- (void)stop;

- (void)pause;
- (void)resume;

- (void)breakLoop;

// Get player state
- (int)currentItemNumber;
- (bool)isPlaying;

// Change sound volume over time
- (void)fadeFrom:(float)s_vol to:(float)e_vol duration:(float)seconds;
- (void)fadeTo:(float)e_vol duration:(float)seconds;

- (void)setMasterVolume:(float)_volume;
- (float)getMasterVolume;
@end
