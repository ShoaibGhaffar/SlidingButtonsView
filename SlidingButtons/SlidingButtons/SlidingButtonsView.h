//
//  SlideButtonsView.h
//  ButtonSlider
//
//  Created by Shoaib Mac Mini on 04/09/2013.
//  Copyright (c) 2013 Shoaib Mac Mini. All rights reserved.
//

#import <UIKit/UIKit.h>

#define BUTTON_SPACING 5.0f
#define SLIDING_SPEED 0.25f  // Range 0 to 1

@class SlidingButtonsView;

@protocol SlidingButtonsViewDelegate <NSObject>

@optional
-(void) slidingButtonsViewHandler:(SlidingButtonsView*)slidingButtonsView button:(id)button buttonIndex:(int)buttonIndex;

@end

typedef enum {
    kSliderDirectionLeft,
    kSliderDirectionRight,
    kSliderDirectionTop,
    kSliderDirectionDown,
} SliderDirection;

@interface SlidingButtonsView : UIView {
    SliderDirection currSliderDirection_;
    
    NSMutableArray* arrSliderButtons_;
    NSTimer* timer_;
    
    BOOL on_;
    
    CGPoint diff_;
    CGPoint refPos_;
    
    id <SlidingButtonsViewDelegate>delegate_;
}

- (id)initWithDirection:(SliderDirection)sldDir Position:(CGPoint)pos ButtonImages:(id)firstObj, ... NS_REQUIRES_NIL_TERMINATION;

@property(nonatomic,getter=isOn) BOOL on;
@property (nonatomic, assign) id <SlidingButtonsViewDelegate>delegate;

@end
