//
//  APPSortingController.m
//
//  Created by Anton Pavlyuk on 21.03.12.
//  Copyright (c) 2012 iHata. All rights reserved.
//

#import "APPSortingController.h"
#import <QuartzCore/QuartzCore.h>
#import <objc/runtime.h>

static NSTimeInterval firstHalfAnimationTimeInterval = 0.3;
static NSTimeInterval secondHalfAnimationTimeInterval = 0.07;
static NSTimeInterval delayBetweenTransitions = 0.2;

static NSMutableDictionary *kClassesDictionary;
static const NSString *kCompletionHandlerKey = @"_kCompletionHandlerKey";
static const NSString *kActionTitleKey = @"_kActionTitleKey";
static const NSString *kItemsKey = @"_kItemsKey";
static const NSString *kFontKey = @"_kFontKey";
static const NSString *kShowAllActionButtonKey = @"_kShowAllActionButtonKey";
static const NSString *kDarkModeKey = @"_kDarkModeKey";
static const NSString *kDeltaY = @"_kDeltaY";

@implementation APPSortingController
{
    SortingControllerHandler completionHandler;
    NSString *actionTitle;
    NSArray *itemsTitle;
    UIViewController *parentViewController;
    
    UIView *actionView;
    CGFloat itemGap;
    NSMutableArray *itemsView;
    
    BOOL actionButtonPressed;
    
    APPDarkView *darkView;
}

@synthesize font = font_;
@synthesize showAllActionButton = showAllActionButton_;
@synthesize darkMode = darkMode_;
@synthesize deltaY = deltaY_;

#pragma mark - Public

- (id)initWithActionButton:(NSString *)button 
                itemsArray:(NSArray *)items 
      parentViewController:(UIViewController *)parent 
         completionHandler:(SortingControllerHandler)handler
{
    self = [super init];
    if (self) {
        
        itemsView = [NSMutableArray array];
        itemGap = 5.0;
        font_ = [UIFont boldSystemFontOfSize:14.0];
        showAllActionButton_ = YES;
        darkMode_ = NO;
        deltaY_ = 100.0;
        
        actionTitle = button;
        itemsTitle = items;
        parentViewController = parent;
        completionHandler = handler;
        
        // resetup static dictionary
        if (!kClassesDictionary) {
            kClassesDictionary = [NSMutableDictionary dictionary];
        }
        NSString *key = NSStringFromClass(parent.class);
        NSMutableDictionary *dictionary = [kClassesDictionary objectForKey:key];
        if (!dictionary) {
            dictionary = [NSMutableDictionary dictionary];
        }
        if (button) {
            [dictionary setObject:button forKey:kActionTitleKey];
        }
        if (items) {
            [dictionary setObject:items forKey:kItemsKey];
        }
        if (handler) {
            [dictionary setObject:[handler copy] forKey:kCompletionHandlerKey];
        }
        [kClassesDictionary setObject:dictionary forKey:key];
    }
    return self;
}

- (void)dealloc
{
    if (darkView) {
        [darkView removeFromSuperview];
        darkView.delegate = nil;
    }
    [actionView removeFromSuperview];
    for (id item in itemsView) {
        [item removeFromSuperview];
    }
}

- (void)show
{
    [self addCodeToParentViewController];
    [self createActionView];
    //if (parentViewController) {
        [[self appWindow] addSubview:actionView];
        [self presentView:actionView completionHandler:nil];
    //}
}

- (void)hide
{
    if (actionView) {
        [actionView removeFromSuperview];
        actionView = nil;
    }
    if (darkView) {
        [darkView removeFromSuperview];
        darkView = nil;
    }
    //[self hideItemsWithTriggeringCompletionHandler:NO sender:nil];
    [itemsView enumerateObjectsUsingBlock:^(UIView *item, NSUInteger idx, BOOL *stop) {
        [item removeFromSuperview];
        item = nil;
    }];
}

#pragma mark - Setters

- (void)setFont:(UIFont *)font
{
    if (font_ != font) {
        font_ = font;
        
        NSString *key = NSStringFromClass(parentViewController.class);
        NSMutableDictionary *dictionary = [kClassesDictionary objectForKey:key];
        if (dictionary && font) {
            [dictionary setObject:font forKey:kFontKey];
        }
    }
}

