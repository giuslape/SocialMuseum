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
    
    __weak AFOpenFlowView* _flowView;
    
}

@property (readonly, strong) id <OpereDao> dao;
@property (nonatomic, strong)IBOutlet UITextView* textView;
@property (weak, nonatomic) IBOutlet AFOpenFlowView *flowView;






@end
