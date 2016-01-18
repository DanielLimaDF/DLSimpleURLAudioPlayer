//
//  DLSimpleURLAudioPlayerController.m
//  DLSimpleURLAudioPlayer
//
//  Created by Daniel Lima on 12/11/15.
//  Copyright © 2015 dl. All rights reserved.
//

#import "DLSimpleURLAudioPlayerController.h"

@implementation DLSimpleURLAudioPlayerController

@synthesize delegate;
@synthesize audioQueue;
@synthesize player;
@synthesize currentAudio;
@synthesize playbackState;
@synthesize currentRepeatMode;
@synthesize currentShuffleMode;
@synthesize currentArtistName;
@synthesize currentSongName;
@synthesize currentCoverFileName;
@synthesize info;
@synthesize forceAudioChange;

-(id)init{
    
    audioLength = 0;
    
    currentRepeatMode = MPMusicRepeatModeNone;
    currentShuffleMode = MPMusicShuffleModeOff;
    
    forceAudioChange = NO;
    
    //info = [[NSDictionary alloc]init];
    
    // Make sure the system follows our playback status
    AVAudioSession *audioSession = [AVAudioSession sharedInstance];
    NSError *sessionError = nil;
    BOOL success = [audioSession setCategory:AVAudioSessionCategoryPlayback error:&sessionError];
    if (!success){
        NSLog(@"setCategory error %@", sessionError);
    }
    success = [audioSession setActive:YES error:&sessionError];
    if (!success){
        NSLog(@"setActive error %@", sessionError);
    }
    [audioSession setDelegate:self];
    
    volume = audioSession.outputVolume;
    
    [[UIApplication sharedApplication] beginReceivingRemoteControlEvents];
    
    //MPRemoteCommandCenter *commandCenter = [MPRemoteCommandCenter sharedCommandCenter];
    
    return self;
}


#pragma mark - MPMediaPlayback
-(void)play{
    
    currentAudio = [audioQueue objectAtIndex:currentAudioIndex];
    
    //Check if audio file exist in Documents folder
    NSString *fileName = [currentAudio.audioURL lastPathComponent];
    
    NSArray *pathsUsr = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentFolder = [pathsUsr objectAtIndex:0];
    
    NSString* localFile = [documentFolder stringByAppendingPathComponent:fileName];
    
    BOOL fileExists = [[NSFileManager defaultManager] fileExistsAtPath:localFile];
    
    if(fileExists){
        
        NSURL *localFileUrl = [[NSURL alloc] initFileURLWithPath: localFile];
        
        AVAsset *asset = [AVURLAsset URLAssetWithURL:localFileUrl options:nil];
        AVPlayerItem *anItem = [AVPlayerItem playerItemWithAsset:asset];
        
        player = [AVPlayer playerWithPlayerItem:anItem];
        
        NSLog(@"Playing from LOCAL DOCUMENTS FOLDER");
        
    }else{
        player = [[AVPlayer alloc]initWithURL:[NSURL URLWithString:currentAudio.audioURL]];
    }
    
    
    // Subscribe to the AVPlayerItem's DidPlayToEndTime notification.
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(itemDidFinishPlaying:) name:AVPlayerItemDidPlayToEndTimeNotification object:player.currentItem];
    
    //Set the inicial music volume, if the user have not yet changed the volume in app, the initial volume will be the system volume
    [player setVolume:volume];
    
    
    [self updateNowPlayingCenter];
    
    audioLength = CMTimeGetSeconds(player.currentItem.asset.duration);
    
    currentSongName = currentAudio.title;
    currentArtistName = currentAudio.author;
    currentCoverFileName = currentAudio.coverFileName;
    
    playbackState = MPMusicPlaybackStatePlaying;
    
    [delegate theAudioStartedPlaying];
    
    [player play];
    
}

- (void)resume {
    
    [player play];
    
    //Make sure the now playin info center current playback time is corrent when resume playing
    [self updateElapsedTimeNowPlayingCenter:[self currentPlaybackTime]];
    
    playbackState = MPMusicPlaybackStatePlaying;
    
    [delegate theAudioDidResume];
    
}

