//
//  NSString+Date.m
//  SocialMuseum
//
//  Created by Giuseppe Lapenta on 07/11/12.
//  Copyright (c) 2012 Lapenta. All rights reserved.
//

#import "NSString+Date.h"

@implementation NSString (Date)

+ (NSString *)determingTemporalDifferencesFromNowtoStartDate:(NSString *)start{
    
    NSString* dateComponents = @"yyyy-MM-dd HH:mm:ss";
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:dateComponents];
    
    NSDate *startDate = [dateFormatter dateFromString:start];
    NSDate *endDate = [NSDate date];
    
    NSCalendar *gregorian = [[NSCalendar alloc]
                             initWithCalendarIdentifier:NSGregorianCalendar];
    
    NSUInteger unitFlags = NSDayCalendarUnit | NSHourCalendarUnit | NSMinuteCalendarUnit;
    
    NSDateComponents *components = [gregorian components:unitFlags
                                                fromDate:startDate
                                                  toDate:endDate options:0];
    NSInteger days = [components day];
    NSInteger hours = [components hour];
    NSInteger minute = [components minute];
    
    NSString* difference = @"";
    NSString* appendix = @"";
    
    if (days > 0){
        
        appendix = @"d";
        difference = [NSString stringWithFormat:@"%d",days];
        
    }else if(hours > 0){
        
        appendix = @"h";
        difference = [NSString stringWithFormat:@"%d",hours];
        
    }else if(minute > 0){
        
        appendix = @"m";
        difference = [NSString stringWithFormat:@"%d",minute];
    }else{
        
        appendix = @"pochi secondi fa";
        difference = @"";
    }
    
    return [NSString stringWithFormat:@"%@%@",difference, appendix];
    
}


@end
