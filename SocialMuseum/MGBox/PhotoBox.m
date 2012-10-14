//
//  PhotoBox.m
//  SocialMuseum
//
//  Created by Giuseppe Lapenta on 12/10/12.
//  Copyright (c) 2012 Lapenta. All rights reserved.
//

#import "PhotoBox.h"
#import "API.h"
#import "UIImage+Resize.h"

@implementation PhotoBox

#define IPHONE_PORTRAIT_PHOTO  (CGSize){120, 112}

#define kPadding 4

#pragma mark - Init

- (void)setup {
    
    // positioning
    self.topMargin = 8;
    self.leftMargin = 8;
    
    // background
    self.backgroundColor = [UIColor colorWithRed:0.94 green:0.94 blue:0.95 alpha:1];
    
    // shadow
    self.layer.shadowColor = [UIColor colorWithWhite:0.12 alpha:1].CGColor;
    self.layer.shadowOffset = CGSizeMake(0, 0.5);
    self.layer.shadowRadius = 1;
    self.layer.shadowOpacity = 1;
}

+ (PhotoBox *)photoProfileBoxWithView:(UIView*)view andSize:(CGSize)size {
    
    // box with photo number tag
    PhotoBox *box = [PhotoBox boxWithSize:size];
    box.topMargin = 0;
    box.leftMargin = 0;
        
    [box addSubview:view];
    view.size = box.size;
    view.center = (CGPoint){box.width / 2, box.height / 2};
    view.alpha = 0.2;
    view.autoresizingMask = UIViewAutoresizingFlexibleTopMargin
    | UIViewAutoresizingFlexibleRightMargin
    | UIViewAutoresizingFlexibleBottomMargin
    | UIViewAutoresizingFlexibleLeftMargin;
    
    [UIView animateWithDuration:0.2 animations:^{
        view.alpha = 1;
    }];

    
    return box;
}

+ (PhotoBox *)photoProfileOptionPhoto:(NSNumber *)idPhoto{
    
    PhotoBox *box = [PhotoBox boxWithSize:IPHONE_PORTRAIT_PHOTO];
    box.topMargin = 0;
    box.leftMargin = 40;
    
    box.tag = [idPhoto integerValue];
    
    // add a loading spinner
    UIActivityIndicatorView *spinner = [[UIActivityIndicatorView alloc]
                                        initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
    spinner.center = CGPointMake(box.width / 2, box.height / 2);
    spinner.autoresizingMask = UIViewAutoresizingFlexibleTopMargin
    | UIViewAutoresizingFlexibleRightMargin
    | UIViewAutoresizingFlexibleBottomMargin
    | UIViewAutoresizingFlexibleLeftMargin;
    spinner.color = UIColor.lightGrayColor;
    [box addSubview:spinner];
    [spinner startAnimating];
    
    // do the photo loading async, because internets
    __block id bbox = box;
    box.asyncLayoutOnce = ^{
        [bbox loadPhoto];
    };
    
    return box;
    
}

+ (PhotoBox *)photoProfileOptionAdvice{
    
    PhotoBox *box = [PhotoBox boxWithSize:IPHONE_PORTRAIT_PHOTO];
    box.topMargin = 0;
    box.leftMargin = 0;
    
    
    UIView * view = [[UIView alloc] initWithFrame:box.frame];
    view.backgroundColor = [UIColor whiteColor];
    
    
    UIImageView* imageView = [[UIImageView alloc] initWithFrame:CGRectMake(view.origin.x + kPadding, view.origin.y + kPadding, 120 - 2*kPadding, 100 - 2*kPadding)];
    
    UIImage *image = [UIImage imageNamed:@"consigli.png"];
    
    UIImage* scaledImage = [image resizedImageWithContentMode:UIViewContentModeScaleAspectFill
                                                       bounds:CGSizeMake(imageView.frame.size.width, imageView.frame.size.height)
                                         interpolationQuality:kCGInterpolationHigh];
    
    UIImage *croppedImage = [scaledImage croppedImage:CGRectMake((scaledImage.size.width -imageView.frame.size.width)/2, (scaledImage.size.height -imageView.frame.size.height)/2, imageView.frame.size.width, imageView.frame.size.height)];
    
    imageView.image = croppedImage;
    
    [view addSubview:imageView];
    imageView.autoresizingMask = UIViewAutoresizingFlexibleWidth
    | UIViewAutoresizingFlexibleHeight;
    
    UILabel* captionLabel = [[UILabel alloc] initWithFrame:CGRectMake(view.origin.x, view.origin.y + imageView.size.height, view.size.width, view.size.height - imageView.size.height)];
    captionLabel.font = [UIFont boldSystemFontOfSize:12.0];
    captionLabel.textAlignment = UITextAlignmentCenter;
    captionLabel.numberOfLines = 0;
    captionLabel.text = @"Consigli";
    [view addSubview:captionLabel];
    
    [box addSubview:view];
    
    return box;
}

#pragma mark - Layout

- (void)layout {
    [super layout];
    
    // speed up shadows
    self.layer.shadowPath = [UIBezierPath bezierPathWithRect:self.bounds].CGPath;
}

#pragma mark - Photo box loading

- (void)loadPhoto {
        
    //Carica l'img
        API* api = [API sharedInstance];
    
        NSInteger IdPhoto = self.tag;
    
        NSURL* imageURL = [api urlForImageWithId:[NSNumber numberWithInteger:IdPhoto] isThumb:YES];
    
        AFImageRequestOperation* imageOperation = [AFImageRequestOperation imageRequestOperationWithRequest: [NSURLRequest requestWithURL:imageURL] success:^(UIImage *image) {
            
            // ditch the spinner
            UIActivityIndicatorView *spinner = self.subviews.lastObject;
            [spinner stopAnimating];
            [spinner removeFromSuperview];
            
        //Crea ImageView e l'aggiunge alla vista
        UIImageView* thumbView = [[UIImageView alloc] initWithImage: image];
            [self addSubview:thumbView];
            thumbView.size = self.size;
            thumbView.alpha = 0;
            thumbView.autoresizingMask = UIViewAutoresizingFlexibleWidth
            | UIViewAutoresizingFlexibleHeight;
            
            // fade the image in
            [UIView animateWithDuration:0.2 animations:^{
                thumbView.alpha = 1;
            }];

    }];
    NSOperationQueue* queue = [[NSOperationQueue alloc] init];
    [queue addOperation:imageOperation];
    
}



@end
