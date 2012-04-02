//
//  OpereDaoXML.h
//  SocialMuseum
//
//  Created by Giuseppe Lapenta on 15/12/11.
//  Copyright (c) 2011 Lapenta. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TBXML.h"

@protocol OpereDao <NSObject>

- (id)loadArtWorks;

@end

@interface OpereDaoXML : NSObject <OpereDao>


-(id)loadArtWorks;


@end
