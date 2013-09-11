//
//  SlideButtonsView.m
//  ButtonSlider
//
//  Created by Shoaib Mac Mini on 04/09/2013.
//  Copyright (c) 2013 Shoaib Mac Mini. All rights reserved.
//

#import "SlidingButtonsView.h"

#pragma mark - SliderButton interface
@interface SliderButtonModel : NSObject
{
    CGRect frameOff_, frameOn_;
    UIButton* button_;
}

@property (nonatomic) CGRect frameOn;
@property (nonatomic) CGRect frameOff;
@property (nonatomic, assign) UIButton* button;

+(id) button:(UIButton*)btn;
+(id) button:(UIButton*)btn FrameOn:(CGRect)frmOn FrameOff:(CGRect)frmOff;
-(id) initWithButton:(UIButton*)btn FrameOn:(CGRect)frmOn FrameOff:(CGRect)frmOff;
@end

#pragma mark - SliderButton implementation
@implementation SliderButtonModel
@synthesize frameOn = frameOn_, frameOff = frameOff_, button = button_;

+(id) button:(UIButton*)btn {
    return [self button:btn FrameOn:CGRectZero FrameOff:CGRectZero];
} //F.E.

+(id) button:(UIButton*)btn FrameOn:(CGRect)frmOn FrameOff:(CGRect)frmOff {
    return [[[self alloc] initWithButton:btn FrameOn:frmOn FrameOff:frmOff] autorelease];
} //F.E.

-(id) initWithButton:(UIButton*)btn FrameOn:(CGRect)frmOn FrameOff:(CGRect)frmOff {
    if (self = [super init]) {
        button_ = btn;
        frameOn_ = frmOn;
        frameOff_ = frmOff;        
    }
    return self;
} //F.E.
@end

#pragma mark - SlideButtonsView implementation
@implementation SlidingButtonsView
@synthesize on = on_, delegate = delegate_;

#pragma mark - init
- (id)initWithDirection:(SliderDirection)sldDir Position:(CGPoint)pos ButtonImageNames:(id)firstObj, ... NS_REQUIRES_NIL_TERMINATION
{
    self = [super initWithFrame:CGRectMake(pos.x, pos.y, 0, 0)];
    
    if (self) {
        //Setting Slider Direction
        currSliderDirection_ = sldDir;
        relPos_ = pos;
        
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
            //--
            buttonSize_  =   [UIImage imageNamed:[arr objectAtIndex:0]].size;
        }
        
        //Setting Slider Buttons
        [self setupSliderWithButtonImageNames:arr];
    }
    return self;
} //F.E.

- (id)initWithDirection:(SliderDirection)sldDir Position:(CGPoint)pos ButtonSize:(CGSize)btnSize Buttons:(UIButton*)firstObj, ... NS_REQUIRES_NIL_TERMINATION
{
    self = [super initWithFrame:CGRectMake(pos.x, pos.y, 0, 0)];
    
    if (self) {
        //Setting Slider Direction
        currSliderDirection_ = sldDir;
        relPos_ = pos;
        
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
            //--
            buttonSize_  =   btnSize;
        }
        
        //Setting Slider Buttons
        [self setupSliderWithButtons:arr];
    }
    return self;
} //F.E.

#pragma mark - setting up buttons
-(void) setupSliderWithButtonImageNames:(NSMutableArray*)arrButtonImageNames {
    assert(arrButtonImageNames.count>1); // Buttons should not be less than 1
    

    arrSliderButtons_  = [[NSMutableArray alloc] init];
    
    buttonPos_ = [self updateFrameWithNoOfItems:arrButtonImageNames.count];
    

    for (int i = 0; i < arrButtonImageNames.count; i++) {
        UIButton* button = [UIButton buttonWithType:UIButtonTypeCustom];
        button.tag = i;
        
        [button setTitle:[NSString stringWithFormat:@"%d", i] forState:UIControlStateNormal];
        [button setTitleColor:[UIColor redColor] forState:UIControlStateNormal];

        [button setBackgroundImage:[UIImage imageNamed:[arrButtonImageNames objectAtIndex:i]] forState:UIControlStateNormal];
        //[button setImage:[UIImage imageNamed:[arrButtons objectAtIndex:i]] forState:UIControlStateNormal];
        
        [button addTarget:self action:@selector(buttonsHandler:) forControlEvents:UIControlEventTouchUpInside];
        
        [self addWithButton:button NoOfItems:arrButtonImageNames.count];
    }
} //F.E.

