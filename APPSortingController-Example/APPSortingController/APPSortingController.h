//
//  APPSortingController.h
//
//  Created by Anton Pavlyuk on 21.03.12.
//  Copyright (c) 2012 iHata. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "APPDarkView.h"

typedef void (^SortingControllerHandler)(NSUInteger buttonIndex);

@interface APPSortingController : NSObject <APPDarkViewDelegate>

@property (nonatomic, strong) UIFont *font;             // = [UIFont boldSystemFontOfSize:14.0] by default;
@property (nonatomic, assign) BOOL showAllActionButton; // = YES by default;
@property (nonatomic, assign) BOOL darkMode;            // = NO by default;
@property (nonatomic, assign) CGFloat deltaY;           // = 100.0 by default. It is the frame.origin.y of main action button.

- (id)initWithActionButton:(NSString *)button 
                itemsArray:(NSArray *)items 
      parentViewController:(UIViewController *)parentViewController 
         completionHandler:(SortingControllerHandler)handler;

- (void)show;
- (void)hide;

- (UIView *)actionView; // main button;
- (NSArray *)items;     // array of UIView's, include darkView (if darkMode == YES);

@end