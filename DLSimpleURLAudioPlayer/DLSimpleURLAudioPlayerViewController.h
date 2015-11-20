//
//  DLSimpleURLAudioPlayerViewController.h
//  DLSimpleURLAudioPlayer
//
//  Created by Daniel Lima on 12/11/15.
//  Copyright © 2015 dl. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DLSimpleURLAudioPlayerController.h"

@interface DLSimpleURLAudioPlayerViewController : UIViewController{
    NSInteger selectedAudio;
}

@property (nonatomic, retain) NSMutableArray *audioList;
@property (nonatomic, retain) DLSimpleURLAudioPlayerController *audioController;

@property (nonatomic, retain) IBOutlet UISlider *progressSlider;
@property (nonatomic, retain) IBOutlet UISlider *volumeSlider;

@property (weak, nonatomic) IBOutlet UILabel *songLabel;
@property (weak, nonatomic) IBOutlet UILabel *artistLabel;
@property (weak, nonatomic) IBOutlet UIImageView *imageView;
@property (weak, nonatomic) IBOutlet UIButton *playPauseButton;
@property (weak, nonatomic) IBOutlet UILabel *trackCurrentPlaybackTimeLabel;
@property (weak, nonatomic) IBOutlet UILabel *trackLengthLabel;
@property (weak, nonatomic) IBOutlet UIButton *repeatButton;
@property (weak, nonatomic) IBOutlet UIButton *shuffleButton;
@property (weak, nonatomic) IBOutlet UIButton *nextButton;
@property (weak, nonatomic) IBOutlet UIButton *prevButton;
@property (strong, nonatomic) NSTimer *timer;

-(void)setSelectedAudio:(NSInteger)currentAudio;

- (IBAction)changeVolume;
- (IBAction)changingAudioProgress;
- (IBAction)changeAudioProgress;
- (IBAction)playPauseAction;
- (IBAction)goNextSong;
- (IBAction)goPrevSong;
- (IBAction)shuffleAction;
- (IBAction)repeatAction;

- (UIImage*)loadImageFromLocalFile:(NSString *)file;

- (void)timerLoop;

- (void)remoteControlReceivedWithEvent:(UIEvent *)receivedEvent;

- (void)theAudioStartedPlaying;

@end