-(void) setupSliderWithButtons:(NSMutableArray*)arrButtons {
    assert(arrButtons.count>1); // Buttons should not be less than 1
    
    
    arrSliderButtons_   =   [[NSMutableArray alloc] init];
    
    buttonPos_   =   [self updateFrameWithNoOfItems:arrButtons.count];
    
    
    for (int i = 0; i < arrButtons.count; i++) {
        UIButton* button = [arrButtons objectAtIndex:i];
        button.tag = i;
        
//        [button setTitle:[NSString stringWithFormat:@"%d", i] forState:UIControlStateNormal];
//        [button setTitleColor:[UIColor redColor] forState:UIControlStateNormal];
//        
//        [button setBackgroundImage:[UIImage imageNamed:@"button.png"] forState:UIControlStateNormal];
        
        [button addTarget:self action:@selector(buttonsHandler:) forControlEvents:UIControlEventTouchUpInside];
        
        [self addWithButton:button NoOfItems:arrButtons.count];
    }
} //F.E.

#pragma mark - update container frame
-(CGPoint)updateFrameWithNoOfItems:(int)noOfItems {
    CGPoint buttonPos;
    switch (currSliderDirection_) {
        case kSliderDirectionRight:
            [self setFrame:CGRectMake(relPos_.x, relPos_.y, (buttonSize_.width + BUTTON_SPACING) * noOfItems, buttonSize_.height)];
            buttonPos = CGPointMake(0, 0);
            break;
            
        case kSliderDirectionLeft:
            [self setFrame:CGRectMake(relPos_.x - ((buttonSize_.width + BUTTON_SPACING) * (noOfItems - 1)) -  (BUTTON_SPACING), relPos_.y, (buttonSize_.width + BUTTON_SPACING) * noOfItems, buttonSize_.height)];
            buttonPos = CGPointMake(((buttonSize_.width + BUTTON_SPACING) * (noOfItems - 1)) + BUTTON_SPACING, 0);
            break;
            
        case kSliderDirectionDown:
            [self setFrame:CGRectMake(relPos_.x, relPos_.y, buttonSize_.width, (buttonSize_.height + BUTTON_SPACING) * noOfItems)];
            buttonPos = CGPointMake(0, 0);
            break;
            
        case kSliderDirectionTop:
            [self setFrame:CGRectMake(relPos_.x, relPos_.y - ((buttonSize_.height + BUTTON_SPACING) * (noOfItems - 1)) -  (BUTTON_SPACING), buttonSize_.width, (buttonSize_.height + BUTTON_SPACING) * noOfItems)];
            buttonPos = CGPointMake(0, ((buttonSize_.height + BUTTON_SPACING) * (noOfItems - 1)) + BUTTON_SPACING);
            break;
    }
    
    return buttonPos;
} //F.E.

#pragma mark - Add Button
-(void) addWithButton:(UIButton*)button {
    [self addWithButton:button NoOfItems:arrSliderButtons_.count+1];
} //F.E.

-(void) addWithButton:(UIButton*)button NoOfItems:(int)noOfItems {
    
    SliderButtonModel* sliderButtonModel = [SliderButtonModel button:button];
    
    [self updateButtonModel:sliderButtonModel NoOfItems:noOfItems];
    
    [self addSubview:button];
    [self sendSubviewToBack:button];
    
    [arrSliderButtons_ addObject:sliderButtonModel];
} //F.E.

