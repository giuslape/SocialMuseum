//
//  OpereDaoXML.m
//  SocialMuseum
//
//  Created by Giuseppe Lapenta on 15/12/11.
//  Copyright (c) 2011 Lapenta. All rights reserved.
//

#import "OpereDaoXML.h"




@implementation OpereDaoXML


-(id)loadArtWorks{
    
    NSMutableDictionary* artWorksToReturn = [[NSMutableDictionary alloc] init];
    
    TBXML* tbxml = [TBXML tbxmlWithXMLFile:@"Opere.xml"];
    
    TBXMLElement * root = tbxml.rootXMLElement;
    
    int indexArtWork = 0;
	
	// if root element is valid
	if (root) {
		// search for the first artwork element within the root element's children
		TBXMLElement * artWork = [TBXML childElementNamed:@"artwork" parentElement:root];
		
		// if an author element was found
		while (artWork != nil) {
			
            NSMutableDictionary * artWorkDictionary = [[NSMutableDictionary alloc] init];
            
			// get the title attribute from the artwork element
			NSString* title = [TBXML valueOfAttributeNamed:@"title" forElement:artWork];
            
            // get the filename attribute from the artwork element
            NSString* fileName = [TBXML valueOfAttributeNamed:@"filename" forElement:artWork];
			
							
            // find the description child element of the artwork element
            TBXMLElement * desc = [TBXML childElementNamed:@"description" parentElement:artWork];
				
            NSString* description = nil;
            // if we found a description
            if (desc != nil) {
					// obtain the text from the description element
                description = [TBXML textForElement:desc];
            }
			            
            [artWorkDictionary setObject:title forKey:@"title"];
            [artWorkDictionary setObject:fileName forKey:@"filename"];
            [artWorkDictionary setObject:description forKey:@"description"];
            
            [artWorksToReturn setObject:artWorkDictionary forKey:[NSNumber numberWithInt:indexArtWork]];
            
			
			// find the next sibling element named "author"
			artWork = [TBXML nextSiblingNamed:@"artwork" searchFromElement:artWork];
            
            indexArtWork++;
		}			
	}
    
    return artWorksToReturn;
    
    
}



@end
