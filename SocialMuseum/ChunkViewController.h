//
//  ChunkViewController.h
//  SocialMuseum
//
//  Created by Giuseppe Lapenta on 26/07/12.
//  Copyright (c) 2012 Lapenta. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ChunkViewController : UIViewController {
    
    NSArray* _comments;
}

@property (weak, nonatomic) IBOutlet UITextView *textView;
@property (nonatomic, strong, readwrite) NSString* chunk;
@property (nonatomic, copy, readwrite) NSNumber* IdChunk;
@property (nonatomic, copy, readwrite) NSNumber* IdOpera;

@property (weak, nonatomic) IBOutlet UITableView *tableView;

@end
