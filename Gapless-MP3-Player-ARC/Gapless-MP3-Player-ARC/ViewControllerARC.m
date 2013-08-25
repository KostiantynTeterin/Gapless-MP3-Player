//
//  ViewController.m
//  Gapless-MP3-Player-ARC
//
//  Created by Kostya Teterin on 8/24/13.
//  Copyright (c) 2013 Kostya Teterin. All rights reserved.
//

#import "ViewControllerARC.h"

@interface ViewControllerARC ()

@end

@implementation ViewControllerARC

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
-(void)viewDidUnload
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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
        [buttonPlay setTitle:@"Stop music" forState:UIControlStateNormal];
        [buttonPlay setTitle:@"Stop music" forState:UIControlStateHighlighted];
        [player playQueue];
    }
    else
    {
        [buttonPlay setTitle:@"Play music" forState:UIControlStateNormal];
        [buttonPlay setTitle:@"Play music" forState:UIControlStateHighlighted];
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
        [buttonPause setTitle:@"Resume music" forState:UIControlStateNormal];
        [buttonPause setTitle:@"Resume music" forState:UIControlStateHighlighted];
        [player pause];
    }
    else
    {
        [buttonPause setTitle:@"Pause music" forState:UIControlStateNormal];
        [buttonPause setTitle:@"Pause music" forState:UIControlStateHighlighted];
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
