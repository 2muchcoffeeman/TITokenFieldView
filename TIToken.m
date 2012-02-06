//
//  TIToken.m
//  RecipeBook
//
//  Created by Marc Winoto on 29/01/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "TIToken.h"

#define kTokenTitleFont [UIFont fontWithName:@"Verdana" size:14.0]
//[UIFont systemFontOfSize:14]

@implementation TIToken
@synthesize highlighted;
@synthesize title;
@synthesize delegate;
@synthesize croppedTitle;
@synthesize tintColor;

- (id)initWithTitle:(NSString *)aTitle 
{	
	if ((self = [super init]))
    {
		title = [aTitle copy];
		croppedTitle = [(aTitle.length > 24 ? [[aTitle substringToIndex:24] stringByAppendingString:@"..."] : aTitle) copy];
		
		tintColor = [UIColor colorWithRed:0.367 green:0.406 blue:0.973 alpha:1];
		//tintColor = [[UIColor grayColor] retain];
		
		CGSize tokenSize = [croppedTitle sizeWithFont:kTokenTitleFont];
		
		//We lay the tokens out all at once, so it doesn't matter what the X,Y coords are.
		[self setFrame:CGRectMake(0, 0, tokenSize.width + 17, tokenSize.height + 8)];
		[self setBackgroundColor:[UIColor clearColor]];
		
		UILongPressGestureRecognizer * longPressRecognizer = [[UILongPressGestureRecognizer alloc] initWithTarget:self 
																										   action:@selector(tokenWasPressed:)];
		[longPressRecognizer setMinimumPressDuration:0];
		[self addGestureRecognizer:longPressRecognizer];
	}
	
	return self;
}

- (void)drawRect:(CGRect)rect 
{	
	CGContextRef context = UIGraphicsGetCurrentContext();

	CGSize titleSize = [croppedTitle sizeWithFont:kTokenTitleFont];
	
	CGRect bounds = CGRectMake(0, 0, titleSize.width + 17, titleSize.height + 5);
	CGRect textBounds = bounds;
	textBounds.origin.x = (bounds.size.width - titleSize.width) / 2;
	textBounds.origin.y += 4;
	
	CGFloat arcValue = (bounds.size.height / 2) + 1;
	
	CGColorSpaceRef colorspace = CGColorSpaceCreateDeviceRGB();
	CGPoint endPoint = CGPointMake(1, self.bounds.size.height + 10);
	
	// Draw the outline.
	CGContextSaveGState(context);
	CGContextBeginPath(context);
	CGContextAddArc(context, arcValue, arcValue, arcValue, (M_PI / 2), (3 * M_PI / 2), NO);
	CGContextAddArc(context, bounds.size.width - arcValue, arcValue, arcValue, 3 * M_PI / 2, M_PI / 2, NO);
	CGContextClosePath(context);
	
	CGFloat red = 1;
	CGFloat green = 1;
	CGFloat blue = 1;
	CGFloat alpha = 1;
	[tintColor ti_getRed:&red green:&green blue:&blue alpha:&alpha];
	
	if (highlighted){
        // highlighted outline color
		CGContextSetFillColor(context, (CGFloat[8]){red, green, blue, 1});
		CGContextFillPath(context);
		CGContextRestoreGState(context);
	}
	else
	{
		CGContextClip(context);
		CGFloat locations[2] = {0, 0.95};
        // unhighlighted outline color
		CGFloat components[8] = {red + .2, green +.2, blue +.2, alpha, red, green, blue, alpha};
		CGGradientRef gradient = CGGradientCreateWithColorComponents(colorspace, components, locations, 2);
		CGContextDrawLinearGradient(context, gradient, CGPointZero, endPoint, 0);
		CGGradientRelease(gradient);
		CGContextRestoreGState(context);
	}
    
    // Draw a white background so we can use alpha to lighten the inner gradient
    CGContextSaveGState(context);
	CGContextBeginPath(context);
	CGContextAddArc(context, arcValue, arcValue, (bounds.size.height / 2), (M_PI / 2) , (3 * M_PI / 2), NO);
	CGContextAddArc(context, bounds.size.width - arcValue, arcValue, arcValue - 1, (3 * M_PI / 2), (M_PI / 2), NO);
	CGContextClosePath(context);
    CGContextSetFillColor(context, (CGFloat[8]){1, 1, 1, 1});
    CGContextFillPath(context);
    CGContextRestoreGState(context);
	
	// Draw the inner gradient.
	CGContextSaveGState(context);
	CGContextBeginPath(context);
	CGContextAddArc(context, arcValue, arcValue, (bounds.size.height / 2), (M_PI / 2) , (3 * M_PI / 2), NO);
	CGContextAddArc(context, bounds.size.width - arcValue, arcValue, arcValue - 1, (3 * M_PI / 2), (M_PI / 2), NO);
	CGContextClosePath(context);
	
	CGContextClip(context);
	
	CGFloat locations[2] = {0, highlighted ? 0.8 : 0.4};
    CGFloat highlightedComp[8] = {red, green, blue, .6, red, green, blue, 1};
    CGFloat nonHighlightedComp[8] = {red, green, blue, .2, red, green, blue, .4};
    
	CGGradientRef gradient = CGGradientCreateWithColorComponents (colorspace, highlighted ? highlightedComp : nonHighlightedComp, locations, 2);
	CGContextDrawLinearGradient(context, gradient, CGPointZero, endPoint, 0);
	CGGradientRelease(gradient);
	CGColorSpaceRelease(colorspace);
	
	[(highlighted ? [UIColor whiteColor] : [UIColor blackColor]) set];
	[croppedTitle drawInRect:textBounds withFont:kTokenTitleFont];
	
	CGContextRestoreGState(context);
}

- (void)tokenWasPressed:(UIGestureRecognizer *)gestureRecognizer {
	
	if (gestureRecognizer.state == UIGestureRecognizerStateChanged || gestureRecognizer.state == UIGestureRecognizerStateBegan){
		
		highlighted = CGRectContainsPoint(self.bounds, [gestureRecognizer locationInView:self]);
		[self setNeedsDisplay];
	}
	
	if (gestureRecognizer.state == UIGestureRecognizerStateEnded) [self setHighlighted:highlighted];
}

- (void)setHighlighted:(BOOL)flag {
	
	if (highlighted != flag){
		highlighted = flag;
		[self setNeedsDisplay];
	}
	
	if (flag && [delegate respondsToSelector:@selector(tokenGotFocus:)]){
		[delegate tokenGotFocus:self];
	}
	
	if (!flag && [delegate respondsToSelector:@selector(tokenLostFocus:)]){
		[delegate tokenLostFocus:self];
	}
}

- (void)setTintColor:(UIColor *)newTintColor {
	
	if (!newTintColor) newTintColor = [UIColor colorWithRed:0.867 green:0.906 blue:0.973 alpha:1];
	
	tintColor = newTintColor;
	
	[self setNeedsDisplay];
}

- (NSString *)description {
	return [NSString stringWithFormat:@"<TIToken %p '%@'>", self, title];
}

- (void)dealloc {
	[self setDelegate:nil];
}

-(void) handleTap:(CGPoint) point {
    // Implement your handling code here
    NSLog(@"Token %f %f", point.x, point.y);
    [self setHighlighted:YES];
}

@end