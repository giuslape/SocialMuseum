//
//  AddContentViewController.m
//  SocialMuseum
//
//  Created by Giuseppe Lapenta on 14/11/12.
//  Copyright (c) 2012 Lapenta. All rights reserved.
//

#import "AddContentViewController.h"
#import "MGBox.h"
#import "MGButton.h"
#import "MGScrollView.h"
#import "MGTableBoxStyled.h"
#import "MGLine.h"
#import "ArtWork.h"
#import "API.h"
#import "UIAlertView+error.h"
#import "MBProgressHUD.h"
#import "AppDelegate.h"

#define IPHONE_TABLES_GRID      (CGSize){320, 0}

#define TEXT_FONT               [UIFont fontWithName:@"HelveticaNeue" size:12]
#define FOOTER_FONT             [UIFont fontWithName:@"HelveticaNeue" size:14]



@implementation AddContentViewController{
    
    MGBox* containerBox, *commentBox, *photoBox;
    MGBox* submitCommentBox, *submitPhotoBox;
    NSString* commentToUpload;
    UITextField* commentTextField;
}

@synthesize artWork;
@synthesize delegate;

#pragma mark -
#pragma mark ===  Init Methods  ===
#pragma mark -

- (void)viewDidLoad
{
    
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor colorWithPatternImage:[[UIImage imageNamed:@"texture.jpg"] resizableImageWithCapInsets:UIEdgeInsetsMake(10, 10, 10, 10)]];
    
    self.scroller.contentLayoutMode = MGLayoutGridStyle;
    self.scroller.bottomPadding = 8;
    
    containerBox = [MGBox boxWithSize:IPHONE_TABLES_GRID];
    containerBox.contentLayoutMode = MGLayoutGridStyle;
    [self.scroller.boxes addObject:containerBox];

    commentBox = MGBox.box;
    [containerBox.boxes addObject:commentBox];
    commentBox.sizingMode = MGResizingShrinkWrap;
    
    [containerBox layout];
    
    [self drawLayoutComment];
    
    submitCommentBox = [MGBox boxWithSize:(CGSize){208,35}];
    submitCommentBox.fixedPosition = (CGPoint){commentBox.origin.x + commentBox.width/2 - submitCommentBox.width/2 + 8, commentBox.origin.y + commentBox.size.height + 8};
    
    UIButton* submitCommentBtn = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    submitCommentBtn.size = (CGSize){200,30};
    
    // Btn Title
    [submitCommentBtn setTitle:@"Lascia un commento" forState:UIControlStateNormal];
    [submitCommentBtn.titleLabel setFont:TEXT_FONT];
    [submitCommentBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    
    // Btn Background
    [submitCommentBtn setBackgroundImage:[[UIImage imageNamed:@"texture.jpg"]
                                         resizableImageWithCapInsets:UIEdgeInsetsMake(10, 10, 10, 10)] forState:UIControlStateNormal];
    
    // Btn shadow
    submitCommentBtn.layer.shadowColor = [UIColor blackColor].CGColor;
    submitCommentBtn.layer.shadowOpacity = 0.5;
    submitCommentBtn.layer.shadowRadius = 1;
    submitCommentBtn.layer.shadowOffset = CGSizeMake(2.0f, 2.0f);
    
    // Btn Border
    submitCommentBtn.layer.borderWidth = 0.35f;
    submitCommentBtn.layer.borderColor = [UIColor grayColor].CGColor;
    
    // Btn action
    [submitCommentBtn addTarget:self action:@selector(uploadComment) forControlEvents:UIControlEventTouchUpInside];
    
    [submitCommentBox addSubview:submitCommentBtn];
    [self.scroller.boxes addObject:submitCommentBox];
    
    [self.scroller layoutWithSpeed:1.0f completion:nil];

    photoBox = MGBox.box;
    [self.scroller.boxes addObject:photoBox];
    photoBox.sizingMode = MGResizingShrinkWrap;
    photoBox.fixedPosition = (CGPoint){0,submitCommentBox.fixedPosition.y + submitCommentBox.size.height};
    
    [self drawLayoutPhoto];
    
    submitPhotoBox = [MGBox boxWithSize:(CGSize){208,35}];
    submitPhotoBox.fixedPosition = (CGPoint){photoBox.origin.x + photoBox.width/2 - submitPhotoBox.width/2 + 8, photoBox.fixedPosition.y + photoBox.size.height + 8};
    
    // Btn init
    UIButton* submitPhotoBtn = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    submitPhotoBtn.size = (CGSize){200,30};
    
    // Btn Title
    [submitPhotoBtn setTitle:@"Carica una Foto" forState:UIControlStateNormal];
    [submitPhotoBtn.titleLabel setFont:TEXT_FONT];
    [submitPhotoBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    
    // Btn Background
    submitPhotoBtn.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"texture.jpg"]];
    [submitPhotoBtn setBackgroundImage:[[UIImage imageNamed:@"texture.jpg"] resizableImageWithCapInsets:UIEdgeInsetsMake(10, 10, 10, 10)] forState:UIControlStateNormal];
    
    // Btn shadow
    submitPhotoBtn.layer.shadowColor = [UIColor blackColor].CGColor;
    submitPhotoBtn.layer.shadowOpacity = 0.5;
    submitPhotoBtn.layer.shadowRadius = 1;
    submitPhotoBtn.layer.shadowOffset = CGSizeMake(2.0f, 2.0f);
    
    // Btn border
    submitPhotoBtn.layer.borderWidth = 0.35f;
    submitPhotoBtn.layer.borderColor = [UIColor grayColor].CGColor;
    
    //Btn action
    [submitPhotoBtn addTarget:self action:@selector(uploadPhoto) forControlEvents:UIControlEventTouchUpInside];

    [submitPhotoBox addSubview:submitPhotoBtn];
    [self.scroller.boxes addObject:submitPhotoBox];
    
    [self.scroller layoutWithSpeed:1.0f completion:nil];

}


