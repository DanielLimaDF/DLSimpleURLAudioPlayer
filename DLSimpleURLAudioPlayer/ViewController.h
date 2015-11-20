//
//  ViewController.h
//  DLSimpleURLAudioPlayer
//
//  Created by Daniel Lima on 12/11/15.
//  Copyright © 2015 dl. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "jsonLoad.h"
#import "Audio.h"
#import "DLSimpleURLAudioPlayerViewController.h"

#import <AVFoundation/AVFoundation.h>

@interface ViewController : UIViewController<UITableViewDataSource, UITableViewDelegate>{
    NSInteger selectedAudio;
}

@property (nonatomic, retain) jsonLoad *loader;
@property (nonatomic, retain) NSMutableArray *audioList;
@property (nonatomic, retain) IBOutlet UITableView *table;

- (void)loaderAudioDone;
- (UIImage*)loadImageFromLocalFile:(NSString *)file;

@end

