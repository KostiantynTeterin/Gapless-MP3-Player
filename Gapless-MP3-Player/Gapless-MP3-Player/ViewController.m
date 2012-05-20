//
//  ViewController.m
//  Gapless-MP3-Player
//
//  Created by Kostiantyn Teterin on 5/17/12.
//  Copyright (c) 2012 Emotion Rays Entertainment. All rights reserved.
//

#import "ViewController.h"
#import "AudioPlayer.h"

@implementation ViewController

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Let's create a queue of gapless mp3 music fragments
    AudioPlayer *player = [AudioPlayer defaultPlayer];
    [player addSoundFromFile:@"mus_main_title_01_lp.mp3" loop:-1];
    [player addSoundFromFile:@"mus_main_title_02_nl.mp3"];
    [player addSoundFromFile:@"mus_main_title_03_lp.mp3" loop:-1];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(colorLabels) name:APEVENT_MOVING_TO_NEXT_SOUND object:nil];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated
{
	[super viewWillDisappear:animated];
}

- (void)viewDidDisappear:(BOOL)animated
{
	[super viewDidDisappear:animated];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation != UIInterfaceOrientationPortraitUpsideDown);
}

- (IBAction)buttonPlayTap:(id)sender
{
    AudioPlayer *player = [AudioPlayer defaultPlayer];
    if(!player.isPlaying)
    {
        [playButton setTitle:@"Stop music" forState:UIControlStateNormal];
        [playButton setTitle:@"Stop music" forState:UIControlStateHighlighted];
        [player playQueue];
    }
    else 
    {
        [playButton setTitle:@"Play music" forState:UIControlStateNormal];
        [playButton setTitle:@"Play music" forState:UIControlStateHighlighted];
        [player stop];
    }
    [self colorLabels];
}
- (IBAction)buttonPauseTap:(id)sender
{
    AudioPlayer *player = [AudioPlayer defaultPlayer];
    if(!player.isPlaying) return;
    if(!player.isPaused)
    {
        [pauseButton setTitle:@"Resume music" forState:UIControlStateNormal];
        [pauseButton setTitle:@"Resume music" forState:UIControlStateHighlighted];
        [player pause];
    }
    else
    {
        [pauseButton setTitle:@"Pause music" forState:UIControlStateNormal];
        [pauseButton setTitle:@"Pause music" forState:UIControlStateHighlighted];
        [player resume];
    }
}
- (IBAction)buttonBreakLoopTap:(id)sender
{
    if([[AudioPlayer defaultPlayer] currentItemNumber] == 0)
    {
        [[AudioPlayer defaultPlayer] breakLoop];
        track1.textColor = [UIColor colorWithRed:0 green:1 blue:0 alpha:1];
    }
}
- (void)colorLabels
{
    UIColor *normal = [UIColor colorWithRed:0 green:0 blue:0 alpha:1];
    UIColor *highlighted = [UIColor colorWithRed:0 green:0 blue:1 alpha:1];
    int num = [[AudioPlayer defaultPlayer] currentItemNumber];
    
    track1.textColor = (num == 0)?highlighted:normal;
    track2.textColor = (num == 1)?highlighted:normal;
    track3.textColor = (num == 2)?highlighted:normal;
}
@end