#pragma mark -
#pragma mark ===  Orientation  ===
#pragma mark -


- (NSUInteger)supportedInterfaceOrientations{
    
    return UIInterfaceOrientationMaskPortrait;
}

#pragma mark -
#pragma mark ===  Unload  ===
#pragma mark -

- (void)viewDidUnload {
    [self setScroller:nil];
    [super viewDidUnload];
}

#pragma mark -
#pragma mark ===  Memory Warning  ===
#pragma mark -


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark -
#pragma mark ===  Action  ===
#pragma mark -

- (IBAction)cancelDidPress:(id)sender {
    
    [self dismissViewControllerAnimated:YES completion:nil];
}


#pragma mark -
#pragma mark ===  Layout Comment  ===
#pragma mark -

- (void)drawLayoutComment{
    
    MGTableBoxStyled* commentSection = MGTableBoxStyled.box;
    [commentBox.boxes addObject:commentSection];

    commentTextField = [[UITextField alloc] init];
    commentTextField.placeholder = @"Scrivi qui il tuo commento";
    commentTextField.borderStyle = UITextBorderStyleNone;
    commentTextField.size = (CGSize){288, 110};
    commentTextField.font = TEXT_FONT;
    commentTextField.delegate = self;
    commentTextField.keyboardType = UIKeyboardAppearanceDefault;
    
    MGLine* textView = [MGLine lineWithLeft:commentTextField right:nil size:(CGSize){304,126}];
    [commentSection.topLines addObject:textView];
    textView.padding = UIEdgeInsetsMake(8, 8, 8, 8);
    
    MGLine* footerLine = [MGLine lineWithSize:(CGSize){304,35}];
    footerLine.padding = UIEdgeInsetsMake(8, 8, 8, 8);
    [commentSection.topLines addObject:footerLine];
    footerLine.backgroundColor = [UIColor colorWithPatternImage:[[UIImage imageNamed:@"texture.jpg"]resizableImageWithCapInsets:UIEdgeInsetsMake(10, 10, 10, 10)]];
    footerLine.layer.cornerRadius = 3;
    footerLine.middleFont = FOOTER_FONT;
    [footerLine.middleItems addObject:artWork.title];
        
    [self.scroller layoutWithSpeed:0.5f completion:nil];
}


