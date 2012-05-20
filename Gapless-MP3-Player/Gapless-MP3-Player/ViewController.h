//
//  ViewController.h
//  Gapless-MP3-Player
//
//  Created by Kostiantyn Teterin on 5/17/12.
//  Copyright (c) 2012 Emotion Rays Entertainment. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AudioPlayer.h"

@interface ViewController : UIViewController {
    AudioSound *mus1, *mus2;
    UIButton IBOutlet *playButton;
    UIButton IBOutlet *pauseButton;
    
    UILabel IBOutlet *track1, *track2, *track3;
}
- (IBAction)buttonPlayTap:(id)sender;
- (IBAction)buttonPauseTap:(id)sender;
- (IBAction)buttonBreakLoopTap:(id)sender;
@end