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
    player = [[AudioPlayer alloc] init];
    volume = 1;
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onAudioPlayerDone) name:APEVENT_QUEUE_DONE object:player];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onAudioPlayerNextFragment) name:APEVENT_MOVING_TO_NEXT_SOUND object:player];

    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onInterruptionBegan) name:SP_NOTIFICATION_AUDIO_INTERRUPTION_BEGAN object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onInterruptionEnd) name:SP_NOTIFICATION_AUDIO_INTERRUPTION_ENDED object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onMasterVolumeChanged) name:SP_NOTIFICATION_MASTER_VOLUME_CHANGED object:nil];
    return self;
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [player release];
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
    NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
    [self dispatchEvent:[SPEvent eventWithType:SP_EVENT_GAUDIO_DONE]];
    [pool drain];
}
- (void)onAudioPlayerNextFragment
{
    NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
    [self dispatchEvent:[SPEvent eventWithType:SP_EVENT_GAUDIO_NEXT_SOUND]];
    [pool drain];
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

// Volume control
- (void)setVolume:(float)vol
{
    volume = vol;
    [player setVolume: vol * [SPAudioEngine masterVolume]];
}
- (bool)isPlaying
{
    return [player isPlaying];
}
- (void)fadeFrom:(float)s_vol to:(float)e_vol duration:(float)seconds
{
    [player fadeFrom:s_vol to:e_vol duration:seconds];
}
- (void)fadeTo:(float)e_vol duration:(float)seconds
{
    [player fadeTo:e_vol duration:seconds];
}

-(void)setMasterVolume:(float)_volume
{
    [player setMasterVolume:_volume];
}
-(float)getMasterVolume
{
    return [player getMasterVolume];
}

@end
