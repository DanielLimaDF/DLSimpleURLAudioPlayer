//
//  ViewController.m
//  DLSimpleURLAudioPlayer
//
//  Created by Daniel Lima on 12/11/15.
//  Copyright © 2015 dl. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()

@end

@implementation ViewController
@synthesize loader;
@synthesize audioList;
@synthesize table;

@synthesize distanceDownloadTop;
@synthesize songDownloader;
@synthesize internetAvailability;
@synthesize statusWeb;

- (void)viewDidLoad {
    
    loader = [[jsonLoad alloc]init];
    loader.delegate = self;
    
    audioList = [[NSMutableArray alloc]init];
    
    songDownloader = [[AudioDownloader alloc]init];
    songDownloader.delegate = self;
    
    [self testInternetConnection];
    
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
}

-(void)viewWillAppear:(BOOL)animated{
    self.navigationController.navigationBar.hidden = YES;
    [super viewWillAppear:animated];
}

-(void)viewDidAppear:(BOOL)animated{
    
    [super viewDidAppear:animated];
}




- (void)testInternetConnection{
    internetAvailability = [Reachability reachabilityWithHostname:@"dlsimpleurlaudioplayer.42noticias.mobi"];
    
    // Internet is reachable
    internetAvailability.reachableBlock = ^(Reachability*reach)
    {
        // Update the UI on the main thread
        dispatch_async(dispatch_get_main_queue(), ^{
            NSLog(@"Yayyy, we have the interwebs!");
            
            statusWeb = [NSNumber numberWithInt:1];
            
            [loader loadAudios];
            [songDownloader startDownload];
            
        });
    };
    
    // Internet is not reachable
    internetAvailability.unreachableBlock = ^(Reachability*reach)
    {
        // Update the UI on the main thread
        dispatch_async(dispatch_get_main_queue(), ^{
            NSLog(@"Someone broke the internet :(");
            
            statusWeb = [NSNumber numberWithInt:2];
            
            [loader loadOffline];
            [self audioDonwloaderDone];
            
        });
    };
    
    [internetAvailability startNotifier];
}





//Table BEGIN
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [audioList count];
}

- (CGFloat)tableView:(UITableView*)tableView heightForHeaderInSection:(NSInteger)section{
    return UITableViewAutomaticDimension;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section{
    
    NSString *sectionName = @"Audio List";
    
    return sectionName;
    
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    return 97;
    
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    UITableViewCell *cell;
    
    Audio *currentAutio = audioList[indexPath.row];
    
    cell = [tableView dequeueReusableCellWithIdentifier:@"cell" forIndexPath:indexPath];
    
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"cell"];
    }
    
    UIImageView *cover =  (UIImageView *)[cell viewWithTag:1];
    UILabel *title =  (UILabel *)[cell viewWithTag:2];
    UILabel *author =  (UILabel *)[cell viewWithTag:3];
    
    if([currentAutio.cover isKindOfClass:[NSNull class]]){
        [cover setImage:[UIImage imageNamed:@"imagemAlbunArtista.png"]];
    }else{
        
        [cover setImage:[self loadImageFromLocalFile:currentAutio.coverFileName]];
        
    }
    
    [title setText:currentAutio.title];
    [author setText:currentAutio.author];
    
    return cell;
}


-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    if(indexPath.section == 0){
        
        selectedAudio = indexPath.row;
        [self performSegueWithIdentifier:@"goAudioPlayerGo" sender:table];
        
    }
}
//Table END

//Audio loader delegate
- (void)loaderAudioDone{
    NSLog(@"Audio loader complete");
    
    audioList = loader.audioList;
    
    //[table reloadData];
    dispatch_async(dispatch_get_main_queue(), ^{
        [table reloadData];
    });
    
}

- (UIImage*)loadImageFromLocalFile:(NSString *)file{
    
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
    NSString *libraryCacheDirectory = [paths objectAtIndex:0];
    NSString* path = [libraryCacheDirectory stringByAppendingPathComponent:[NSString stringWithFormat: @"%@",file]];
    UIImage* image = [UIImage imageWithContentsOfFile:path];
    return image;
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (void)audioDonwloaderDone{
    
    [self.view layoutIfNeeded];
    
    distanceDownloadTop.constant = 1000;
    [UIView animateWithDuration:.4
                     animations:^{
                         [self.view layoutIfNeeded]; // Called on parent view
                     }];
    
}




#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
    
    if ([[segue identifier] isEqualToString:@"goAudioPlayerGo"]) {
        
        DLSimpleURLAudioPlayerViewController *playerView = [segue destinationViewController];
        playerView.audioList = audioList;
        [playerView setSelectedAudio:selectedAudio];
        
    }
    
    
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}

@end
