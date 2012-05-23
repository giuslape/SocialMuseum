//
//  SMAnnotationView.m
//  SocialMuseum
//
//  Created by Giuseppe Lapenta on 08/05/12.
//  Copyright (c) 2012 Lapenta. All rights reserved.
//

#import "SMAnnotationView.h"

@implementation SMAnnotationView


-(id)initWithAnnotation:(id<MKAnnotation>)annotation reuseIdentifier:(NSString *)reuseIdentifier{
    
    self = [super initWithAnnotation:annotation reuseIdentifier:reuseIdentifier];
    
    if (self)
    {
        // Set the frame size to the appropriate values.
        CGRect  myFrame = self.frame;
        myFrame.size.width = 40;
        myFrame.size.height = 40;
        self.frame = myFrame;
        
        // The opaque property is YES by default. Setting it to
        // NO allows map content to show through any unrendered
        // parts of your view.
        self.opaque = NO;
    }
    return self;
}


@end