- (void)setShowAllActionButton:(BOOL)showAllActionBtn
{
    showAllActionButton_ = showAllActionBtn;
    
    NSString *key = NSStringFromClass(parentViewController.class);
    NSMutableDictionary *dictionary = [kClassesDictionary objectForKey:key];
    if (dictionary) {
        [dictionary setObject:[NSNumber numberWithBool:showAllActionBtn] forKey:kShowAllActionButtonKey];
    }
}

- (void)setDarkMode:(BOOL)dm
{
    darkMode_ = dm;
    
    NSString *key = NSStringFromClass(parentViewController.class);
    NSMutableDictionary *dictionary = [kClassesDictionary objectForKey:key];
    if (dictionary) {
        [dictionary setObject:[NSNumber numberWithBool:dm] forKey:kDarkModeKey];
    }
}

- (void)setDeltaY:(CGFloat)newDeltaY
{
    deltaY_ = newDeltaY;
    
    NSString *key = NSStringFromClass(parentViewController.class);
    NSMutableDictionary *dictionary = [kClassesDictionary objectForKey:key];
    if (dictionary) {
        [dictionary setObject:[NSNumber numberWithFloat:newDeltaY] forKey:kDeltaY];
    }
}

#pragma mark - Getters

- (UIView *)actionView
{
    return actionView;
}

- (NSArray *)items
{
    NSMutableArray *array = [NSMutableArray arrayWithArray:itemsView];
    if (darkView && itemsView) {
        [array addObject:darkView];
    }
    return array;
}

#pragma mark - Private

- (void)createActionView
{
    actionView = [[UIView alloc] init];
    CGFloat viewWidth = [self sizeForItemWithTitle:actionTitle].width;
    CGFloat viewHeight = [self sizeForItemWithTitle:actionTitle].height;
    CGFloat cornerRadius = viewHeight / 2;
    actionView.frame = CGRectMake([UIScreen mainScreen].bounds.size.width, deltaY_, viewWidth, viewHeight);
    [self setUpAppearanceForView:actionView cornerRadius:cornerRadius];
    
    CGFloat scaleFactor = 0.6;
    UIView *roundView = [self roundCrossWithRadius:(viewHeight/2 * scaleFactor)];
    CGRect roundFrame = roundView.frame;
    roundFrame.origin.x = viewHeight * (1 - scaleFactor) / 2;
    roundFrame.origin.y = viewHeight * (1 - scaleFactor) / 2;
    roundView.frame = roundFrame;
    [actionView addSubview:roundView];
    
    UIButton *actionButton = [UIButton buttonWithType:UIButtonTypeCustom];
    actionButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentRight;
    CGRect frame = actionView.frame;
    frame.origin.x = 0.0;// + frame.size.height / 2;
    frame.origin.y = 0.0;
    frame.size.width -= frame.size.height;
    actionButton.frame = frame;
    [actionButton setTitle:[NSString stringWithFormat:@"%@ ", actionTitle] forState:UIControlStateNormal];
    actionButton.titleLabel.font = font_;
    [actionButton setTitleColor:[UIColor darkGrayColor] forState:UIControlStateNormal];
    [actionButton addTarget:self action:@selector(actionButtonAction:) forControlEvents:UIControlEventTouchUpInside];
    [actionView addSubview:actionButton];
}

- (void)createItems
{
    [itemsTitle enumerateObjectsUsingBlock:^(NSString *title, NSUInteger idx, BOOL *stop) {
        UIView *singleView = [[UIView alloc] init];
        CGFloat viewHeight = [self sizeForItemWithTitle:title].height;
        CGFloat viewWidth = [self sizeForItemWithTitle:title].width;
        viewWidth -= viewHeight / 2;
        CGFloat cornerRadius = viewHeight / 2;
        singleView.frame = CGRectMake([UIScreen mainScreen].bounds.size.width, actionView.frame.origin.y + (actionView.frame.size.height + viewHeight/3) * (idx + 1) , viewWidth, viewHeight);
        [self setUpAppearanceForView:singleView cornerRadius:cornerRadius];
        
        UIButton *actionButton = [UIButton buttonWithType:UIButtonTypeCustom];
        CGRect frame = singleView.frame;
        frame.origin.x = 0.0 + frame.size.height / 4;
        frame.origin.y = 0.0;
        frame.size.width -= frame.size.height;
        actionButton.frame = frame;
        [actionButton setTitle:title forState:UIControlStateNormal];
        actionButton.titleLabel.font = font_;
        [actionButton setTitleColor:[UIColor darkGrayColor] forState:UIControlStateNormal];
        [actionButton addTarget:self action:@selector(singleItemAction:) forControlEvents:UIControlEventTouchUpInside];
        [singleView addSubview:actionButton];
        
        [itemsView addObject:singleView];
    }];
}

