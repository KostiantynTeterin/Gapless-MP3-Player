//
//  SoundQueue.m
//  Gapless-MP3-Player-ARC
//
//  Created by Kostya Teterin on 8/24/13.
//  Copyright (c) 2013 Kostya Teterin. All rights reserved.
//

#import "SoundQueue.h"

@implementation SoundQueueItem
@synthesize breakEndlessLoop;
@synthesize loop;
@synthesize sound;
-(void)setNextItem:(SoundQueueItem *)_nextItem
{
    nextItem = _nextItem;
}
-(SoundQueueItem*)nextItem
{
    return nextItem;
}
@end

@implementation SoundQueue
@synthesize currentItemNumber;
@synthesize isPlaying;

-(void)setObject:(NSObject *)_object
{
    object = _object;
}
-(NSObject*)object
{
    return object;
}
-(void)setFirstItem:(SoundQueueItem *)_firstItem
{
    firstItem = _firstItem;
}
-(SoundQueueItem*)firstItem
{
    return firstItem;
}
-(void)setLastItem:(SoundQueueItem *)_lastItem
{
    lastItem = _lastItem;
}
-(SoundQueueItem*)lastItem
{
    return lastItem;
}
-(void)setCurrentItem:(SoundQueueItem *)_currentItem
{
    currentItem = _currentItem;
}
-(SoundQueueItem*)currentItem
{
    return currentItem;
}
@end
