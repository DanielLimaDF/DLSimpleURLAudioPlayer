//
//  DLSimpleURLAudioPlayerViewController.m
//  DLSimpleURLAudioPlayer
//
//  Created by Daniel Lima on 12/11/15.
//  Copyright © 2015 dl. All rights reserved.
//

#import "DLSimpleURLAudioPlayerViewController.h"

@interface DLSimpleURLAudioPlayerViewController ()

@end

@implementation DLSimpleURLAudioPlayerViewController
@synthesize audioController;
@synthesize audioList;

@synthesize progressSlider;
@synthesize volumeSlider;

@synthesize songLabel;
@synthesize artistLabel;
@synthesize imageView;
@synthesize playPauseButton;
@synthesize trackCurrentPlaybackTimeLabel;
@synthesize trackLengthLabel;
@synthesize repeatButton;
@synthesize shuffleButton;
@synthesize nextButton;
@synthesize prevButton;
@synthesize timer;

- (void)viewDidLoad {
    
    //Change progress slider appearance
    [progressSlider setThumbImage:[UIImage imageNamed:@"itemSlider"] forState:UIControlStateNormal];
    
    //Set and play current media
    audioController = [[DLSimpleURLAudioPlayerController alloc]init];
    audioController.delegate = self;
    audioController.audioQueue = audioList;
    [audioController setSelectedAudioIndex:selectedAudio];
    [audioController play];
    
    [volumeSlider setValue:[audioController getVolume] animated:YES];
    
    //Start the timer used to update the player informations
    timer = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(timerLoop) userInfo:nil repeats:YES];
    [timer fire];
    
    //Set playpause button initial image
    [playPauseButton setImage:[UIImage imageNamed:@"Controls_Pause.png"] forState:UIControlStateNormal];
    
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}


-(void)viewWillAppear:(BOOL)animated{
    self.navigationController.navigationBar.hidden = NO;
    [super viewWillAppear:animated];
}

-(void)viewWillDisappear:(BOOL)animated{
    
    [audioController stop];
    
    [super viewWillDisappear:animated];
}

//Update player labels and progress slider
- (void)timerLoop{
    
    if(audioController.playbackState == MPMusicPlaybackStatePlaying){
        
        float currentPlaybackTime = [audioController currentPlaybackTime];
        float TotalLength = [audioController getAudioLength];
        
        float remainingPlaybackTime = TotalLength - currentPlaybackTime;
        
        float sliderPosition = (currentPlaybackTime *100) / TotalLength;
        
        //Update slider
        [progressSlider setValue:sliderPosition];
        
        //Update labels
        NSDate* d1 = [NSDate dateWithTimeIntervalSince1970:currentPlaybackTime];
        NSDate* d2 = [NSDate dateWithTimeIntervalSince1970:remainingPlaybackTime];
        
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setDateFormat:@"mm:ss"];
        
        NSString *currentTime = [dateFormatter stringFromDate:d1];
        NSString *ramainingTime = [dateFormatter stringFromDate:d2];
        
        [trackCurrentPlaybackTimeLabel setText:currentTime];
        [trackLengthLabel setText:[NSString stringWithFormat:@"-%@",ramainingTime]];
        
    }
    
}



//Define the current audio from the preview view controller
-(void)setSelectedAudio:(NSInteger)currentAudio{
    
    selectedAudio = currentAudio;
    
}


//Change colume using uislider
- (IBAction)changeVolume{
    [audioController setVolume:volumeSlider.value];
}

//Update only the progress labels while draging uislider
- (IBAction)changingAudioProgress{
    
    float TotalLength = [audioController getAudioLength];
    float currentDragPosition = progressSlider.value;
    
    float currentPlaybackDragPosition = (currentDragPosition * TotalLength) / 100;
    float remainingPlaybackTime = TotalLength - currentPlaybackDragPosition;
    
    //NSDate *d1 = [[NSDate alloc] initWithTimeIntervalSinceNow:currentPlaybackDragPosition];
    NSDate* d1 = [NSDate dateWithTimeIntervalSince1970:currentPlaybackDragPosition];
    NSDate* d2 = [NSDate dateWithTimeIntervalSince1970:remainingPlaybackTime];
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"mm:ss"];
    
    NSString *currentTime = [dateFormatter stringFromDate:d1];
    NSString *ramainingTime = [dateFormatter stringFromDate:d2];
    
    [trackCurrentPlaybackTimeLabel setText:currentTime];
    [trackLengthLabel setText:[NSString stringWithFormat:@"-%@",ramainingTime]];
    
}