- (void)presentView:(UIView *)view completionHandler:(void (^)(void))handler
{
    if (!view) {
        return;
    }
    
    CGRect finalFrame = view.frame;
    finalFrame.origin.x = [UIScreen mainScreen].bounds.size.width;
    finalFrame.origin.x += view.bounds.size.height - view.bounds.size.width;
    
    if (view == actionView && !self.showAllActionButton) {
        finalFrame.origin.x = [UIScreen mainScreen].bounds.size.width - view.bounds.size.height;
    }
    
    CGRect tempFrame = finalFrame;
    tempFrame.origin.x -= view.bounds.size.height / 2;
    
    [UIView animateWithDuration:firstHalfAnimationTimeInterval 
                     animations:^{
                         view.frame = tempFrame;
                     } completion:^(BOOL finished) {
                         [UIView animateWithDuration:secondHalfAnimationTimeInterval 
                                          animations:^{
                                              view.frame = finalFrame;
                                          } completion:^(BOOL finished) {
                                              if (handler) {
                                                  handler();
                                              }
                                          }];
                     }];
}

- (void)hideView:(UIView *)view
{
    if (!view) {
        return;
    }
    
    CGRect finalFrame = view.frame;
    finalFrame.origin.x = [UIScreen mainScreen].bounds.size.width;
    
    if (view == actionView && !self.showAllActionButton) {
        finalFrame.origin.x = [UIScreen mainScreen].bounds.size.width - view.bounds.size.height;
    }
    
    CGRect tempFrame = view.frame;
    tempFrame.origin.x -= view.bounds.size.height / 2;
    
    [UIView animateWithDuration:secondHalfAnimationTimeInterval 
                     animations:^{
                         view.frame = tempFrame;
                     } completion:^(BOOL finished) {
                         [UIView animateWithDuration:firstHalfAnimationTimeInterval 
                                          animations:^{
                                              view.frame = finalFrame;
                                          } completion:^(BOOL finished) {
                                              if (view != actionView) {
                                                  [view removeFromSuperview];
                                              }
                                          }];
                     }];
}

- (void)showItems
{
    if (!itemsView.count) {
        [self createItems];
    }
    actionView.userInteractionEnabled = NO;
    [self rotateRoundCrossForShowingItems:YES];
    [itemsView enumerateObjectsUsingBlock:^(UIView *view, NSUInteger idx, BOOL *stop) {
        BOOL lastObject = NO;
        if (idx == itemsView.count - 1) {
            lastObject = YES;
        }
        [[self appWindow] addSubview:view];
        double delayInSeconds = delayBetweenTransitions * idx;
        dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, delayInSeconds * NSEC_PER_SEC);
        dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
            [self presentView:view completionHandler:^{
                if (lastObject) {
                    actionView.userInteractionEnabled = YES;
                }
            }];
        });
    }];
}

- (void)hideItemsWithTriggeringCompletionHandler:(BOOL)trigger sender:(id)sender
{
    [self rotateRoundCrossForShowingItems:NO];
    [itemsView enumerateObjectsUsingBlock:^(UIView *view, NSUInteger idx, BOOL *stop) {
        BOOL lastItem = NO;
        if (idx == itemsView.count - 1) {
            lastItem = YES;
        }
        double delayInSeconds = delayBetweenTransitions * idx;
        dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, delayInSeconds * NSEC_PER_SEC);
        dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
            [self hideView:view];
            if (lastItem && !self.showAllActionButton) {
                double delayInSeconds = delayBetweenTransitions;
                dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, delayInSeconds * NSEC_PER_SEC);
                dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
                    [self hideView:actionView];
                });
            }
        });
    }];
    if (trigger) {
        if (completionHandler) {
            NSUInteger index = [itemsTitle indexOfObject:((UIButton *)sender).titleLabel.text];
            if (index != NSNotFound) {
                completionHandler(index);
            }
        }
    }
    
    [itemsView removeAllObjects];
}

- (void)rotateRoundCrossForShowingItems:(BOOL)showItems
{
    UIView *viewToSpin = nil;
    for (id subview in actionView.subviews) {
        if ([subview isKindOfClass:UIView.class]) {
            viewToSpin = subview;
            break;
        }
    }
    
    if (viewToSpin) {        
        CGFloat degrees = showItems ? 135.0 : 0.0;
        [UIView animateWithDuration:firstHalfAnimationTimeInterval + secondHalfAnimationTimeInterval 
                         animations:^{
                             float targetRotation = degrees;
                             viewToSpin.transform = CGAffineTransformMakeRotation(targetRotation / 180.0 * M_PI);
                         }];
    }
}

