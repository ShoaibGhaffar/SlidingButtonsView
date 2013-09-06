//
//  SlideButtonsView.m
//  ButtonSlider
//
//  Created by Shoaib Mac Mini on 04/09/2013.
//  Copyright (c) 2013 Shoaib Mac Mini. All rights reserved.
//

#import "SlidingButtonsView.h"

#pragma mark - SliderButton interface
@interface SliderButton : UIButton
{
    CGRect frameOff_, frameOn_;
}

@property (nonatomic) CGRect frameOn;
@property (nonatomic) CGRect frameOff;
@end

#pragma mark - SliderButton implementation
@implementation SliderButton
@synthesize frameOn = frameOn_, frameOff = frameOff_;
@end

#pragma mark - SlideButtonsView implementation
@implementation SlidingButtonsView
@synthesize on = on_, delegate = delegate_;


#pragma mark - init
- (id)initWithDirection:(SliderDirection)sldDir Position:(CGPoint)pos ButtonImages:(id)firstObj, ... NS_REQUIRES_NIL_TERMINATION
{
    self = [super initWithFrame:CGRectMake(pos.x, pos.y, 0, 0)];
    
    if (self) {
        //Setting Slider Direction
        currSliderDirection_ = sldDir;
        
        //Extracting Image Names
        NSMutableArray* arr = [NSMutableArray array];
        
        id eachObject;
        va_list argumentList;
        if (firstObj) // The first argument isn't part of the varargs list,
        {                                   // so we'll handle it separately.
            [arr addObject:firstObj];
            va_start(argumentList, firstObj); // Start scanning for arguments after firstObject.
            while ((eachObject = va_arg(argumentList, id))) // As many times as we can get an argument of type "id"
                [arr addObject: eachObject]; // that isn't nil, add it to self's contents.
            va_end(argumentList);
        }
        
        //Setting Slider Buttons
        [self setupSliderWithButtons:arr];
    }
    return self;
} //F.E.

