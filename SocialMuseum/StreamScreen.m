//
//  StreamScreen.m
//  iReporter
//
//  Created by Giuseppe Lapenta on 10/02/2012.
//  Copyright (c) 2012 Giuseppe Lapenta. All rights reserved.
//

#import "StreamScreen.h"
#import "API.h"
#import "PhotoView.h"
#import "StreamPhotoScreen.h"
#import "PhotoScreen.h"

@interface StreamScreen(private)

-(void)refreshStream;
-(void)showStream:(NSArray*)stream;

@end

@implementation StreamScreen

@synthesize IdOpera;

#pragma mark - View lifecycle

-(void)viewDidLoad {
    [super viewDidLoad];
    self.navigationItem.rightBarButtonItem = btnCompose;
    self.navigationItem.title = @"Foto";
    //Mostra lo stream delle foto
	[self refreshStream];
}

    
-(BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

-(IBAction)btnRefreshTapped {
	[self refreshStream];
}

-(void)refreshStream {
    [[API sharedInstance] commandWithParams:[NSMutableDictionary dictionaryWithObjectsAndKeys:@"stream", @"command",IdOpera,@"IdOpera", nil] onCompletion:^(NSDictionary *json) {
        //Mostra lo stream
		[self showStream:[json objectForKey:@"result"]];
	}];
}

-(void)showStream:(NSArray*)stream {
    // Rimuove le vecchie foto
    for (UIView* view in listView.subviews) {
        [view removeFromSuperview];
    }
    // Aggiunge le nuove
    for (int i=0;i<[stream count];i++) {
        NSDictionary* photo = [stream objectAtIndex:i];
        PhotoView* photoView = [[PhotoView alloc] initWithIndex:i andData:photo];
        photoView.delegate = self;
        [listView addSubview: photoView];
    }    
    // Aggiorna la lista degli scroll
    int listHeight = ([stream count]/3 + 1)*(kThumbSide+kPadding);
    [listView setContentSize:CGSizeMake(320, listHeight)];
    [listView scrollRectToVisible:CGRectMake(0, 0, 10, 10) animated:YES];
}

-(void)didSelectPhoto:(PhotoView*)sender {
    //Foto selezionata mostra in full screen
    [self performSegueWithIdentifier:@"ShowPhoto" sender:[NSNumber numberWithInt:sender.tag]];   
}

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([@"ShowPhoto" compare: segue.identifier]==NSOrderedSame) {
        StreamPhotoScreen* streamPhotoScreen = segue.destinationViewController;
        streamPhotoScreen.IdPhoto = sender;
    }
    if ([@"ShowScreen" compare: segue.identifier] == NSOrderedSame) {
        PhotoScreen* photoScreen = segue.destinationViewController;
        photoScreen.IdOpera = self.IdOpera;
    }
}

@end