- (void)pause {
    [player pause];
    playbackState = MPMusicPlaybackStatePaused;
    
    [delegate theAudioDidPause];
    
}

- (void)stop {
    [player pause];
    playbackState = MPMusicPlaybackStateStopped;
    [[MPNowPlayingInfoCenter defaultCenter] setNowPlayingInfo:nil];
}


//MPMusicShuffleModeSongs
//MPMusicShuffleModeOff

-(void)nextSong{
    
    NSInteger queueSize = [audioQueue count];
    
    if(currentRepeatMode == MPMusicRepeatModeOne && !forceAudioChange){
        
        //Will not change the current audio index
        [self play];
    
    }else{
        if(currentShuffleMode == MPMusicShuffleModeSongs){
        
            int r = arc4random() % [audioQueue count];
        
            while(r == currentAudioIndex){
                r = arc4random() % [audioQueue count];
            }
        
            currentAudioIndex = r;
        
        }else{
            currentAudioIndex ++;
        }
    
        if(currentAudioIndex > (queueSize - 1)){
            currentAudioIndex = 0;
        }
        
        [self play];
        
    }
    
    
    
}

-(void)prevSong{
    
    NSInteger queueSize = [audioQueue count];
    
    if(currentRepeatMode == MPMusicRepeatModeOne && !forceAudioChange){
        
        //Will not change the current audio index
        [self play];
        
    }else{
    
        if(currentShuffleMode == MPMusicShuffleModeSongs){
        
            int r = arc4random() % [audioQueue count];
        
            while(r == currentAudioIndex){
                r = arc4random() % [audioQueue count];
            }
        
            currentAudioIndex = r;
        
        }else{
            currentAudioIndex --;
        }
    
        if(currentAudioIndex < 0){
            currentAudioIndex = queueSize - 1;
        }
        
        [self play];
        
    }
    
}


//Receive events from the device Quick Access Toolbar or the locked screen
- (void)remoteControlReceivedWithEvent:(UIEvent *)receivedEvent {

    if (receivedEvent.type != UIEventTypeRemoteControl) {
        return;
    }
    
    switch (receivedEvent.subtype) {
        case UIEventSubtypeRemoteControlTogglePlayPause: {
            if (self.playbackState == MPMusicPlaybackStatePlaying) {
                [self pause];
            } else {
                [self resume];
            }
            break;
        }
            
        case UIEventSubtypeRemoteControlNextTrack:
            
            [self nextSong];
            
            break;
            
        case UIEventSubtypeRemoteControlPreviousTrack:
            
            [self prevSong];
            
            break;
            
        case UIEventSubtypeRemoteControlPlay:
            
            [self resume];
            
            break;
            
        case UIEventSubtypeRemoteControlPause:
            
            [self pause];
            
            break;
            
        case UIEventSubtypeRemoteControlStop:
            
            [self pause];
            break;
            
        
            
        default:
            break;
    }
    
}

//Update now playng center in order to show audio information and controller to the device locked screen
- (void)updateNowPlayingCenter {
    
    float dur = CMTimeGetSeconds(player.currentItem.asset.duration);
    NSNumber *currentDur = [NSNumber numberWithFloat:dur];
    
    UIImage *image = [self loadImageFromLocalFile:currentAudio.coverFileName];
    
    MPMediaItemArtwork *albumArtwork;
    
    if([currentAudio.cover isKindOfClass:[NSNull class]]){
        albumArtwork = [[MPMediaItemArtwork alloc] initWithImage:[UIImage imageNamed:@"imagemAlbunArtista.png"]];
    }else{
        albumArtwork = [[MPMediaItemArtwork alloc] initWithImage:image];
    }
    
    
    info = @{ MPMediaItemPropertyTitle: currentAudio.title,
                            MPMediaItemPropertyArtist: currentAudio.author,
                            MPMediaItemPropertyPlaybackDuration: currentDur,
                            //MPNowPlayingInfoPropertyElapsedPlaybackTime: @0,
                            MPMediaItemPropertyArtwork: albumArtwork };
    
    [MPNowPlayingInfoCenter defaultCenter].nowPlayingInfo = info;
    
}

