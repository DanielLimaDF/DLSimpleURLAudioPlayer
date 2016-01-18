//
//  AudioDownloader.m
//  DLSimpleURLAudioPlayer
//
//  Created by Daniel Lima on 17/01/16.
//  Copyright © 2016 dl. All rights reserved.
//

#import "AudioDownloader.h"

@implementation AudioDownloader

@synthesize delegate;
@synthesize url;

#define kBgQueue dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)

-(id)init{
    
    url = [NSString stringWithFormat:@"http://dlsimpleurlaudioplayer.42noticias.com/mp3/hinonacional.mp3"];
    
    return self;
}

-(void)startDownload{
    
    NSString *fileName = [url lastPathComponent];
    
    NSArray *pathsUsr = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentFolder = [pathsUsr objectAtIndex:0];
    
    NSString* localFile = [documentFolder stringByAppendingPathComponent:fileName];
    
    BOOL fileExists = [[NSFileManager defaultManager] fileExistsAtPath:localFile];
    
    if(fileExists){
        
        [delegate audioDonwloaderDone];
    
    }else{
        
            dispatch_async(kBgQueue, ^{
                NSData *audioData = [NSData dataWithContentsOfURL:[NSURL URLWithString:url]];
                if (audioData) {
                    
                    dispatch_async(dispatch_get_main_queue(), ^{
                        
                        NSURL *saveLocation = [self.documentsDirectoryURL URLByAppendingPathComponent:@"hinonacional.mp3"];
                        
                        //NSLog(@"Local URL: %@",saveLocation);
                        
                        NSError *saveError = nil;
                        BOOL writeWasSuccessful = [audioData writeToURL:saveLocation
                                                                options:kNilOptions
                                                                  error:&saveError];
                        
                        dispatch_async(dispatch_get_main_queue(), ^{
                            
                            if (writeWasSuccessful) {
                                
                                NSLog(@"Write Was Sucessfull");
                                
                                [delegate audioDonwloaderDone];
                                
                            }else{
                                
                                NSLog(@"Write error");
                                
                            }
                        });
                        
                    });
                    
                }else{
                    NSLog(@"Error loading audio");
                }
            });
        
    }
    
    
    
    
    
}

- (NSURL *)documentsDirectoryURL{
    NSError *error = nil;
    NSURL *urlDir = [[NSFileManager defaultManager] URLForDirectory:NSDocumentDirectory
                                                        inDomain:NSUserDomainMask
                                               appropriateForURL:nil
                                                          create:NO
                                                           error:&error];
    if (error) {
        // Figure out what went wrong and handle the error.
    }
    
    return urlDir;
}

@end