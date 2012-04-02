//
//  APPDarkView.m
//
//  Created by Anton Pavlyuk on 23.03.12.
//  Copyright (c) 2012 iHata. All rights reserved.
//

#import "APPDarkView.h"

@implementation APPDarkView

@synthesize delegate;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    if ([self.delegate respondsToSelector:@selector(appDarkView:didTouch:withEvent:)]) {
        [self.delegate appDarkView:self didTouch:touches withEvent:event];
    }
}

@end