#pragma mark - setting up buttons
-(void) setupSliderWithButtons:(NSMutableArray*)arrButtons {
    assert(arrButtons.count>1); // Buttons should not be less than 1
    
    CGPoint pos         =   self.frame.origin;
    CGSize  buttonSize  =   [UIImage imageNamed:[arrButtons objectAtIndex:0]].size;
    CGPoint buttonPos;
    arrSliderButtons_   =   [[NSMutableArray alloc] init];
    
    
    switch (currSliderDirection_) {
        case kSliderDirectionRight:
            [self setFrame:CGRectMake(pos.x, pos.y, (buttonSize.width + BUTTON_SPACING) * arrButtons.count, buttonSize.height)];
            buttonPos = CGPointMake(0, 0);
             break;
            
        case kSliderDirectionLeft:
            [self setFrame:CGRectMake(pos.x - ((buttonSize.width + BUTTON_SPACING) * (arrButtons.count - 1)) -  (BUTTON_SPACING), pos.y, (buttonSize.width + BUTTON_SPACING) * arrButtons.count, buttonSize.height)];
            buttonPos = CGPointMake(((buttonSize.width + BUTTON_SPACING) * (arrButtons.count - 1)) + BUTTON_SPACING, 0);
            break;
            
        case kSliderDirectionDown:
            [self setFrame:CGRectMake(pos.x, pos.y, buttonSize.width, (buttonSize.height + BUTTON_SPACING) * arrButtons.count)];
            buttonPos = CGPointMake(0, 0);
            break;
            
        case kSliderDirectionTop:
            [self setFrame:CGRectMake(pos.x, pos.y - ((buttonSize.height + BUTTON_SPACING) * (arrButtons.count - 1)) -  (BUTTON_SPACING), buttonSize.width, (buttonSize.height + BUTTON_SPACING) * arrButtons.count)];
            buttonPos = CGPointMake(0, ((buttonSize.height + BUTTON_SPACING) * (arrButtons.count - 1)) + BUTTON_SPACING);
            break;
    }
    

    for (int i = arrButtons.count-1; i >= 0; i--) {
        SliderButton* button = [SliderButton buttonWithType:UIButtonTypeCustom];
        button.tag = i;
        
        [button setTitle:[NSString stringWithFormat:@"%d", i] forState:UIControlStateNormal];

        //[button setBackgroundImage:[UIImage imageNamed:[arrButtons objectAtIndex:i]] forState:UIControlStateNormal];
        [button setImage:[UIImage imageNamed:[arrButtons objectAtIndex:i]] forState:UIControlStateNormal];
        
        [button addTarget:self action:@selector(buttonsHandler:) forControlEvents:UIControlEventTouchUpInside];
        
        CGRect frameOn;
        frameOn.size = buttonSize;
        
        switch (currSliderDirection_) {
            case kSliderDirectionRight:
                frameOn.origin.x = (buttonSize.width + BUTTON_SPACING) * i;//buttonPos.x;
                frameOn.origin.y = buttonPos.y;
                break;
                
            case kSliderDirectionLeft:
                frameOn.origin.x = ((buttonSize.width + BUTTON_SPACING) * (arrButtons.count - i - 1)) + BUTTON_SPACING;
                frameOn.origin.y = buttonPos.y;
                break;
                
            case kSliderDirectionDown:
                frameOn.origin.x = buttonPos.x;
                frameOn.origin.y = (buttonSize.height + BUTTON_SPACING) * i;//buttonPos.y;
                break;
                
            case kSliderDirectionTop:
                frameOn.origin.x = buttonPos.x;
                frameOn.origin.y = ((buttonSize.height + BUTTON_SPACING) * (arrButtons.count - i - 1) + BUTTON_SPACING);
                break;
        }

        button.frameOn  = frameOn;
        button.frameOff = CGRectMake(buttonPos.x, buttonPos.y, buttonSize.width, buttonSize.height);

        
        [button setFrame: button.frameOff];
        
        if (i == arrButtons.count-1) {
            diff_ = CGPointMake(((button.frameOn.origin.x - button.frameOff.origin.x) * (SLIDING_SPEED/2.0f)), ((button.frameOn.origin.y - button.frameOff.origin.y) * (SLIDING_SPEED/2.0f)));
        }
        
        if (i == 1) {
            refPos_ = frameOn.origin;
        }
//        (i > 0)?[button setHidden:YES]:NULL;
        
        [self addSubview:button];
        [arrSliderButtons_ addObject:button];
    }
} //F.E.

#pragma mark - buttons Handler
-(void) buttonsHandler:(id)sender {
    int indx = [sender tag];
    
    if (indx == 0)
    {self.on = !on_;}
    
    //Invoking funciton
    if ([delegate_ respondsToSelector:@selector(slidingButtonsViewHandler:button:buttonIndex:)]) {
        [delegate_ slidingButtonsViewHandler:self button:sender buttonIndex:indx];
    }
} //F.E.

#pragma mark - Overriden function for On/ Off
-(void) setOn:(BOOL)newOn {
    if (newOn == on_)
    {return;}
    //--
    on_ = newOn;
    [self startSliding];
}//F.E.

#pragma mark - Start Sliding
-(void) startSliding {
    
    if (timer_ && timer_.isValid) {
        return;
    }
    
    timer_ = nil;
    timer_ = [NSTimer scheduledTimerWithTimeInterval:0.05
                                              target:self
                                            selector:@selector(update:)
                                            userInfo:nil
                                             repeats:YES];
} //F.E.