- (void)setParentViewToDarkMode:(BOOL)setToDark
{
    if (!darkMode_) {
        return;
    }
    
    if (setToDark) {
        UIWindow *appWindow = [self appWindow];
        
        if (!darkView) {
            darkView = [[APPDarkView alloc] initWithFrame:appWindow.bounds];
            // Correct the frame
            CGRect darkFrame = darkView.frame;
            if (![UIApplication sharedApplication].statusBarHidden) {
                darkFrame.origin.y += [UIApplication sharedApplication].statusBarFrame.size.height;
            }
            if (parentViewController.navigationController.navigationBar && !parentViewController.navigationController.navigationBarHidden) {
                darkFrame.origin.y += parentViewController.navigationController.navigationBar.frame.size.height;
            }
            if (parentViewController.view.frame.origin.y > 0) {
                darkFrame.origin.y += parentViewController.view.frame.origin.y;
            }
            darkView.frame = darkFrame;
            
            darkView.delegate = self;
            darkView.backgroundColor = [UIColor darkGrayColor];
            darkView.alpha = 0.0;
            darkView.backgroundColor = [UIColor darkGrayColor];
        }
        
        [appWindow addSubview:darkView];
        [UIView animateWithDuration:delayBetweenTransitions 
                         animations:^{
                             darkView.alpha = 0.7;
                         }];
        [appWindow bringSubviewToFront:actionView];
        
        for (UIView *subview in itemsView) {
            [appWindow bringSubviewToFront:subview];
        }
        
    } else {
        
        if (darkView) {
            [UIView animateWithDuration:delayBetweenTransitions 
                             animations:^{
                                 darkView.alpha = 0.0;
                             } completion:^(BOOL finished) {
                                 [darkView removeFromSuperview];
                                 darkView = nil;
                             }];
        }
    }
}

#pragma mark - APPDarkView delegate

- (void)appDarkView:(APPDarkView *)darkView didTouch:(NSSet *)touches withEvent:(UIEvent *)event
{
    [self actionButtonAction:nil];
}

#pragma mark - Actions

- (void)actionButtonAction:(id)sender
{
    actionButtonPressed = itemsView.count ? NO : YES;
    
    if (actionButtonPressed) {
        if (self.showAllActionButton) {
            [self showItems];
        }
        if (!self.showAllActionButton) {
            self.showAllActionButton = YES;
            [self presentView:actionView completionHandler:^{
                if (!self.showAllActionButton) {
                    [self showItems];
                }
            }];
            self.showAllActionButton = NO;
        }
        [self setParentViewToDarkMode:YES];
    } else {
        [self hideItemsWithTriggeringCompletionHandler:NO sender:sender];
        [self setParentViewToDarkMode:NO];
    }
}

- (void)singleItemAction:(id)sender
{
    [self hideItemsWithTriggeringCompletionHandler:YES sender:sender];
    [self setParentViewToDarkMode:NO];
}

#pragma mark - Helpers

- (CGSize)sizeForItemWithTitle:(NSString *)title
{
    CGSize size = [title sizeWithFont:font_ constrainedToSize:CGSizeMake([UIScreen mainScreen].bounds.size.width, 100000.0f) lineBreakMode:UILineBreakModeWordWrap];
    size.height += 2 * itemGap;
    size.width += 2 * itemGap + 2 * size.height;
    return size;
}

- (UIWindow *)appWindow
{
    UIWindow *window = (UIWindow *)[UIApplication sharedApplication].delegate.window;
    return window;
}

- (UIView *)roundCrossWithRadius:(CGFloat)radius
{
    UIView *round = [[UIView alloc] initWithFrame:CGRectMake(0.0, 0.0, 2*radius, 2*radius)];
    round.backgroundColor = [UIColor grayColor];
    round.layer.cornerRadius = radius;
    
    CGFloat crossSideWidth = radius / 3;
    CGFloat crossGap = radius / 3;
    
    UIView *halfCross1 = [[UIView alloc] initWithFrame:CGRectMake(crossGap, radius - crossSideWidth/2, 2*(radius - crossGap), crossSideWidth)];
    halfCross1.backgroundColor = [UIColor whiteColor];
    [round addSubview:halfCross1];
    UIView *halfCross2 = [[UIView alloc] initWithFrame:CGRectMake(radius - crossSideWidth/2, crossSideWidth, crossGap, 2*(radius - crossGap))];
    halfCross2.backgroundColor = [UIColor whiteColor];
    [round addSubview:halfCross2];
    
    return round;
}

