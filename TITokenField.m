//
//  TITokenField.m
//  RecipeBook
//
//  Created by Marc Winoto on 29/01/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "TITokenField.h"

#pragma mark - TITokenField



@implementation TITokenField
@synthesize numberOfLines;
@synthesize cursorLocation;

- (id)initWithFrame:(CGRect)frame 
{	
    if ((self = [super initWithFrame:frame]))
    {
		//self.borderStyle = UITextBorderStyleRoundedRect;
        self.backgroundColor = [UIColor grayColor]; //self.superview.backgroundColor;
		self.textColor = [UIColor blackColor];
		self.font = kSmallTokenFont;
		self.autocorrectionType = UITextAutocorrectionTypeNo;
		self.autocapitalizationType = UITextAutocapitalizationTypeNone;
		self.textAlignment = NSTextAlignmentLeft;
		self.keyboardType = UIKeyboardTypeDefault;
		self.returnKeyType = UIReturnKeyDefault;
		self.clearsOnBeginEditing = NO;

		// We don't just set a leftside view
		// as it centers vertically on resize.
		// This is not something we want,
		// so instead, we add a subview.
		self.text = kTextEmpty;
        self.contentVerticalAlignment = UIControlContentVerticalAlignmentTop;
        
    }
	
    return self;
}

- (void)dealloc 
{
	[self setDelegate:nil];
}

#pragma mark - TITokenField Token Handlers

#pragma mark View Handlers

-(void) handleTap:(CGPoint) point {
    if(self.isFirstResponder)
       	[self setText:kTextEmpty];
    else
        [self becomeFirstResponder];
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
	
	//UITouch * touch = [[event allTouches] anyObject];
	//CGPoint loc = [touch locationInView:self];
	
    // When we lose firsSResponder status, we should be cleaning up
	//NSArray * tokens = [[NSArray alloc] initWithArray:tokensArray];
	//for (TIToken * token in tokens) 
    //    [token setHighlighted:NO];
	
	if ([self.text isEqualToString:kTextHidden]) 
    {
        [self setText:kTextEmpty];
        TITokenFieldView * t = (TITokenFieldView*)self.superview;
        [t deselectAll];
	}
	[super touchesBegan:touches withEvent:event];
}

#pragma mark - Override methods from UITextField
// FIXME: The button view may not need to be taken into account anymore.
- (CGRect)textRectForBounds:(CGRect)bounds 
{
	if ([self.text isEqualToString:kTextHidden]) 
        return CGRectMake(0, -20, 0, 0);
	
	CGRect frame = CGRectOffset(bounds, cursorLocation.x, cursorLocation.y + 3);
	frame.size.width -= cursorLocation.x + (self.rightView.hidden ? 0 : 24) + 8;
	return frame;
}

- (CGRect)editingRectForBounds:(CGRect)bounds 
{
	return [self textRectForBounds:bounds];
}

- (CGRect)placeholderRectForBounds:(CGRect)bounds 
{
	return [self textRectForBounds:bounds];
}

/*
- (NSMutableArray *)getTokenTitles 
{
	NSMutableArray * titles = [[NSMutableArray alloc] init];
	
	NSArray * tokens = [[NSArray alloc] initWithArray:tokensArray];
	for (TIToken * token in tokens) 
        [titles addObject:token.title];
	
	return titles;
}
*/

@end
