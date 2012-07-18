//
//  PhotoView.m
//  iReporter
//
//  Created by Giuseppe Lapenta on 9/6/12.
//  Copyright (c) 2012 Giuseppe Lapenta. All rights reserved.
//

#import "PhotoView.h"
#import "API.h"

@implementation PhotoView

@synthesize delegate;

-(id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

-(id)initWithIndex:(int)i andData:(NSDictionary*)data {
    self = [super init];
    if (self !=nil) {
        //Inizializzazione
        self.tag = [[data objectForKey:@"IdPhoto"] intValue];
        int row = i/3;
        int col = i % 3;
        self.frame = CGRectMake(1.5*kPadding+col*(kThumbSide+kPadding), 1.5*kPadding+row*(kThumbSide+kPadding), kThumbSide, kThumbSide);
        self.backgroundColor = [UIColor grayColor];
        //aggiunge la foto
        UILabel* caption = [[UILabel alloc] initWithFrame:CGRectMake(0, kThumbSide-16, kThumbSide, 16)];
        caption.backgroundColor = [UIColor blackColor];
        caption.textColor = [UIColor whiteColor];
        caption.textAlignment = UITextAlignmentCenter;
        caption.font = [UIFont systemFontOfSize:12];
        caption.text = [NSString stringWithFormat:@"@%@",[data objectForKey:@"username"]];
        [self addSubview: caption];
        
        //Aggiunge un evento al tocco
		[self addTarget:delegate action:@selector(didSelectPhoto:) forControlEvents:UIControlEventTouchUpInside];
        
		//Carica l'img
		API* api = [API sharedInstance];
		int IdPhoto = [[data objectForKey:@"IdPhoto"] intValue];
		NSURL* imageURL = [api urlForImageWithId:[NSNumber numberWithInt: IdPhoto] isThumb:YES];
		AFImageRequestOperation* imageOperation = [AFImageRequestOperation imageRequestOperationWithRequest: [NSURLRequest requestWithURL:imageURL] success:^(UIImage *image) {
			//Crea ImageView e l'aggiunge alla vista
			UIImageView* thumbView = [[UIImageView alloc] initWithImage: image];
			[self insertSubview: thumbView belowSubview: caption];
		}];
		NSOperationQueue* queue = [[NSOperationQueue alloc] init];
		[queue addOperation:imageOperation];
    }
    return self;
}

@end
