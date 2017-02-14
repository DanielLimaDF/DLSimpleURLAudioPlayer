//
//  jsonLoad.m
//  DLSimpleURLAudioPlayer
//
//  Created by Daniel Lima on 12/11/15.
//  Copyright © 2015 dl. All rights reserved.
//

#import "jsonLoad.h"

@implementation jsonLoad
@synthesize loadedData;
@synthesize registerDictionary;
@synthesize audioList;
@synthesize delegate;

#define kBgQueue dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)

-(id)init {
    
    totalAudios = 0;
    audioCount = 0;
    
    loadedData = [[NSMutableData alloc]init];
    registerDictionary = [[NSMutableDictionary alloc]init];
    audioList = [[NSMutableArray alloc]init];
    
    return self;
}


-(void)loadAudios{
    
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
    
    [request setURL:[NSURL URLWithString:[NSString stringWithFormat:@"http://dlsimpleurlaudioplayer.42noticias.mobi/audios.php"]]];
    
    [request setHTTPMethod:@"POST"];
    
    [request setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];
    [request setValue:@"UTF-8" forHTTPHeaderField:@"Accept-Charset"];
    
    NSURLSession *session = [NSURLSession sharedSession];
    NSURLSessionDataTask *dataTask = [session dataTaskWithRequest:request
                                                completionHandler:^(NSData *data, NSURLResponse *response, NSError *error)
                                      {
                                          // do something with the data
                                          
                                          NSLog(@"Data loaded");
                                          
                                          [loadedData appendData:data];
                                          registerDictionary = [NSJSONSerialization
                                                      JSONObjectWithData:loadedData
                                                      options:NSJSONReadingMutableContainers|NSJSONReadingMutableLeaves
                                                      error:&error];
                                          
                                          
                                          
                                          
                                          //Store data for offline usage:
                                          [[NSUserDefaults standardUserDefaults] setObject:data forKey:@"offlineJson"];
                                          
                                          
                                          
                                          
                                          if( error ){
                                              NSLog(@"%@", [error localizedDescription]);
                                          }else{
                                              
                                              
                                              NSMutableArray *result = [[NSMutableArray alloc]init];
                                              result = registerDictionary[@"data"];
                                              
                                              NSNumber *acount = [NSNumber numberWithInteger:[result count]];
                                              
                                              totalAudios = [acount intValue];
                                              
                                              //Create audio list
                                              for (int i = 0; i < [result count]; i++) {
                                                  
                                                  NSDictionary *currentData = result[i];
                                                  
                                                  Audio *a = [[Audio alloc]init];
                                                  
                                                  a.audioURL = currentData[@"fileUrl"];
                                                  a.title = currentData[@"title"];
                                                  a.author = currentData[@"author"];
                                                  a.cover = currentData[@"cover"];
                                                  
                                                  
                                                  //Cache cover image
                                                  
                                                  if(![a.cover isKindOfClass:[NSNull class]]){
                                                  
                                                      NSString *fileName = [a.cover lastPathComponent];
                                                  
                                                      a.coverFileName = fileName;
                                                  
                                                      NSArray *pathsUsr = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
                                                      NSString *cacheUsr = [pathsUsr objectAtIndex:0];
                                                      NSString* arquivoLocal = [cacheUsr stringByAppendingPathComponent:fileName];
                                                      BOOL fileExists = [[NSFileManager defaultManager] fileExistsAtPath:arquivoLocal];
                                                  
                                                      if(fileExists){
                                                          //Not necessary to store, file already exists
                                                      
                                                          //Call completion
                                                          [self audioItemLoaded];
                                                      
                                                      }else{
                                                      
                                                          dispatch_async(kBgQueue, ^{
                                                              NSData *imgData2 = [NSData dataWithContentsOfURL:[NSURL URLWithString:a.cover]];
                                                              if (imgData2) {
                                                                  UIImage *imagem = [UIImage imageWithData:imgData2];
                                                                  if (imagem) {
                                                                      dispatch_async(dispatch_get_main_queue(), ^{
                                                                      
                                                                          //Save the image
                                                                          [self saveImage:imagem whithName:fileName];
                                                                          [self audioItemLoaded];
                                                                      
                                                                      });
                                                                  }
                                                              }else{
                                                                  NSLog(@"It was not possible to load the cover");
                                                              }
                                                          });
                                                      
                                                      
                                                      }
                                                  
                                                  
                                                  }else{
                                                      [self audioItemLoaded];
                                                  }
                                                  
                                                  [audioList addObject:a];
                                                  
                                              }
                                          }
                                          
                                          //[delegate loaderAudioDone];
                                          
                                      }];
    [dataTask resume];
}




-(void)loadOffline{
    
    NSData *storedData = [[NSUserDefaults standardUserDefaults] dataForKey:@"offlineJson"];
    
    NSError *error;
    
    [loadedData appendData:storedData];
    registerDictionary = [NSJSONSerialization
                          JSONObjectWithData:loadedData
                          options:NSJSONReadingMutableContainers|NSJSONReadingMutableLeaves
                          error:&error];
    
    if( error ){
        NSLog(@"%@", [error localizedDescription]);
    }else{
        
        
        
        
        NSMutableArray *result = [[NSMutableArray alloc]init];
        result = registerDictionary[@"data"];
        
        NSNumber *acount = [NSNumber numberWithInteger:[result count]];
        
        totalAudios = [acount intValue];
        
        //Create audio list
        for (int i = 0; i < [result count]; i++) {
            
            NSDictionary *currentData = result[i];
            
            Audio *a = [[Audio alloc]init];
            
            a.audioURL = currentData[@"fileUrl"];
            a.title = currentData[@"title"];
            a.author = currentData[@"author"];
            a.cover = currentData[@"cover"];
            
            if(![a.cover isKindOfClass:[NSNull class]]){
                
                NSString *fileName = [a.cover lastPathComponent];
                a.coverFileName = fileName;
                
            }
            
            [self audioItemLoaded];
            
            [audioList addObject:a];
            
        }
        
        
        
        
    }
    
    
    
    
}







-(void)audioItemLoaded{
    
    audioCount++;
    
    if(totalAudios == audioCount){
        
        [delegate loaderAudioDone];
        
    }
}

-(void)saveImage:(UIImage *)img whithName:(NSString*)fileName{
    if (img != nil){
            NSArray *paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
            NSString *libraryCacheDirectory = [paths objectAtIndex:0];
            NSString *path = [libraryCacheDirectory stringByAppendingPathComponent:fileName];
            NSData *imageData = UIImagePNGRepresentation(img);
            [imageData writeToFile:path atomically:YES];
    }
}

@end
