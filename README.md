# DLSimpleURLAudioPlayer

License: MIT

Platform: iOs

##Very simple way to play audios from urls in iOs

DLSimpleURLAudioPlayer can play audios files from urls using `AVPlayer`. You can set the artist's name , audio name and cover art.

####The Player View Controller (DLSimpleURLAudioPlayerViewController)

iPhone 5s<br>
![Alt][screenshot2]

iPad<br>
![Alt][screenshot1]

[screenshot1]: https://github.com/DanielLimaDF/DLSimpleURLAudioPlayer/blob/master/Screenshots/ipad_1.png
[screenshot2]: https://github.com/DanielLimaDF/DLSimpleURLAudioPlayer/blob/master/Screenshots/iphone5s1.png

####Device Control Center

iPhone<br>
![Alt][screenshot3]

iPad<br>
![Alt][screenshot4]

[screenshot3]: https://github.com/DanielLimaDF/DLSimpleURLAudioPlayer/blob/master/Screenshots/iphone6s2.PNG
[screenshot4]: https://github.com/DanielLimaDF/DLSimpleURLAudioPlayer/blob/master/Screenshots/ipad_3.jpg

####Device Lock Screen

iPhone 6<br>
![Alt][screenshot5]

iPad<br>
![Alt][screenshot6]

[screenshot5]: https://github.com/DanielLimaDF/DLSimpleURLAudioPlayer/blob/master/Screenshots/iphone6s1.png
[screenshot6]: https://github.com/DanielLimaDF/DLSimpleURLAudioPlayer/blob/master/Screenshots/ipad_2.jpg

## Usage

DLSimpleURLAudioPlayer is designed to work with a View Controller. Simply create a `Segue` to DLSimpleURLAudioPlayerViewController and enter the audio queue to be executed along with the first audio to be played by AvPlayer

```obj-c


//You can, for example, create a vector of Audio objects somewhere

NSInteger CurrentSelectAudio = 0;
    
NSMutableArray *YourArrayAudioList = [[NSMutableArray alloc]init];
    
Audio *song1 = [[Audio alloc]init];
Audio *song2 = [[Audio alloc]init];
Audio *song3 = [[Audio alloc]init];
    
//Set info:
[song1 setTitle:@"Title 1"];
[song1 setAuthor:@"Artist name"];
[song1 setCover:@"http://yoururl.com/youraudiofile1.mp3"];
    
[song2 setTitle:@"Title 2"];
[song2 setAuthor:@"Artist name"];
[song2 setCover:@"http://yoururl.com/youraudiofile2.mp3"];
    
[song3 setTitle:@"Title 3"];
[song3 setAuthor:@"Artist name"];
[song3 setCover:@"http://yoururl.com/youraudiofile3.mp3"];
    
//Add to array
[YourArrayAudioList addObject:song1];
[YourArrayAudioList addObject:song2];
[YourArrayAudioList addObject:song3];

//Pass the array and the current audio index via prepareForSegue
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
    if ([[segue identifier] isEqualToString:@"goAudioPlayerGo"]) {
        DLSimpleURLAudioPlayerViewController *playerView = [segue destinationViewController];
        playerView.audioList = YourArrayAudioList;
        [playerView setSelectedAudio:CurrentSelectAudio];
    }
}
```

I recommend that you download and run the project to better understand how it works.

## License

DLSimpleURLAudioPlayer is available under the MIT license. See the LICENSE file for more info.

## Notes

The songs and the audiobook used as an example in this project are Public Domain in Brazil. They were obtained on http://www.dominiopublico.gov.br/