#pragma mark Appearance

- (void)setUpAppearanceForView:(UIView *)view cornerRadius:(CGFloat)cornerRadius
{
    //view.layer.mask = [self maskForView:view cornerRadius:cornerRadius];
    view.layer.cornerRadius = cornerRadius;
    
    view.layer.backgroundColor = [UIColor whiteColor].CGColor;
    
    view.layer.shadowColor = [UIColor blackColor].CGColor;
    view.layer.shadowOffset = CGSizeMake(0, 1);
    view.layer.shadowOpacity = 0.6;
    view.layer.shadowPath = [UIBezierPath bezierPathWithRoundedRect:view.bounds cornerRadius:cornerRadius].CGPath;
    
    view.layer.borderColor = [UIColor lightGrayColor].CGColor;
    view.layer.borderWidth = 2.0;
}

#pragma mark - Runtime magic

- (void)addCodeToParentViewController 
{
    if (!parentViewController) {
        return;
    }
    
    [self addCodeToViewDidAppearMethodInParentViewController];
    [self addCodeToViewWillDisappearMethodInParentViewController];
}

+ (NSString *)ivarNameOfAPPSortingControllerForClass:(Class)classToInspect
{
    NSString *appSortingControllerIvarName = nil;
    
    unsigned int ivarCount = 0;
    Ivar *ivars = class_copyIvarList(classToInspect, &ivarCount);
    for (int i = 0; i < ivarCount; i++) {
        const char *ivarName = ivar_getName(ivars[i]);
        const char *ivarType = ivar_getTypeEncoding(ivars[i]);
        //ptrdiff_t ivarOffset = ivar_getOffset(ivars[i]);
        
        //NSLog(@"ivar: %s (type: %s) (offset: %d)", ivarName, ivarType, ivarOffset);
        NSString *ivarNameStr = [NSString stringWithCString:ivarName encoding:NSUTF8StringEncoding];
        ivarNameStr = [ivarNameStr stringByReplacingOccurrencesOfString:[NSString stringWithFormat:@"%c", '"'] withString:@""];
        NSString *classNameStr = [NSString stringWithCString:ivarType encoding:NSUTF8StringEncoding];
        
        classNameStr = [classNameStr stringByReplacingOccurrencesOfString:@"@" withString:@""];
        NSMutableString *strToDelete = [NSMutableString stringWithFormat:@"%c", '"'];
        classNameStr = [classNameStr stringByReplacingOccurrencesOfString:strToDelete withString:@""];
        
        if ([classNameStr isEqualToString:NSStringFromClass(self)]) {
            appSortingControllerIvarName = ivarNameStr;
            break;
        }
    }
    free(ivars);
    
    return appSortingControllerIvarName;
}

#pragma mark ViewDidAppear

- (void)addCodeToViewDidAppearMethodInParentViewController
{    
    SEL customViewDidAppearSEL = @selector(customViewDidAppear:);
    SEL standartViewDidAppearSEL = @selector(viewDidAppear:);
    
    if ([parentViewController respondsToSelector:customViewDidAppearSEL]) {
        return;
    }
    
    const char *types = [[NSString stringWithFormat: @"%s%s%s%s", @encode(void), @encode(id), @encode(SEL), @encode(BOOL)] UTF8String];
    class_addMethod(parentViewController.class, customViewDidAppearSEL, (IMP)customViewDidAppearIMP, types);
    
    Method standartDidAppearMethod = class_getInstanceMethod(parentViewController.class, standartViewDidAppearSEL);
    Method customDidAppearMethod = class_getInstanceMethod(parentViewController.class, customViewDidAppearSEL);
    
    if ([parentViewController.class instancesRespondToSelector:standartViewDidAppearSEL] && 
        [parentViewController.class instancesRespondToSelector:customViewDidAppearSEL]) 
    {
        method_exchangeImplementations(standartDidAppearMethod, customDidAppearMethod);
    }
}

