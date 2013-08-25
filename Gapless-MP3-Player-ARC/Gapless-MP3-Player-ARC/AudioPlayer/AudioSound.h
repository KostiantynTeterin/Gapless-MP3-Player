//
//  AudioSound.h
//  Gapless-MP3-Player-ARC
//
//  Created by Kostya Teterin on 8/24/13.
//  Copyright (c) 2013 Kostya Teterin. All rights reserved.
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