#pragma mark - Update Button Model
-(void) updateButtonModel:(SliderButtonModel*)sliderButtonModel NoOfItems:(int)noOfItems {
    CGRect frameOn, frameOff;
    frameOn.size = buttonSize_;
    
    int i = arrSliderButtons_.count;
    
    switch (currSliderDirection_) {
        case kSliderDirectionRight:
            frameOn.origin.x = (buttonSize_.width + BUTTON_SPACING) * i;//buttonPos.x;
            frameOn.origin.y = buttonPos_.y;
            break;
            
        case kSliderDirectionLeft:
            frameOn.origin.x = ((buttonSize_.width + BUTTON_SPACING) * (noOfItems - i - 1)) + BUTTON_SPACING;
            frameOn.origin.y = buttonPos_.y;
            break;
            
        case kSliderDirectionDown:
            frameOn.origin.x = buttonPos_.x;
            frameOn.origin.y = (buttonSize_.height + BUTTON_SPACING) * i;//buttonPos.y;
            break;
            
        case kSliderDirectionTop:
            frameOn.origin.x = buttonPos_.x;
            frameOn.origin.y = ((buttonSize_.height + BUTTON_SPACING) * (noOfItems - i - 1) + BUTTON_SPACING);
            break;
    }
    
    frameOff = CGRectMake(buttonPos_.x, buttonPos_.y, buttonSize_.width, buttonSize_.height);
    
    if (i == noOfItems-1) {
        diff_ = CGPointMake(((frameOn.origin.x - frameOff.origin.x) * (SLIDING_SPEED/2.0f)), ((frameOn.origin.y - frameOff.origin.y) * (SLIDING_SPEED/2.0f)));
    }
    
    if (i == 1) {
        refPos_ = frameOn.origin;
    }
    
    sliderButtonModel.frameOn = frameOn;
    sliderButtonModel.frameOff = frameOff;
    //--
    [sliderButtonModel.button setFrame: frameOff];
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

#pragma mark - Updater
-(void) update:(NSTimer*)timer {
    
    int noOfBtnDoneAnim = 0;
    
    for (int i = arrSliderButtons_.count-1; i >0 ; i--) {
        
        //button instance from arr
        SliderButtonModel * buttonModel = ((SliderButtonModel*)[arrSliderButtons_ objectAtIndex:i]);
        
        CGRect curFrame = buttonModel.button.frame;
        
        CGRect newFrame;
        newFrame.size = curFrame.size;
        
        if (on_) {
            
            BOOL wait = false;
            
            if (i < arrSliderButtons_.count-2) {
                wait = [self waitForPreviousButton:((SliderButtonModel*)[arrSliderButtons_ objectAtIndex:i+1]).button];
            }
            
            if (!wait) {
                switch (currSliderDirection_) {
                    case kSliderDirectionRight:
                        newFrame.origin.x = MIN(curFrame.origin.x + diff_.x, buttonModel.frameOn.origin.x);
                        newFrame.origin.y = curFrame.origin.y;
                        break;
                        
                    case kSliderDirectionLeft:
                        newFrame.origin.x = MAX(curFrame.origin.x + diff_.x, buttonModel.frameOn.origin.x);
                        newFrame.origin.y = curFrame.origin.y;
                        break;
                        
                    case kSliderDirectionDown:
                        newFrame.origin.x = curFrame.origin.x;
                        newFrame.origin.y = MIN(curFrame.origin.y + diff_.y, buttonModel.frameOn.origin.y);
                        break;
                        
                    case kSliderDirectionTop:
                        newFrame.origin.x = curFrame.origin.x;
                        newFrame.origin.y = MAX(curFrame.origin.y + diff_.y, buttonModel.frameOn.origin.y);
                        break;
                }
            }
            else {
                newFrame.origin = curFrame.origin;
            }
        
            if (CGRectEqualToRect(newFrame, buttonModel.frameOn))
            {noOfBtnDoneAnim++;}
//            if (i == 0 && timer && CGRectEqualToRect(newFrame, button.frameOn) && timer.isValid) {
//                [timer invalidate]; timer = nil; timer_ = nil;
//            }
        }
        else
        {
            switch (currSliderDirection_) {
                case kSliderDirectionRight:
                    newFrame.origin.x = MAX(curFrame.origin.x - diff_.x, buttonModel.frameOff.origin.x);
                    newFrame.origin.y = curFrame.origin.y;
                    break;
                    
                case kSliderDirectionLeft:
                    newFrame.origin.x = MIN(curFrame.origin.x - diff_.x, buttonModel.frameOff.origin.x);
                    newFrame.origin.y = curFrame.origin.y;
                    break;
                    
                case kSliderDirectionDown:
                    newFrame.origin.x = curFrame.origin.x;
                    newFrame.origin.y = MAX(curFrame.origin.y - diff_.y, buttonModel.frameOff.origin.y);
                    break;
                    
                case kSliderDirectionTop:
                    newFrame.origin.x = curFrame.origin.x;
                    newFrame.origin.y = MIN(curFrame.origin.y - diff_.y, buttonModel.frameOff.origin.y);
                    break;
            }
            
            if (CGRectEqualToRect(newFrame, buttonModel.frameOff))
            {noOfBtnDoneAnim++;}
//            
//            if (i == 0 && timer && CGRectEqualToRect(newFrame, button.frameOff) && timer.isValid) {
//                [timer invalidate]; timer = nil; timer_ = nil;
//            }
        }
        
        [buttonModel.button setFrame:newFrame];
    }

    //--

    if (timer && noOfBtnDoneAnim>=(arrSliderButtons_.count-1) && timer.isValid)
    {
        [timer invalidate]; timer = nil; timer_ = nil;
    }
} //F.E.

#pragma mark - Waiting
-(BOOL) waitForPreviousButton:(UIButton*)previousButton {
    
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

#pragma mark - dealloc
-(void) dealloc {
    if (arrSliderButtons_) {
        [arrSliderButtons_ removeAllObjects];
        [arrSliderButtons_ release];
        arrSliderButtons_ = nil;
    }
    //--
    if (timer_) {
        if (timer_.isValid)
        {[timer_ invalidate];}
        //--
        timer_ = nil;
    }
    [super dealloc];
} //F.E.

@end
