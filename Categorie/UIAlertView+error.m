//
//  UIAlertView+error.m
//  iReporter
//
//  Created by Marin Todorov on 09/02/2012.
//  Copyright (c) 2012 Marin Todorov. All rights reserved.
//

#import "UIAlertView+error.h"

@implementation UIAlertView(error)
+(void)error:(NSString*)msg
{
    [[[UIAlertView alloc] initWithTitle:@"Error" 
                                message:msg 
                               delegate:nil 
                      cancelButtonTitle:@"Close" 
                      otherButtonTitles: nil] show];
}
@end
