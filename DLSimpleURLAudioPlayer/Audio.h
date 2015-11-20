//
//  Audio.h
//  DLSimpleURLAudioPlayer
//
//  Created by Daniel Lima on 12/11/15.
//  Copyright © 2015 dl. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Audio : NSObject{
    
}

@property (nonatomic,retain) NSString *audioURL;
@property (nonatomic,retain) NSString *title;
@property (nonatomic,retain) NSString *author;
@property (nonatomic,retain) NSString *cover;
@property (nonatomic,retain) NSString *coverFileName;

-(id)init;

@end