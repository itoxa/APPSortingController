//
//  APPDarkView.h
//
//  Created by Anton Pavlyuk on 23.03.12.
//  Copyright (c) 2012 iHata. All rights reserved.
//

#import <UIKit/UIKit.h>

@class APPDarkView;
@protocol APPDarkViewDelegate <NSObject>
@required
- (void)appDarkView:(APPDarkView *)darkView didTouch:(NSSet *)touches withEvent:(UIEvent *)event;
@end

@interface APPDarkView : UIView

@property (nonatomic, unsafe_unretained) id <APPDarkViewDelegate> delegate;

@end
