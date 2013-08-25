//
//  ViewController.h
//  Gapless-MP3-Player-ARC
//
//  Created by Kostya Teterin on 8/24/13.
//  Copyright (c) 2013 Kostya Teterin. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AudioPlayer.h"

@interface ViewControllerARC : UIViewController {
    __weak IBOutlet UIButton *buttonPlay;
    __weak IBOutlet UIButton *buttonBreakLoop;
    __weak IBOutlet UIButton *buttonPause;
    __weak IBOutlet UILabel *track1;
    __weak IBOutlet UILabel *track2;
    __weak IBOutlet UILabel *track3;
}
- (IBAction)buttonPlayTap:(id)sender;
- (IBAction)buttonPauseTap:(id)sender;
- (IBAction)buttonBreakLoopTap:(id)sender;
@end
