//
//  ArtWorkViewController.h
//  SocialMuseum
//
//  Created by Giuseppe Lapenta on 26/01/12.
//  Copyright (c) 2012 Lapenta. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ArtWork.h"

@interface ArtWorkViewController : UIViewController

{
    
    ArtWork* _artWorkToModify;
    
}

@property (weak, nonatomic) IBOutlet UIImageView * artWorkImage;
@property (nonatomic, strong)ArtWork* artWorkToModify;
@property (nonatomic, weak)IBOutlet UILabel* label;



@end
