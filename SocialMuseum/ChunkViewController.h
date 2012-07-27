//
//  ChunkViewController.h
//  SocialMuseum
//
//  Created by Vincenzo Lapenta on 26/07/12.
//  Copyright (c) 2012 Lapenta. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ChunkViewController : UIViewController 

@property (weak, nonatomic) IBOutlet UITextView *textView;
@property (nonatomic, strong, readwrite) NSString* chunk;
@property (nonatomic, strong, readwrite) NSNumber* IdChunk;

@end