//Change audio progress using uislider (value from 0 to 100 - will use percentage)
- (IBAction)changeAudioProgress{
    
    [audioController setProgress:progressSlider.value];
    
}

//Resume or pause the sound
- (IBAction)playPauseAction{
    
    if(audioController.playbackState == MPMusicPlaybackStatePlaying){
        [audioController pause];
    }else{
        
        if(audioController.playbackState == MPMusicPlaybackStatePaused){
            [audioController resume];
        }
    }
    
}


//Enable or disable shuffle
- (IBAction)shuffleAction{
    
    shuffleButton.selected = !shuffleButton.selected;
    
    if (shuffleButton.selected) {
        [audioController setShuffleMode:MPMusicShuffleModeSongs];
    } else {
        [audioController setShuffleMode:MPMusicShuffleModeOff];
    }
}

//Changing repeat mode
- (IBAction)repeatAction{
    
    switch (audioController.currentRepeatMode) {
        case MPMusicRepeatModeAll:
            // From repeat all to repeat one
            audioController.currentRepeatMode = MPMusicRepeatModeOne;
            break;
            
        case MPMusicRepeatModeOne:
            // From repeat one to repeat none
            audioController.currentRepeatMode = MPMusicRepeatModeNone;
            break;
            
        case MPMusicRepeatModeNone:
            // From repeat none to repeat all
            audioController.currentRepeatMode = MPMusicRepeatModeAll;
            break;
            
        default:
            audioController.currentRepeatMode = MPMusicRepeatModeAll;
            break;
    }
    
    
    //Change button image
    NSString *repeatButtonImage;
    
    switch (audioController.currentRepeatMode) {
        case MPMusicRepeatModeAll:
            repeatButtonImage = @"Track_Repeat_On";
            break;
            
        case MPMusicRepeatModeOne:
            repeatButtonImage = @"Track_Repeat_On_Track";
            break;
            
        case MPMusicRepeatModeNone:
            repeatButtonImage = @"Track_Repeat_Off";
            break;
            
        default:
            repeatButtonImage = @"Track_Repeat_Off";
            break;
    }
    
    [repeatButton setImage:[UIImage imageNamed:repeatButtonImage] forState:UIControlStateNormal];
    
    
}


- (IBAction)goNextSong{
    
    //Force audio change even if the repeat mode is active
    audioController.forceAudioChange = YES;
    
    [audioController nextSong];
}
- (IBAction)goPrevSong{
    
    //Force audio change even if the repeat mode is active
    audioController.forceAudioChange = YES;
    
    [audioController prevSong];
}

- (void)remoteControlReceivedWithEvent:(UIEvent *)receivedEvent{
    [audioController remoteControlReceivedWithEvent:receivedEvent];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

//Imagem loader from local cache
- (UIImage*)loadImageFromLocalFile:(NSString *)file{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
    NSString *libraryCacheDirectory = [paths objectAtIndex:0];
    NSString* path = [libraryCacheDirectory stringByAppendingPathComponent:[NSString stringWithFormat: @"%@",file]];
    UIImage* image = [UIImage imageWithContentsOfFile:path];
    return image;
}




//Delegates
- (void)theAudioStartedPlaying{
    
    audioController.forceAudioChange = NO;
    
    [songLabel setText:audioController.currentSongName];
    [artistLabel setText:audioController.currentArtistName];
    
    if([audioController.currentAudio.cover isKindOfClass:[NSNull class]]){
        [imageView setImage:[UIImage imageNamed:@"imagemAlbunArtista.png"]];
    }else{
        [imageView setImage:[self loadImageFromLocalFile:audioController.currentCoverFileName]];
    }
    
}

- (void)theAudioDidResume{
    [playPauseButton setImage:[UIImage imageNamed:@"Controls_Pause.png"] forState:UIControlStateNormal];
}

- (void)theAudioDidPause{
    [playPauseButton setImage:[UIImage imageNamed:@"Controls_Play.png"] forState:UIControlStateNormal];
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
