//
//  AudioPlayer.m
//  Gapless-MP3-Player
//
//  Created by Kostya Teterin on 17.05.12.
//  Copyright (c) 2012 Emotion Rays Entertainment. All rights reserved.
//

#import "AudioPlayer.h"

@implementation AudioPlayer

/////////////////////////////////////////
//  Create audio player

static AudioPlayer *sharedAudioPlayer = nil;

+ (AudioPlayer *)defaultPlayer
{
    if(sharedAudioPlayer == nil)
    {
        sharedAudioPlayer = [[AudioPlayer alloc] init];
    }
    return sharedAudioPlayer;
}

- (id)init
{
    [super init];
    soundQueue = new SoundQueue;
    soundQueue->currentItem = nil;
    soundQueue->firstItem = nil;
    soundQueue->lastItem = nil;
    soundQueue->currentItem = 0;
    queue = nil;
    
    sounds = [[NSMutableArray alloc] init];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(dispose) name:APEVENT_QUEUE_DONE object:nil];
    return self;
}
- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [self clearQueue];
    [sounds release];
    delete soundQueue;
    [super dealloc];
}

// Manage audio queue
- (void)addSoundFromFile:(NSString*)filename
{
    [self addSoundFromFile:filename loop:0];
}
- (void)addSoundFromFile:(NSString*)filename loop:(int)loop
{
    AudioSound *sound = [[AudioSound alloc] initWithSoundFile:filename];
    [sounds addObject:sound];
    [self addSound:sound loop:loop];
}

- (void)addSound:(AudioSound*)sound;
{
    [self addSound:sound loop:0];
}
- (void)addSound:(AudioSound*)sound loop:(int)loop;
{
    SoundQueueItem *item = new SoundQueueItem;
    item->nextItem = nil;
    item->breakEndlessLoop = NO;
    item->loop = loop;
    item->sound = [sound description];
        
    // Add item to the queue
    if(soundQueue->lastItem == nil)
        soundQueue->firstItem = item;
    else 
        soundQueue->lastItem->nextItem = item;
    soundQueue->lastItem = item;
}
- (void)clearQueue
{
    // Clear sound queue
    if(soundQueue->firstItem)
    {
        SoundQueueItem *currentItem = soundQueue->firstItem, *nextItem;
        do {
            nextItem = currentItem->nextItem;
            delete currentItem;
            currentItem = nextItem;
        } while(currentItem);
        soundQueue->firstItem = nil;
        soundQueue->lastItem = nil;
        soundQueue->currentItem = nil;
    }
    
    // Clear sound objects created from file
    while([sounds count])
    {
        [[sounds lastObject] release];
        [sounds removeLastObject];
    }
}

// Control player
- (void)playQueue
{
    if(queue != nil) return; // Another queue is already playing
    if(soundQueue->firstItem == nil) return; // No sounds in the queue
    
    soundQueue->currentItem = soundQueue->firstItem;
    soundQueue->currentItemNumber = 0;
    
    // Check if all sounds in the queue have the same format and parameters
    AudioStreamBasicDescription *ethalonDesc = &soundQueue->firstItem->sound->dataFormat;
    int n = 1;
    SoundQueueItem *item = soundQueue->firstItem->nextItem;
    while(item)
    {
        AudioStreamBasicDescription *desc = &item->sound->dataFormat;
        bool isNotSame = NO;
        isNotSame |= (desc->mBytesPerFrame != ethalonDesc->mBytesPerFrame);
        isNotSame |= (desc->mBytesPerPacket != ethalonDesc->mBytesPerPacket);
        isNotSame |= (desc->mChannelsPerFrame != ethalonDesc->mChannelsPerFrame);
        isNotSame |= (desc->mFormatFlags != ethalonDesc->mFormatFlags);
        isNotSame |= (desc->mFormatID != ethalonDesc->mFormatID);
        isNotSame |= (desc->mSampleRate != ethalonDesc->mSampleRate);
        isNotSame |= (desc->mFramesPerPacket != ethalonDesc->mFramesPerPacket);
        if(isNotSame)
        {
            NSLog(@"%d sound in the queue is different from the rest. Can't play the queue.", n);
            return;
        }
        ++n;
        item = item->nextItem;
    }
    NSLog(@"All sounds have the same format. Let's play'em");
    
    // Prepare to play

    // Rewind all sounds to the beginning
    item = soundQueue->firstItem;
    while(item)
    {
        item->sound->isDone = false;
        item->sound->packetPosition = 0;
        item->breakEndlessLoop = NO;
        item = item->nextItem;
    }
    
    // Create audio queue for playing
    CheckError(AudioQueueNewOutput(ethalonDesc, AQOutputCallback, soundQueue, NULL, NULL, 0, &queue), "AudioQueueNewOutput failed");
    
    // Add the callback that will determine when sound playing stop
    CheckError(AudioQueueAddPropertyListener(queue, kAudioQueueProperty_IsRunning, AQPropertyListenerProc, nil), "AudioQueueAddPropertyListener failed");
    
    
    // Copy magic cookie from file (it is providing a valuable information for the decoder)
    CopyEncoderCookieToQueue(currentSoundDescription(soundQueue)->playbackFile, queue);
    
    // Allocate bufers and fill them with data by using the callback that is reading portions of file from the disk.
    AudioQueueBufferRef buffers[kNumberPlaybackBuffers];
    int i;
    for(i = 0; i < kNumberPlaybackBuffers; ++i)
    {
        CheckError(AudioQueueAllocateBuffer(queue, currentSoundDescription(soundQueue)->bufferByteSize, &buffers[i]), "AudioQueueAllocateBuffer failed");
        AQOutputCallback(soundQueue, queue, buffers[i]);
        if(currentSoundDescription(soundQueue)->isDone) break;
    }
    
    // Play
    CheckError(AudioQueueStart(queue, NULL), "AudioQueueStart failed");
    isPlaying = YES;
}
- (void)stop
{
    if(!queue) return;
    CheckError(AudioQueueStop(queue, YES), "AudioQueueStop failed");
    // [self dispose] will be called automatically through the notification from a callback that track the event when audio player is stop playing
}
- (void)dispose
{
    if(!queue) return;
    CheckError(AudioQueueDispose(queue, YES), "AudioQueueDispose failed");
    queue = nil;
    isPlaying = NO;
}

- (void)pause
{
    if(!queue) return;
    isPause = YES;
    CheckError(AudioQueuePause(queue), "AudioQueuePause failed");
}
- (void)resume
{
    if(!queue) return;
    isPause = NO;
    CheckError(AudioQueueStart(queue, nil), "AudioQueueStart (resume) failed");
}

- (void)breakLoop
{
    // Change the current element loop property so when it's done the next element will start to play
    currentQueueItem(soundQueue)->breakEndlessLoop = YES;
}

// Get player state
- (bool)isPaused
{
    return isPause;
}
- (bool)isPlaying
{
    return isPlaying;
}
- (int)currentItemNumber
{
    return isPlaying?soundQueue->currentItemNumber:-1;
}

@end