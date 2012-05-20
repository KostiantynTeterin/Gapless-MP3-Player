//
//  GASound.h
//  Gapless-MP3-Player
//
//  Created by Kostya Teterin on 19.05.12.
//  Copyright (c) 2012 Emotion Rays Entertainment. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreFoundation/CoreFoundation.h>
#import <AudioToolbox/AudioToolbox.h>
#import <AudioUnit/AudioUnit.h>

#import "AudioPlayerUtilities.h"

typedef struct GAGraphPlayer {
    AudioStreamBasicDescription inputFormat;
    AudioFileID                 inputFile;
    ExtAudioFileRef             extInputFile;
    AUGraph                     graph;
    AudioUnit                   fileAU;
} GAGraphPlayer;

@interface GASound : NSObject {
    GAGraphPlayer player;
}
    
- (void)loadFromFile:(NSString*)filename;

@end
