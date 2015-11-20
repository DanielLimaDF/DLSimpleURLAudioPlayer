//
//  DLSimpleURLAudioPlayerController.h
//  DLSimpleURLAudioPlayer
//
//  Created by Daniel Lima on 12/11/15.
//  Copyright © 2015 dl. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>
#import <MediaPlayer/MediaPlayer.h>
#import "Audio.h"

@protocol DLSimpleURLAudioPlayerControllerDelegate
- (void)theAudioStartedPlaying;
- (void)theAudioDidResume;
- (void)theAudioDidPause;
@end

@interface DLSimpleURLAudioPlayerController : NSObject<MPMediaPlayback>{
    id <NSObject, DLSimpleURLAudioPlayerControllerDelegate > delegate;
    NSInteger currentAudioIndex;
    CGFloat volume;
    float audioLength;
}

@property (nonatomic) MPMusicPlaybackState playbackState;
@property (nonatomic) MPMusicRepeatMode currentRepeatMode;
@property (nonatomic) MPMusicShuffleMode currentShuffleMode;
@property (nonatomic, retain) NSMutableArray *audioQueue;
@property (strong, nonatomic) AVPlayer *player;
@property (strong, nonatomic) Audio *currentAudio;

@property (nonatomic, retain) NSString *currentSongName;
@property (nonatomic, retain) NSString *currentArtistName;
@property (nonatomic, retain) NSString *currentCoverFileName;

@property (nonatomic, retain) NSDictionary *info;

@property (retain) id <NSObject, DLSimpleURLAudioPlayerControllerDelegate > delegate;

//Force audio change even if the repeat mode is active
@property BOOL forceAudioChange;


-(id)init;
-(void)play;
-(void)resume;
-(void)pause;
-(void)stop;
-(void)nextSong;
-(void)prevSong;
-(void)setSelectedAudioIndex:(NSInteger)currentAudio;
-(UIImage*)loadImageFromLocalFile:(NSString *)file;
-(void)updateNowPlayingCenter;
-(void)updateElapsedTimeNowPlayingCenter:(float)currentTime;
-(CGFloat)getVolume;
-(float)getAudioLength;
-(void)setVolume:(float)currentVolume;
-(void)setProgress:(float)currentValue;
-(float)currentPlaybackTime;
- (void)setShuffleMode:(MPMusicShuffleMode)shuffleMode;


//Delegates, events and notifications
-(void)itemDidFinishPlaying:(NSNotification *) notification;

- (void)remoteControlReceivedWithEvent:(UIEvent *)receivedEvent;

@end
