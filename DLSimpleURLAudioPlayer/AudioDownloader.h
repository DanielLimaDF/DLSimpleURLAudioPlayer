//
//  AudioDownloader.h
//  DLSimpleURLAudioPlayer
//
//  Created by Daniel Lima on 17/01/16.
//  Copyright © 2016 dl. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol audioDownloaderDelegate
- (void)audioDonwloaderDone;
@end

@interface AudioDownloader : NSObject{
    id <NSObject, audioDownloaderDelegate > delegate;
}

@property (retain) id <NSObject, audioDownloaderDelegate > delegate;

@property (nonatomic,retain) NSString *url;

-(id)init;
-(void)startDownload;
-(NSURL *)documentsDirectoryURL;

@end
