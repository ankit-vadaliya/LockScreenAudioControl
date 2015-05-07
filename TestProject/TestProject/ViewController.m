//
//  ViewController.m
//  TestProject
//
//  Created by Parth Dobariya on 30/04/15.
//  Copyright (c) 2015 Parth Dobariya. All rights reserved.
//

#import "ViewController.h"
#import <MediaPlayer/MPNowPlayingInfoCenter.h>
#import <MediaPlayer/MPMediaItem.h>
#import <AVFoundation/AVFoundation.h>

@interface ViewController ()

@property(nonatomic, strong) AVQueuePlayer *player;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    [[AVAudioSession sharedInstance] setActive:YES error:nil];
    
    NSError *myErr;
    
    // Initialize the AVAudioSession here.
    if (![[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryPlayback error:&myErr]) {
        NSLog(@"Audio Session error %@, %@", myErr, [myErr userInfo]);
    }
    else
    {
        // Since there were no errors initializing the session, we'll allow begin receiving remote control events
        [[UIApplication sharedApplication] beginReceivingRemoteControlEvents];
    }
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

- (BOOL)canBecomeFirstResponder
{
    return YES;
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [[UIApplication sharedApplication] beginReceivingRemoteControlEvents];
    [self becomeFirstResponder];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [[UIApplication sharedApplication] endReceivingRemoteControlEvents];
    [self resignFirstResponder];
    [super viewWillDisappear:animated];
}

- (void)remoteControlReceivedWithEvent:(UIEvent *)receivedEvent {
    
    if (receivedEvent.type == UIEventTypeRemoteControl) {
        
        switch (receivedEvent.subtype) {
                
            case UIEventSubtypeRemoteControlPlay:
                [self.player play];
                break;
            case UIEventSubtypeRemoteControlPause:
                [self.player pause];
                break;
            case UIEventSubtypeRemoteControlNextTrack:
                NSLog(@"NextTrack Button Pressed");
                break;
            case UIEventSubtypeRemoteControlPreviousTrack:
                NSLog(@"PreviousTrack Button Pressed");
                break;
            case UIEventSubtypeRemoteControlTogglePlayPause:
                if (self.player.status == MPMoviePlaybackStatePlaying) {
                    [self.player pause];
                }
                else {
                    [self.player play];
                }
                break;
            default:
                break;
        }
    }
}

- (IBAction)showMediaPicker:(id)sender
{
    MPMediaPickerController *mediaPicker = [[MPMediaPickerController alloc] initWithMediaTypes: MPMediaTypeAny];
    
    mediaPicker.delegate = self;
    mediaPicker.allowsPickingMultipleItems = YES;
    mediaPicker.prompt = @"Select songs to play";
    
    [self presentViewController:mediaPicker animated:YES completion:nil];
}

- (void) mediaPicker: (MPMediaPickerController *) mediaPicker didPickMediaItems: (MPMediaItemCollection *) mediaItemCollection
{
    if (mediaItemCollection)
    {
        // Get AVAsset
        NSURL* assetUrl = [mediaItemCollection.representativeItem valueForProperty:MPMediaItemPropertyAssetURL];
        AVURLAsset* asset = [AVURLAsset URLAssetWithURL:assetUrl options:nil];
        
        // Create player item
        AVPlayerItem* playerItem = [AVPlayerItem playerItemWithAsset:asset];
        
        // Play it
        self.player = [[AVQueuePlayer alloc] initWithPlayerItem:playerItem];
        [self.player play];
        
        Class playingInfoCenter = NSClassFromString(@"MPNowPlayingInfoCenter");
        
        if (playingInfoCenter)
        {
            NSMutableDictionary *songInfo = [[NSMutableDictionary alloc] init];
            
            [songInfo setObject:[mediaItemCollection.representativeItem valueForProperty:MPMediaItemPropertyPlaybackDuration] forKey:MPMediaItemPropertyPlaybackDuration];
            
            [songInfo setObject:[mediaItemCollection.representativeItem valueForProperty:MPMediaItemPropertyTitle] forKey:MPMediaItemPropertyTitle];
            
            [songInfo setObject:[mediaItemCollection.representativeItem valueForProperty:MPMediaItemPropertyAlbumArtist] forKey:MPMediaItemPropertyArtist];
            
            [songInfo setObject:[mediaItemCollection.representativeItem valueForProperty:MPMediaItemPropertyAlbumTitle] forKey:MPMediaItemPropertyAlbumTitle];
            
            [songInfo setObject:[mediaItemCollection.representativeItem valueForProperty:MPMediaItemPropertyArtwork] forKey:MPMediaItemPropertyArtwork];
            
            [[MPNowPlayingInfoCenter defaultCenter] setNowPlayingInfo:songInfo];
        }
    }
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void) mediaPickerDidCancel: (MPMediaPickerController *) mediaPicker
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end
