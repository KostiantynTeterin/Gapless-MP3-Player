//
//  SoundQueue.h
//  Gapless-MP3-Player-ARC
//
//  Created by Kostya Teterin on 8/24/13.
//  Copyright (c) 2013 Kostya Teterin. All rights reserved.
//

#import <CoreFoundation/CoreFoundation.h>
#import <AudioToolbox/AudioToolbox.h>
#import <Foundation/Foundation.h>

typedef struct SoundDescription {
    AudioFileID                     playbackFile;
    UInt32                          bufferByteSize;
    SInt64                          packetPosition;
    UInt32                          numPacketsToRead;
    AudioStreamPacketDescription    *packetDescs;
    AudioStreamBasicDescription     dataFormat;
    Boolean                         isDone;
} SoundDescription;

@interface SoundQueueItem : NSObject {
    bool breakEndlessLoop;
    int loop; // -1 = endless loop, 0 - play once
    SoundDescription *sound;
    SoundQueueItem *nextItem;
}
@property (nonatomic, assign) bool breakEndlessLoop;
@property (nonatomic, assign) int loop;
@property (nonatomic, assign) SoundDescription *sound;

-(void)setNextItem:(SoundQueueItem *)_nextItem;
-(SoundQueueItem*)nextItem;
@end

@interface SoundQueue : NSObject {
    SoundQueueItem *firstItem;
    SoundQueueItem *lastItem;
    SoundQueueItem *currentItem;
    int currentItemNumber;
    NSObject *object;
    bool isPlaying;
}
@property (nonatomic, assign) int currentItemNumber;
@property (nonatomic, assign) bool isPlaying;

-(void)setObject:(NSObject *)_object;
-(NSObject*)object;
-(void)setFirstItem:(SoundQueueItem *)_firstItem;
-(SoundQueueItem*)firstItem;
-(void)setLastItem:(SoundQueueItem *)_lastItem;
-(SoundQueueItem*)lastItem;
-(void)setCurrentItem:(SoundQueueItem *)_currentItem;
-(SoundQueueItem*)currentItem;
@end
