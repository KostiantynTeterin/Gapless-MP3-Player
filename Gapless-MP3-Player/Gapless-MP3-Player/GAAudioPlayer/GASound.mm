//
//  GASound.m
//  Gapless-MP3-Player
//
//  Created by Kostya Teterin on 19.05.12.
//  Copyright (c) 2012 Emotion Rays Entertainment. All rights reserved.
//

#import "GASound.h"

static void CreateAUGraph(GAGraphPlayer *player)
{
	// create a new AUGraph
	CheckError(NewAUGraph(&player->graph),
			   "NewAUGraph failed");
	// genereate description that will match out output device (speakers)
	AudioComponentDescription outputcd = {0};
	outputcd.componentType = kAudioUnitType_Output;
	outputcd.componentSubType = kAudioUnitSubType_RemoteIO;
	outputcd.componentManufacturer = kAudioUnitManufacturer_Apple;

	// adds a node with above description to the graph
	AUNode outputNode;
	CheckError(AUGraphAddNode(player->graph, &outputcd, &outputNode),
			   "AUGraphAddNode[kAudioUnitSubType_DefaultOutput] failed");

	// genereate description that will match a generator AU of type: audio file player
	AudioComponentDescription fileplayercd = {0};
	fileplayercd.componentType = kAudioUnitType_Generator;
	fileplayercd.componentSubType = kAudioUnitSubType_AudioFilePlayer;
	fileplayercd.componentManufacturer = kAudioUnitManufacturer_Apple;
	
	// adds a node with above description to the graph
	AUNode fileNode;
	CheckError(AUGraphAddNode(player->graph, &fileplayercd, &fileNode),
			   "AUGraphAddNode[kAudioUnitSubType_AudioFilePlayer] failed");
	
	// opening the graph opens all contained audio units but does not allocate any resources yet
	CheckError(AUGraphOpen(player->graph),
			   "AUGraphOpen failed");
    
    // Get the reference to the AudioUnit object for the file player graph node
    CheckError(AUGraphNodeInfo(player->graph, fileNode, NULL, &player->fileAU), "AUGraphNodeInfo failed");
    
    // Connect the output source of the file player AU to the input source of the output node
    CheckError(AUGraphConnectNodeInput(player->graph, fileNode, 0, outputNode, 0), "AUGraphConnectNodeInput");
    
    // Initialize the graph
    CheckError(AUGraphInitialize(player->graph), "AUGraphInitialize failed");
}

static double PrepareFileAU(GAGraphPlayer *player)
{
    // Load the file
    CheckError(AudioUnitSetProperty(player->fileAU, kAudioUnitProperty_ScheduledFileIDs, kAudioUnitScope_Global, 0, &player->inputFile, sizeof(player->inputFile)), "AudioUnitSetProperty - ScheduledFileIDs failed");
    
    UInt64 nPackets;
    UInt32 propSize = sizeof(nPackets);
    CheckError(AudioFileGetProperty(player->inputFile, kAudioFilePropertyAudioDataPacketCount, &propSize, &nPackets), "AudioFileGetProperty - AudioDataPacketCount");
    
    // Tell the player AU to play the entire file
    ScheduledAudioFileRegion rgn;
    memset(&rgn.mTimeStamp, 0, sizeof(rgn.mTimeStamp));
    rgn.mTimeStamp.mFlags = kAudioTimeStampSampleTimeValid;
    rgn.mTimeStamp.mSampleTime = 0;
    rgn.mCompletionProc = NULL;
    rgn.mCompletionProcUserData = NULL;
    rgn.mAudioFile = player->inputFile;
    rgn.mLoopCount = 1;
    rgn.mStartFrame = 0;
    rgn.mFramesToPlay = nPackets * player->inputFormat.mFramesPerPacket;
    
    CheckError(AudioUnitSetProperty(player->fileAU, kAudioUnitProperty_ScheduledFileRegion, kAudioUnitScope_Global, 0, &rgn, sizeof(rgn)), "AudioUnitSetProperty - ScheduledFileRegion");
    
    // Set when to start playing
    AudioTimeStamp startTime;
    memset(&startTime, 0, sizeof(startTime));
    startTime.mFlags = kAudioTimeStampSampleTimeValid;
    startTime.mSampleTime = -1;
    CheckError(AudioUnitSetProperty(player->fileAU, kAudioUnitProperty_ScheduleStartTimeStamp, kAudioUnitScope_Global, 0, &startTime, sizeof(startTime)), "AudioUnitSetProperty - scheduledstarttimestamp failed");
    
    // File duration
    return (nPackets * player->inputFormat.mFramesPerPacket) / player->inputFormat.mSampleRate;
}

@implementation GASound

- (void)loadFromFile:(NSString*)filename
{
    // Load file
    NSString *soundFile= [[NSBundle mainBundle] pathForResource:filename ofType:nil];
    CFURLRef soundURL = (__bridge CFURLRef)[NSURL fileURLWithPath:soundFile];
    CheckError(AudioFileOpenURL(soundURL, kAudioFileReadPermission, 0, &player.inputFile), "AudioFileOpenURL failed");
    CFRelease(soundURL);
    
    // Get audio data format from file
    UInt32 propSize = sizeof(player.inputFormat);

    CheckError(AudioFileGetProperty(player.inputFile, kAudioFilePropertyDataFormat, &propSize, &player.inputFormat), "Couldn't get file's data format");
    
    // Build fileplayer->speakers graph
    CreateAUGraph(&player);
    
    // Configure the file player
    Float64 fileDuration = PrepareFileAU(&player);
    
    // Start playing
    CheckError(AUGraphStart(player.graph), "AUGraphStart failed");
    
    // Sleep until the file is finished
    usleep((int)(fileDuration * 1000.0 * 1000.0));
    
    // Cleanup
    AUGraphStop(player.graph);
    AUGraphUninitialize(player.graph);
    AUGraphClose(player.graph);
    AudioFileClose(player.inputFile);
}

@end
