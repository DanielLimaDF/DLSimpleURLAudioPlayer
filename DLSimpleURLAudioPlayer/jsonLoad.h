//
//  jsonLoad.h
//  DLSimpleURLAudioPlayer
//
//  Created by Daniel Lima on 12/11/15.
//  Copyright © 2015 dl. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Audio.h"
#import <UIKit/UIKit.h>

@protocol loaderAudioDelegate
- (void)loaderAudioDone;
@end

@interface jsonLoad : NSObject{
    id <NSObject, loaderAudioDelegate > delegate;
    int totalAudios;
    int audioCount;
}

@property (nonatomic, retain) NSMutableData *loadedData;
@property (nonatomic, retain) NSMutableDictionary *registerDictionary;
@property (nonatomic, retain) NSMutableArray *audioList;

@property (retain) id <NSObject, loaderAudioDelegate > delegate;

-(id)init;
-(void)loadAudios;
-(void)loadOffline;

-(void)audioItemLoaded;

-(void)saveImage:(UIImage *)img whithName:(NSString*)fileName;

@end