//Update the elapsed time on Now Playin center
-(void)updateElapsedTimeNowPlayingCenter:(float)currentTime{
    
    
    float dur = CMTimeGetSeconds(player.currentItem.asset.duration);
    NSNumber *currentDur = [NSNumber numberWithFloat:dur];
    NSNumber *currentProgressTime = [NSNumber numberWithFloat:currentTime];
    
    UIImage *image = [self loadImageFromLocalFile:currentAudio.coverFileName];
    
    MPMediaItemArtwork *albumArtwork;
    
    if([currentAudio.cover isKindOfClass:[NSNull class]]){
        albumArtwork = [[MPMediaItemArtwork alloc] initWithImage:[UIImage imageNamed:@"imagemAlbunArtista.png"]];
    }else{
        albumArtwork = [[MPMediaItemArtwork alloc] initWithImage:image];
    }
    
    
    info = @{ MPMediaItemPropertyTitle: currentAudio.title,
              MPMediaItemPropertyArtist: currentAudio.author,
              MPMediaItemPropertyPlaybackDuration: currentDur,
              MPNowPlayingInfoPropertyElapsedPlaybackTime: currentProgressTime,
              MPMediaItemPropertyArtwork: albumArtwork };
    
    [MPNowPlayingInfoCenter defaultCenter].nowPlayingInfo = info;
    
    
    
}



//Define the current audio from the view controller
-(void)setSelectedAudioIndex:(NSInteger)currentIndex{
    currentAudioIndex = currentIndex;
}


//Get system volume
-(CGFloat)getVolume{
    return volume;
}

//Get current audio Length
-(float)getAudioLength{
    return audioLength;
}


//Set player volume
-(void)setVolume:(float)currentVolume{
    volume = currentVolume;
    [player setVolume:currentVolume];
}

//Current value goes from 0 to 100, need to use percentage to calculate current position
-(void)setProgress:(float)currentValue{
    
    float totalDuration = CMTimeGetSeconds(player.currentItem.asset.duration);
    float desiredPosition = (currentValue * totalDuration) / 100;
    
    //NSLog(@"Total: %f - Desired: %f", totalDuration, desiredPosition);
    
    CMTime desiredTime = CMTimeMake(desiredPosition, 1);
    
    [player seekToTime:desiredTime toleranceBefore:kCMTimeZero toleranceAfter:kCMTimeZero];
    
    [self updateElapsedTimeNowPlayingCenter:desiredPosition];
    
}

//Change shuffle mode
- (void)setShuffleMode:(MPMusicShuffleMode)shuffleMode {
    currentShuffleMode = shuffleMode;
}


//Return float representation of current playback progress position
-(float)currentPlaybackTime{
    float currentPT = CMTimeGetSeconds(player.currentTime);
    
    return currentPT;
}


//Imagem loader from local cache
- (UIImage*)loadImageFromLocalFile:(NSString *)file{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
    NSString *libraryCacheDirectory = [paths objectAtIndex:0];
    NSString* path = [libraryCacheDirectory stringByAppendingPathComponent:[NSString stringWithFormat: @"%@",file]];
    UIImage* image = [UIImage imageWithContentsOfFile:path];
    return image;
}

//Delegates and notifications
-(void)itemDidFinishPlaying:(NSNotification *) notification {
    // Will be called when AVPlayer finishes playing playerItem
    
    playbackState = MPMusicPlaybackStateStopped;
    
    if(currentAudioIndex < ([audioQueue count] -1)){
    
        [self nextSong];
    
    }else{
        
        if(currentRepeatMode == MPMusicRepeatModeAll){
            [self nextSong];
        }else{
            [self stop];
        }
    }
}

@end
