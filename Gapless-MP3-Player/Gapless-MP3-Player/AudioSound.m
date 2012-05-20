//
//  AudioSound.m
//  Gapless-MP3-Player
//
//  Created by Kostya Teterin on 18.05.12.
//  Copyright (c) 2012 Emotion Rays Entertainment. All rights reserved.
//

#import "AudioSound.h"
#import "AudioPlayer.h"
#import <mach/mach_time.h>

@implementation AudioSound

- (id)initWithSoundFile:(NSString*)filename
{
    [super init];
    [self loadSoundFile:filename];
    return self;
}
- (void)loadSoundFile:(NSString*)filename
{
    NSString *soundFile= [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:filename];
    CFURLRef soundURL = CFURLCreateWithFileSystemPath(kCFAllocatorDefault, (CFStringRef)soundFile, kCFURLPOSIXPathStyle, false);
    CheckError(AudioFileOpenURL(soundURL, kAudioFileReadPermission, 0, &soundDescription.playbackFile), "AudioFileOpenURL failed");
    CFRelease(soundURL);
    
    // Get file format information and check if it's compatible to play
    UInt32 propSize = sizeof(soundDescription.dataFormat);
    CheckError(AudioFileGetProperty(soundDescription.playbackFile, kAudioFilePropertyDataFormat, &propSize, &soundDescription.dataFormat), "Couldn't get file's data format");
    
    // Get sound duration in seconds
    CFTimeInterval seconds;
    UInt32 propertySize = sizeof(seconds);
    AudioFileGetProperty(soundDescription.playbackFile, kAudioFilePropertyEstimatedDuration, &propertySize, &seconds);
    mSoundDuration = seconds;
    
    // Figure out how big data buffer we need and how much bytes will be reading on each callback
    CalculateBytesForTime(soundDescription.playbackFile, soundDescription.dataFormat, kBufferSizeInSeconds, &soundDescription.bufferByteSize, &soundDescription.numPacketsToRead);
    
    // Allocating memory for packet description array
    bool isFormatVBR = (soundDescription.dataFormat.mBytesPerPacket == 0 || soundDescription.dataFormat.mFramesPerPacket == 0);
    if(isFormatVBR) 
        soundDescription.packetDescs = (AudioStreamPacketDescription*)malloc(sizeof(AudioStreamPacketDescription) * soundDescription.numPacketsToRead);
    else 
        soundDescription.packetDescs = NULL;
    
}
- (void)dealloc
{
    if(soundDescription.packetDescs) free(soundDescription.packetDescs);
    AudioFileClose(soundDescription.playbackFile);
    [super dealloc];
}

- (SoundDescription*)description
{
    return &soundDescription;
}
- (NSTimeInterval)duration
{
    return mSoundDuration;
}

@end
