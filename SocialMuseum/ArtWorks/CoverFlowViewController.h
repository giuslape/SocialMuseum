//
//  CoverFlowViewController.h
//  SocialMuseum
//
//  Created by Giuseppe Lapenta on 13/12/11.
//  Copyright (c) 2011 Lapenta. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AFOpenFlowView.h"
#import "OpereDaoXML.h"


@interface CoverFlowViewController : UIViewController <AFOpenFlowViewDelegate,AFOpenFlowViewDataSource, UISearchBarDelegate> {
	
    
    IBOutlet UITextView* textView;
    
    AFOpenFlowView* _flowView;
    
    NSMutableDictionary* _artWorks;
    
    int _indexArtWork;
    
}

@property (readonly, strong) id <OpereDao> dao;
@property (nonatomic, strong)IBOutlet UITextView* textView;
@property (nonatomic, strong)IBOutlet AFOpenFlowView *flowView;






@end