void customViewDidAppearIMP(id self, SEL _cmd, BOOL animated)
{
    Method selfViewDidAppearMethod = class_getInstanceMethod([self class], @selector(viewDidAppear:));
    IMP selfViewDidAppearIMP = method_getImplementation(selfViewDidAppearMethod);
    Method superViewDidAppearMethod = class_getInstanceMethod([self superclass], @selector(viewDidAppear:));
    IMP superViewDidAppearIMP = method_getImplementation(superViewDidAppearMethod);
    
    if (selfViewDidAppearIMP != superViewDidAppearIMP) {
        if ([self respondsToSelector:@selector(customViewDidAppear:)]) {
            [self performSelector:@selector(customViewDidAppear:)];
        }
    } else {
        //NSLog(@"There is no implementation of -viewDidAppear: in %@", self);
    }
    
    // my super code for viewDidAppear
    
    NSMutableDictionary *dictionary = [kClassesDictionary objectForKey:NSStringFromClass([self class])];
    
    if (dictionary) {
        
        NSString *appSortingControllerIvarName = [APPSortingController ivarNameOfAPPSortingControllerForClass:[self class]];
        
        if (!appSortingControllerIvarName) {
            return;
        }
        
        if ([self valueForKey:appSortingControllerIvarName]) {
            return;
        }
        
        APPSortingController *sortingController = [[APPSortingController alloc] initWithActionButton:[dictionary objectForKey:kActionTitleKey] 
                                                                                          itemsArray:[dictionary objectForKey:kItemsKey] 
                                                                                parentViewController:self 
                                                                                   completionHandler:[dictionary objectForKey:kCompletionHandlerKey]];
        
        [self setValue:sortingController forKey:appSortingControllerIvarName];
        [sortingController setShowAllActionButton:[[dictionary objectForKey:kShowAllActionButtonKey] boolValue]];
        [sortingController setDarkMode:[[dictionary objectForKey:kDarkModeKey] boolValue]];
        if ([dictionary objectForKey:kDeltaY]) {
            [sortingController setDeltaY:[[dictionary objectForKey:kDeltaY] floatValue]];
        }
        if ([dictionary objectForKey:kFontKey]) {
            [sortingController setFont:[dictionary objectForKey:kFontKey]];
        }
        [sortingController show];
    }
}

#pragma mark ViewWillDisappear

- (void)addCodeToViewWillDisappearMethodInParentViewController
{    
    SEL customViewWillDisappearSEL = @selector(customViewWillDisappear:);
    SEL standartViewWillDisappearSEL = @selector(viewWillDisappear:);
    
    if ([parentViewController respondsToSelector:customViewWillDisappearSEL]) {
        return;
    }
    
    const char *types = [[NSString stringWithFormat: @"%s%s%s%s", @encode(void), @encode(id), @encode(SEL), @encode(BOOL)] UTF8String];
    class_addMethod(parentViewController.class, customViewWillDisappearSEL, (IMP)customViewWillDisappearIMP, types);
    
    Method standartWillDisappearMethod = class_getInstanceMethod(parentViewController.class, standartViewWillDisappearSEL);
    Method customWillDisappearMethod = class_getInstanceMethod(parentViewController.class, customViewWillDisappearSEL);
    
    if ([parentViewController.class instancesRespondToSelector:standartViewWillDisappearSEL] && 
        [parentViewController.class instancesRespondToSelector:customViewWillDisappearSEL]) 
    {
        method_exchangeImplementations(standartWillDisappearMethod, customWillDisappearMethod);
    }
}

void customViewWillDisappearIMP(id self, SEL _cmd, BOOL animated)
{
    Method selfViewWillDisappearMethod = class_getInstanceMethod([self class], @selector(viewWillDisappear:));
    IMP selfViewWillDisappearIMP = method_getImplementation(selfViewWillDisappearMethod);
    Method superViewWillDisappearMethod = class_getInstanceMethod([self superclass], @selector(viewWillDisappear:));
    IMP superViewWillDisappearIMP = method_getImplementation(superViewWillDisappearMethod);
    
    if (selfViewWillDisappearIMP != superViewWillDisappearIMP) {
        if ([self respondsToSelector:@selector(customViewWillDisappear:)]) {
            [self performSelector:@selector(customViewWillDisappear:)];
        }
    } else {
        //NSLog(@"There is no implementation of -viewDidAppear: in %@", self);
    }
    
    // my super code for viewWillDisappear
    
    NSString *appIvarName = [APPSortingController ivarNameOfAPPSortingControllerForClass:[self class]];
    if (!appIvarName) {
        return;
    }
    
    APPSortingController *ivar = [self valueForKey:appIvarName];
    if (ivar) {
        [self setValue:nil forKey:appIvarName];
    }
}

@end
