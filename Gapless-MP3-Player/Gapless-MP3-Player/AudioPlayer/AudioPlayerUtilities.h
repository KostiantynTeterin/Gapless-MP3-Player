//
//  AudioPlayerUtilities.h
//  Gapless-MP3-Player
//
//  Created by Kostya Teterin on 18.05.12.
//  Copyright (c) 2012 Emotion Rays Entertainment. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreFoundation/CoreFoundation.h>
#import <AudioToolbox/AudioToolbox.h>

#define APEVENT_QUEUE_DONE  @"apeventQueueDone"
#define APEVENT_MOVING_TO_NEXT_SOUND  @"apeventMovingToNextSound"

// We will need 3 buffers: 1 is playing, 2 is reading and 3 in case of lag
#define kNumberPlaybackBuffers 3
#define kBufferSizeInSeconds 0.01

typedef struct SoundDescription {
    AudioFileID                     playbackFile;
    UInt32                          bufferByteSize;
    SInt64                          packetPosition;
    UInt32                          numPacketsToRead;
    AudioStreamPacketDescription    *packetDescs;
    AudioStreamBasicDescription     dataFormat;
    Boolean                         isDone;
} SoundDescription;

typedef struct SoundQueueItem {
    Boolean                         breakEndlessLoop;
    int                             loop; // -1 = endless loop, 0 - play once
    SoundDescription                *sound;
    struct SoundQueueItem           *nextItem;
} SoundQueueItem;

typedef struct SoundQueue {
    SoundQueueItem *firstItem;
    SoundQueueItem *lastItem;
    SoundQueueItem *currentItem;
    int currentItemNumber;
} SoundQueue;


// Just helper functions in case if the SoundQueue format will be changed in the future (to store objects instead of structures for example)
static SoundQueueItem *currentQueueItem(SoundQueue *queue)
{
    return queue->currentItem;
}
static SoundDescription* currentSoundDescription(SoundQueue *queue)
{
    return currentQueueItem(queue)->sound;
}

#pragma mark Utility functions

static void CheckError(OSStatus error, const char *operation)
{
    if(error == noErr) return;
    
    char errorString[20];
    *(UInt32*)(errorString + 1) = CFSwapInt32HostToBig(error);
    if(isprint(errorString[1]) && isprint(errorString[2]) && isprint(errorString[3]) && isprint(errorString[4]))
    {
        errorString[0] = errorString[5] = '\'';
        errorString[6] = '\0';
    }
    else 
        sprintf(errorString, "%d", (int)error);
    
    fprintf(stderr, "Error: %s (%s)\n", operation, errorString);
    exit(1);
}

// Set up a "magic cookie" - a format related information for Audio Queue that helps to determine how to decode the audio data
static void CopyEncoderCookieToQueue(AudioFileID theFile, AudioQueueRef queue)
{
    UInt32 propertySize;
    OSStatus result = AudioFileGetPropertyInfo(theFile, kAudioFilePropertyMagicCookieData, &propertySize, NULL);
    if(result == noErr && propertySize > 0)
    {
        Byte *magicCookie = (UInt8*)malloc(sizeof(UInt8) * propertySize);
        CheckError(AudioFileGetProperty(theFile, kAudioFilePropertyMagicCookieData, &propertySize, magicCookie), "Get cookie from file failed");
        CheckError(AudioQueueSetProperty(queue, kAudioQueueProperty_MagicCookie, magicCookie, propertySize), "Set cookie on queue failed");
        free(magicCookie);
    }
}