#pragma mark -
#pragma mark ===  Layout Photo  ===
#pragma mark -

- (void)drawLayoutPhoto{
    
    MGTableBoxStyled* photoSection = MGTableBoxStyled.box;
    [photoBox.boxes addObject:photoSection];
    
    UIImageView* imageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"camera.png"] highlightedImage:[UIImage imageNamed:@"camera_sel.png"]];
    imageView.backgroundColor = [UIColor colorWithPatternImage:[[UIImage imageNamed:@"texture.jpg"]resizableImageWithCapInsets:UIEdgeInsetsMake(10, 10, 10, 10)]];
    imageView.size = (CGSize){288,130};
    imageView.contentMode = UIViewContentModeCenter;
    
    MGLine* linePhoto = [MGLine lineWithLeft:imageView right:nil size:(CGSize){304,146}];
    linePhoto.padding = UIEdgeInsetsMake(8, 8, 8, 8);
    [photoSection.topLines addObject:linePhoto];
    
    static bool tap = false;
    
    linePhoto.onTap = ^{
        
        if (!tap) {
            tap = true;
            imageView.highlighted = true;
            
        }else{
            tap = false;
            imageView.highlighted = false;
        }
    };
    linePhoto.onLongPress = ^{
        
        if (!tap) {
            tap = true;
            imageView.highlighted = true;
            
            AppDelegate* appDelegate = [UIApplication sharedApplication].delegate;
            
            [[[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:@"Chiudi" destructiveButtonTitle:nil otherButtonTitles:@"Scegli dalla libreria", @"Scatta Foto", nil]
             showInView:appDelegate.window.rootViewController.view];
            
        }else{
            tap = false;
            imageView.highlighted = false;
        }
        
    };
    
    [self.scroller layoutWithSpeed:0.5f completion:nil];
}


#pragma mark -
#pragma mark ===  Text Field Delegate  ===
#pragma mark -

- (BOOL)textFieldShouldReturn:(UITextField *)textField{
    
    commentToUpload = textField.text;
    
    [textField resignFirstResponder];
    
    return YES;
}

#pragma mark -
#pragma mark ===  Button Methods  ===
#pragma mark -

- (void)uploadComment{
    
    commentToUpload = commentTextField.text;
    
    [commentTextField resignFirstResponder];
    
    MBProgressHUD* hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    hud.dimBackground = YES;
    hud.labelText = @"Carico il Commento";
    
    
    [[API sharedInstance] commandWithParams:[NSMutableDictionary dictionaryWithObjectsAndKeys:@"addComment", @"command",commentToUpload,@"testo",artWork.IdOpera,@"IdOpera",@"0",@"IdChunk",nil] onCompletion:^(NSDictionary *json) {
		//Completamento
		if (![json objectForKey:@"error"]) {
			//Successo
            hud.customView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"37x-Checkmark.png"]];
            hud.mode = MBProgressHUDModeCustomView;
            hud.labelText = @"Completato";
            [hud hide:YES afterDelay:1];
            
            [delegate submitCommentDidPressed:self];
			
		} else {
			//Errore, Cerca se la sessione è scaduta e se l'utente è autorizzato
			NSString* errorMsg = [json objectForKey:@"error"];
			[UIAlertView error:errorMsg];
            [hud hide:YES afterDelay:1];
        }
	}];    
}

- (void)uploadPhoto{
    
    
    
}

@end
