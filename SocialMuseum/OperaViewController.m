//
//  OperaViewController.m
//  SocialMuseum
//
//  Created by Giuseppe Lapenta on 05/06/12.
//  Copyright (c) 2012 Lapenta. All rights reserved.
//

#import "OperaViewController.h"
#import "StreamScreen.h"
#import "API.h"
#import "ChunkViewController.h"
#import "UpdateViewController.h"
#import "ArtWork.h"
#import "MGScrollView.h"
#import "MGTableBoxStyled.h"
#import "MGLine.h"
#import "PhotoBox.h"
#import "MBProgressHUD.h"

#define IPHONE_TABLES_GRID     (CGSize){320, 0}
#define IPHONE_PORTRAIT_PHOTO  (CGSize){288, 136}

#define ROW_IMAGE_ARTWORK      (CGSize){304, 152}


#define LINE_FONT            [UIFont fontWithName:@"HelveticaNeue" size:12]


@interface OperaViewController ()

-(void)showPhotos:(NSArray *)stream;

@end


#define kThumb 30
#define kPad 3

@implementation OperaViewController{
    
    ArtWork* artwork;
    MGBox *tablesGrid, *tableContent, *tablePhotos, *tableComments;
    NSArray* chuncks;
    
    UIImage* arrow;
}


- (void)viewDidLoad
{
    [super viewDidLoad];
    
    arrow = [UIImage imageNamed:@"arrow.png"];
    chuncks = [NSArray array];
    
    artwork = [[API sharedInstance] temporaryArtWork];
    self.view.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"texture.jpg"]];

    self.navigationItem.title = artwork.title;
    
    MBProgressHUD* hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    [hud setLabelText:@"Loading"];
    hud.dimBackground = YES;

    self.scroller.contentLayoutMode = MGLayoutTableStyle;
    self.scroller.bottomPadding = 8;
    
    CGSize tablesGridSize =  IPHONE_TABLES_GRID;
    tablesGrid = [MGBox boxWithSize:tablesGridSize];
    tablesGrid.contentLayoutMode = MGLayoutGridStyle;
    [self.scroller.boxes addObject:tablesGrid];
    
    tableContent = MGBox.box;
    [tablesGrid.boxes addObject:tableContent];
    tableContent.sizingMode = MGResizingShrinkWrap;
    
    tableComments = MGBox.box;
    [tablesGrid.boxes addObject:tableComments];
    tableComments.sizingMode = MGResizingShrinkWrap;
    
    [tablesGrid layout];
    
    [self loadArtWorkContent];
}


- (void)viewDidUnload
{
    artwork = nil;
    [self setScroller:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

- (void)viewWillAppear:(BOOL)animated{
   
    /*[[API sharedInstance] commandWithParams:[NSMutableDictionary dictionaryWithObjectsAndKeys:@"stream", @"command",_artWork.IdOpera,@"IdOpera", nil]
                               onCompletion:^(NSDictionary *json) {
        //Mostra lo stream
		[self showPhotos:[json objectForKey:@"result"]];
        
        }];*/
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (void)viewDidAppear:(BOOL)animated {
    
    [super viewDidAppear:animated];
    [self willAnimateRotationToInterfaceOrientation:self.interfaceOrientation
                                           duration:1];
}

- (void)willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)orient
                                         duration:(NSTimeInterval)duration {
    
    // relayout the sections
    [self.scroller layoutWithSpeed:duration completion:nil];
}





#pragma mark -
#pragma mark ===  Storyboard  ===
#pragma mark -


-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
    
  /*  if ([@"ShowStream" compare:[segue identifier]] == NSOrderedSame) {
        
        StreamScreen* stream = [segue destinationViewController];
        [stream setArtWork:_artWork];

        self.navigationItem.title = nil;
    }
    
    if ([@"ShowContent" compare:segue.identifier] == NSOrderedSame) {
        
        UITableViewCell* cell = (UITableViewCell *)sender;
        ChunkViewController* chunk = [segue destinationViewController];
        chunk.chunk = cell.textLabel.text;
        chunk.IdChunk = [NSNumber numberWithInt:cell.tag];
        [chunk setIdOpera:_artWork.IdOpera];
    }
    
    if ([@"StreamComment" compare:segue.identifier] == NSOrderedSame) {
        UpdateViewController* update = segue.destinationViewController;
        [update setIdOpera:_artWork.IdOpera];
    }*/
    
}



#pragma mark -
#pragma mark ===  Stream Photo  ===
#pragma mark -

-(void)showPhotos:(NSArray *)stream{
    
   /* for (UIView* view in _photoView.subviews) {
        [view removeFromSuperview];
    }
    API* api = [API sharedInstance];
    
    for (int i=0;i<[stream count];i++) {
        
        NSDictionary* photo = [stream objectAtIndex:i];
        
		int IdPhoto = [[photo objectForKey:@"IdPhoto"] intValue];
        int col = i%8;
        NSURL* imageURL = [api urlForImageWithId:[NSNumber numberWithInt: IdPhoto] isThumb:YES];
		AFImageRequestOperation* imageOperation = [AFImageRequestOperation imageRequestOperationWithRequest: [NSURLRequest requestWithURL:imageURL] success:^(UIImage *image) {
			//Crea ImageView e l'aggiunge alla vista
			UIImageView* thumbView = [[UIImageView alloc] initWithImage: image];
            thumbView.frame = CGRectMake(1.5*kPad+col*(kThumb+kPad), kPad, kThumb, kThumb);
			[_photoView addSubview:thumbView];
		}];
		NSOperationQueue* queue = [[NSOperationQueue alloc] init];
		[queue addOperation:imageOperation];
    }     */
}

#pragma mark -
#pragma mark ===  Artwork Content  ===
#pragma mark -

- (void)loadArtWorkContent{
    
    [[API sharedInstance] commandWithParams:[NSMutableDictionary dictionaryWithObjectsAndKeys:@"content", @"command",artwork.IdOpera,@"IdOpera", nil]
                               onCompletion:^(NSDictionary *json) {
                                   
                                   if (![json objectForKey:@"error"]) {
                                       
                                       chuncks  = [NSArray arrayWithArray:[json objectForKey:@"result"]];
                                       [self dataSourceDidLoad];
                                   }
                                   
    }];
}

- (void)dataSourceDidLoad{
    
    MGTableBoxStyled* art = MGTableBoxStyled.box;
    [tableContent.boxes addObject:art];
    
    MGLine* line = [MGLine lineWithLeft:[self photoBoxForArtwork:artwork.imageUrl] right:nil size:ROW_IMAGE_ARTWORK];
    [art.topLines addObject:line];
    line.padding = UIEdgeInsetsMake(8, 8, 8, 8);
    
    for (NSDictionary* dict in chuncks) {
        
        MGLine* chunckLine = [MGLine lineWithMultilineLeft:[dict objectForKey:@"testo"] right:arrow width:304 minHeight:44];
        [art.topLines addObject:chunckLine];
        chunckLine.padding = UIEdgeInsetsMake(8, 8, 8, 8);
        chunckLine.font = LINE_FONT;
        chunckLine.sidePrecedence = MGSidePrecedenceRight;
    }
    
    [self.scroller layoutWithSpeed:0.3 completion:nil];
    
    [MBProgressHUD hideHUDForView:self.view animated:YES];

}

- (PhotoBox *)photoBoxForArtwork:(NSString *)urlImage{
    
    PhotoBox* box = [PhotoBox photoArtworkWithUrl:urlImage andSize:IPHONE_PORTRAIT_PHOTO];
    
    return box;
}
@end