static void CalculateBytesForTime(AudioFileID inAudioFile, AudioStreamBasicDescription inDesc, Float64 inSeconds, UInt32 *outBufferSize, UInt32 *outNumPackets)
{
    UInt32 maxPacketSize;
    UInt32 propSize = sizeof(maxPacketSize);
    CheckError(AudioFileGetProperty(inAudioFile, kAudioFilePropertyPacketSizeUpperBound, &propSize, &maxPacketSize), "Couldn't get file's max packet size");
    
    static const int maxBufferSize = 0x10000;
    static const int minBufferSize = 0x4000;
    
    if(inDesc.mFramesPerPacket)
    {
        Float64 numPacketsForTime = inDesc.mSampleRate / inDesc.mFramesPerPacket * inSeconds;
        *outBufferSize = numPacketsForTime * maxPacketSize;
    }
    else
    {
        *outBufferSize = maxBufferSize > maxPacketSize ? maxBufferSize:maxPacketSize;
    }
    
    if(*outBufferSize > maxBufferSize && *outBufferSize > maxPacketSize)
        *outBufferSize = maxBufferSize;
    else 
    {
        if(*outBufferSize < minBufferSize) *outBufferSize = minBufferSize;
    }
    *outNumPackets = *outBufferSize / maxPacketSize;
}


// Callback when isRunning property is changed
static void AQPropertyListenerProc (void *inUserData, AudioQueueRef inAQ, AudioQueuePropertyID inID)
{
    UInt32 value;
    UInt32 size = sizeof(value);
    AudioQueueGetProperty(inAQ, kAudioQueueProperty_IsRunning, &value, &size);
    if(value == 0)
    {
        // This event should be catched by audio player to dispose the audio queue
        [[NSNotificationCenter defaultCenter] postNotificationName:APEVENT_QUEUE_DONE object:nil];
    }
}

// Callback that read the data to buffers and enqueue them to be played
static void AQOutputCallback(void *inUserData, AudioQueueRef inAQ, AudioQueueBufferRef inCompleteAQBuffer)
{
    // inUserData = SoundQueue object
    SoundDescription *sound = currentSoundDescription((SoundQueue*)inUserData);
    if(sound->isDone) return;
    
    UInt32 numBytes;
    UInt32 nPackets = sound->numPacketsToRead;
    CheckError(AudioFileReadPackets(sound->playbackFile, false, &numBytes, sound->packetDescs, sound->packetPosition, &nPackets, inCompleteAQBuffer->mAudioData), "AudioFileReadPackets failed");
    
    if(nPackets > 0)
    {
        // If there's more packets, read them
        inCompleteAQBuffer->mAudioDataByteSize = numBytes;
        AudioQueueEnqueueBuffer(inAQ, inCompleteAQBuffer, (sound->packetDescs?nPackets:0), sound->packetDescs);
        sound->packetPosition += nPackets;
    }
    else 
    {
        SoundQueueItem *soundItem = currentQueueItem((SoundQueue*)inUserData);
        if((soundItem->loop == -1 || soundItem->loop > 0) && !soundItem->breakEndlessLoop)
        {
            // If sound is done but it is looped, play it again
            sound->packetPosition = 0;
            AQOutputCallback(inUserData, inAQ, inCompleteAQBuffer);
            
            // If the loop isn't endless, decrease the counter
            if(soundItem->loop > 0) --soundItem->loop;
        }
        else
        {
            // Done with this sound
            sound->isDone = true;
            
            SoundQueue *queue = (SoundQueue*)inUserData;
            // Move to the next sound (if any)
            queue->currentItem = queue->currentItem->nextItem;
            if(queue->currentItem)
            {
                // Copy new magic cookie to the queue
                CopyEncoderCookieToQueue(currentSoundDescription(queue)->playbackFile, inAQ);

                // Fill the buffers with the data of the next sound
                AQOutputCallback(inUserData, inAQ, inCompleteAQBuffer);
                ++queue->currentItemNumber;
                [[NSNotificationCenter defaultCenter] postNotificationName:APEVENT_MOVING_TO_NEXT_SOUND object:nil];
            }
            else 
            {
                // Queue is done.
                CheckError(AudioQueueStop(inAQ, false), "AudioQueueStop failed");
            }
        }
    }
}
