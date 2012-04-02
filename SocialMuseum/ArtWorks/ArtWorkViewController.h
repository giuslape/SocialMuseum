//
//  ArtWorkViewController.h
//  SocialMuseum
//
//  Created by Vincenzo Lapenta on 26/01/12.
//  Copyright (c) 2012 Lapenta. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ArtWork.h"

@interface ArtWorkViewController : UIViewController

{
    NSMutableArray* _artWorks; 
    
    ArtWork* _artWorkToModify;
    
    
}

@property (nonatomic, strong)NSMutableArray* artWorks;
@property (weak, nonatomic) IBOutlet UIImageView * artWorkImage;
@property (nonatomic, strong)ArtWork* artWorkToModify;


@end
