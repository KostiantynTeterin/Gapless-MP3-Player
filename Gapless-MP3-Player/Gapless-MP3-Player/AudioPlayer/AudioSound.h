//
//  AudioSound.h
//  Gapless-MP3-Player
//
//  Created by Kostya Teterin on 18.05.12.
//  Copyright (c) 2012 Emotion Rays Entertainment. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreFoundation/CoreFoundation.h>
#import <AudioToolbox/AudioToolbox.h>

#import "AudioPlayerUtilities.h"

@interface AudioSound : NSObject {
    SoundDescription soundDescription;
    NSTimeInterval mSoundDuration;
}

- (id)initWithSoundFile:(NSString*)filename;
- (void)loadSoundFile:(NSString*)filename;

- (SoundDescription*)description;
- (NSTimeInterval)duration;
@end