-(void) update:(NSTimer*)timer {
    
    int noOfBtnDoneAnim = 0;
    
    for (int i = 0; i < arrSliderButtons_.count-1; i++) {
        
        //button instance from arr
        SliderButton * button = [arrSliderButtons_ objectAtIndex:i];
        
        CGRect curFrame = button.frame;
        
        CGRect newFrame;
        newFrame.size = curFrame.size;
        
        if (on_) {
            
            BOOL wait = false;
            
            if (i > 0) {
                wait = [self waitForPreviousButton:[arrSliderButtons_ objectAtIndex:i - 1]];
            }
            
            if (!wait) {
                switch (currSliderDirection_) {
                    case kSliderDirectionRight:
                        newFrame.origin.x = MIN(curFrame.origin.x + diff_.x, button.frameOn.origin.x);
                        newFrame.origin.y = curFrame.origin.y;
                        break;
                        
                    case kSliderDirectionLeft:
                        newFrame.origin.x = MAX(curFrame.origin.x + diff_.x, button.frameOn.origin.x);
                        newFrame.origin.y = curFrame.origin.y;
                        break;
                        
                    case kSliderDirectionDown:
                        newFrame.origin.x = curFrame.origin.x;
                        newFrame.origin.y = MIN(curFrame.origin.y + diff_.y, button.frameOn.origin.y);
                        break;
                        
                    case kSliderDirectionTop:
                        newFrame.origin.x = curFrame.origin.x;
                        newFrame.origin.y = MAX(curFrame.origin.y + diff_.y, button.frameOn.origin.y);
                        break;
                }
            }
            else {
                newFrame.origin = curFrame.origin;
            }
        
            if (CGRectEqualToRect(newFrame, button.frameOn))
            {noOfBtnDoneAnim++;}
//            if (i == 0 && timer && CGRectEqualToRect(newFrame, button.frameOn) && timer.isValid) {
//                [timer invalidate]; timer = nil; timer_ = nil;
//            }
        }
        else
        {
            switch (currSliderDirection_) {
                case kSliderDirectionRight:
                    newFrame.origin.x = MAX(curFrame.origin.x - diff_.x, button.frameOff.origin.x);
                    newFrame.origin.y = curFrame.origin.y;
                    break;
                    
                case kSliderDirectionLeft:
                    newFrame.origin.x = MIN(curFrame.origin.x - diff_.x, button.frameOff.origin.x);
                    newFrame.origin.y = curFrame.origin.y;
                    break;
                    
                case kSliderDirectionDown:
                    newFrame.origin.x = curFrame.origin.x;
                    newFrame.origin.y = MAX(curFrame.origin.y - diff_.y, button.frameOff.origin.y);
                    break;
                    
                case kSliderDirectionTop:
                    newFrame.origin.x = curFrame.origin.x;
                    newFrame.origin.y = MIN(curFrame.origin.y - diff_.y, button.frameOff.origin.y);
                    break;
            }
            
            if (CGRectEqualToRect(newFrame, button.frameOff))
            {noOfBtnDoneAnim++;}
//            
//            if (i == 0 && timer && CGRectEqualToRect(newFrame, button.frameOff) && timer.isValid) {
//                [timer invalidate]; timer = nil; timer_ = nil;
//            }
        }

        [button setFrame:newFrame];
    }

    //--

    if (timer && noOfBtnDoneAnim>=(arrSliderButtons_.count-1) && timer.isValid)
    {
        [timer invalidate]; timer = nil; timer_ = nil;
    }
} //F.E.

-(BOOL) waitForPreviousButton:(SliderButton*)previousButton {
    
    switch (currSliderDirection_) {
        case kSliderDirectionRight:
            if (previousButton.frame.origin.x >=  (refPos_.x + BUTTON_SPACING))
            {return false;}
            break;
            
        case kSliderDirectionLeft:
            if (previousButton.frame.origin.x <= (refPos_.x - BUTTON_SPACING))
            {return false;}
            break;
            
        case kSliderDirectionDown:
            if (previousButton.frame.origin.y >=  (refPos_.y + BUTTON_SPACING))
            {return false;}
            break;
            
        case kSliderDirectionTop:
            if (previousButton.frame.origin.y <=  (refPos_.y - BUTTON_SPACING))
            {return false;}
            break;
    }
    
    return true;
} //F.E.

@end
