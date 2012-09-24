//
//  StreamScreen+Private.m
//  SocialMuseum
//
//  Created by Giuseppe Lapenta on 24/09/12.
//  Copyright (c) 2012 Lapenta. All rights reserved.
//

#import "StreamScreen+Private.h"
#import "API.h"

#define kNumberOfPhotos 25

@implementation StreamScreen (Private)

-(void)imagesFromArtWork:(NSNumber *)idArtwork
{   
   /* [[API sharedInstance] commandWithParams:[NSMutableDictionary dictionaryWithObjectsAndKeys:@"stream", @"command",idArtwork,@"IdOpera", nil] onCompletion:^(NSDictionary *json) {
        //Mostra lo stream
        NSArray* images = [json objectForKey:@"result"];
        
        for (int i = 0; i < images.count; i++) {
            
            UIImageView *imageView = [_items objectAtIndex:i];
            NSDictionary* photo = [images objectAtIndex:i];
            int IdPhoto = [[photo objectForKey:@"IdPhoto"] intValue];
            NSURL* imageURL = [[API sharedInstance] urlForImageWithId:[NSNumber numberWithInt: IdPhoto] isThumb:YES];
            AFImageRequestOperation* imageOperation = [AFImageRequestOperation imageRequestOperationWithRequest: [NSURLRequest requestWithURL:imageURL] success:^(UIImage *image) {
                //Crea ImageView e l'aggiunge alla vista
                imageView.frame = CGRectMake(0, 0, image.size.width, image.size.height);
                
                [self performSelector:@selector(animateUpdate:) 
                           withObject:[NSArray arrayWithObjects:imageView, image, nil]
                           afterDelay:0.2 + (arc4random()%3) + (arc4random() %10 * 0.1)];            }];
            NSOperationQueue* queue = [[NSOperationQueue alloc] init];
            [queue addOperation:imageOperation];
        }
        
	}];*/
}


- (void)asyncDataLoadingForArtWork:(NSNumber *)idArtwork
{
  //  _items = [NSArray array];
    //load the placeholder image
    for (int i=0; i < kNumberOfPhotos; i++) {
        UIImageView *imageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"placeholder2.png"]];
        imageView.frame = CGRectMake(0, 0, 44, 44);
        imageView.clipsToBounds = YES;
     //   _items = [_items arrayByAddingObject:imageView];
    }
   // [self reloadData];
    [self imagesFromArtWork:idArtwork];
}

- (void) animateUpdate:(NSArray*)objects
{
  /*  UIImageView *imageView = [objects objectAtIndex:0];
    UIImage* image = [objects objectAtIndex:1];
    [UIView animateWithDuration:0.5 
                     animations:^{
                         imageView.alpha = 0.f;
                     } completion:^(BOOL finished) {
                         imageView.image = image;
                         [UIView animateWithDuration:0.5
                                          animations:^{
                                              imageView.alpha = 1;
                                          } completion:^(BOOL finished) {
                                              NSArray *visibleRowInfos =  [self visibleRowInfos];
                                              for (RowInfo *rowInfo in visibleRowInfos) {
                                                  [self updateLayoutWithRow:rowInfo animated:YES];
                                              }
                                          }];
                     }];*/
}



@end
