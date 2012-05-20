//
//  SPGAudioPlayer.m
//  Gapless MP3 Player wrapper for Sparrow Framework
//
//  Created by Kostya Teterin on 20.05.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "SPGAudioPlayer.h"

@implementation SPGAudioPlayer

@synthesize volume;

- (id)init
{
    [super init];
    player = [AudioPlayer defaultPlayer];
    volume = 1;
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onAudioPlayerDone) name:APEVENT_QUEUE_DONE object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onAudioPlayerNextFragment) name:APEVENT_QUEUE_DONE object:nil];

    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onInterruptionBegan) name:SP_NOTIFICATION_AUDIO_INTERRUPTION_BEGAN object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onInterruptionEnd) name:SP_NOTIFICATION_AUDIO_INTERRUPTION_ENDED object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onMasterVolumeChanged) name:SP_NOTIFICATION_MASTER_VOLUME_CHANGED object:nil];
    return self;
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [super dealloc];
}


// Manage audio queue

- (void)addSoundFromFile:(NSString*)filename
{
    [player addSoundFromFile:filename];
}
- (void)addSoundFromFile:(NSString*)filename loop:(int)loop
{
    [player addSoundFromFile:filename loop:loop];
}

- (void)clearQueue
{
    if([player isPlaying]) [player stop];
    [player clearQueue];
}

// Control player
- (void)playQueue
{
    if([player isPaused])
        [player resume];
    else
    {
        [player setVolume:volume];
        [player playQueue];
    }
}
- (void)stop
{
    [player stop];
}

- (void)pause
{
    [player pause];
}

- (void)breakLoop
{
    [player breakLoop];
}

// Events
- (void)onAudioPlayerDone
{
    [self dispatchEvent:[SPEvent eventWithType:SP_EVENT_GAUDIO_DONE]];
}
- (void)onAudioPlayerNextFragment
{
    [self dispatchEvent:[SPEvent eventWithType:SP_EVENT_GAUDIO_NEXT_SOUND]];
}
- (void)onMasterVolumeChanged
{
    [self setVolume:volume];
}
- (void)onInterruptionBegan
{
    [player pause];
}
- (void)onInterruptionEnd
{
    [player resume];
}
- (void)setVolume:(float)vol
{
    NSLog(@"Volume set");
    self.volume = vol;
    [player setVolume: vol * [SPAudioEngine masterVolume]];
}

@end
