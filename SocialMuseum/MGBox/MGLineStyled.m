//
//  Created by matt on 10/11/12.
//

#import "MGLineStyled.h"

#define DEFAULT_SIZE (CGSize){304, 40}

@implementation MGLineStyled

- (void)setup {
  [super setup];

  // default styling
  self.backgroundColor = [UIColor colorWithRed:0.94 green:0.94 blue:0.95 alpha:1];
  self.padding = UIEdgeInsetsMake(0, 8, 8, 8);

  // use MGBox borders instead of the maybe-to-be-deprecated solidUnderline
  self.borderStyle = MGBorderEtchedTop | MGBorderEtchedBottom;
}

+ (id)line {
  return [self boxWithSize:DEFAULT_SIZE];
}

+ (UIColor *) borderColorForTag:(NSNumber *)lineTag{
    
    UIColor* color;

    switch ([lineTag intValue] % 5) {
        case 0:
            color = UIColor.redColor;
            break;
        case 1:
            color = [UIColor greenColor];
            break;
        case 2:
            color = [UIColor purpleColor];
            break;
        case 3:
            color = [UIColor blueColor];
            break;
        case 4:
            color = [UIColor yellowColor];
            break;
        default:
            color = [UIColor blackColor];
            break;
    }
    
    return color;
    
}


@end
