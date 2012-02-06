//
//  TITokenFieldView.m
//  TITokenFieldView
//
//  Created by Tom Irving on 16/02/2010.
//  Copyright 2010 Tom Irving. All rights reserved.
//
//  Modified by Marc Winoto for iPad Compatibility

#import "TITokenFieldView.h"

#pragma mark - Private Additions Interfaces

@interface TITokenFieldView ()

@property (nonatomic, strong) NSMutableArray * tokensArray;
-(void) initialise:(CGRect)frame;

@end

#pragma mark - TITokenFieldView

@implementation TITokenFieldView

@synthesize showAlreadyTokenized;
@synthesize delegate;

@synthesize tokensArray;

@synthesize tokenField;
@synthesize addButton=_addButton;

@synthesize popoverSelector;
@synthesize summarise;

NSString * const kTextEmpty = @" "; // Just a space
NSString * const kTextHidden = @"`"; // This character isn't available on the iPhone (yet) so it's safe.

CGFloat const kShadowHeight = 10;
CGFloat const kTokenFieldHeight = 42;
CGFloat const kSeparatorHeight = 1;

#pragma mark - Main Shit

-(void) initialise:(CGRect)frame
{
    tokensArray = [[NSMutableArray alloc] init];
    self.backgroundColor = self.superview.backgroundColor;
    self.delaysContentTouches=NO;
    self.multipleTouchEnabled=NO;
    self.scrollEnabled=YES;
    
    showAlreadyTokenized = NO;
    summarise = NO;
    
    // The tokenfield
    tokenField = [[TITokenField alloc] initWithFrame:CGRectMake(0, 0, frame.size.width, kTokenFieldHeight)];
    //tokenField.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleTopMargin;
    [tokenField addTarget:self action:@selector(textFieldDidChange:) forControlEvents:UIControlEventEditingChanged];
    [tokenField setDelegate:self];
    [self addSubview:tokenField];
    tokenField.backgroundColor = self.backgroundColor;
    [self updateContentSize];
}

-(id) init
{
    if ((self = [super init]))
    {
        [self initialise:self.frame];
	}	
    return self;    
}

-(id) initWithCoder:(NSCoder *)aDecoder
{
    if ((self = [super initWithCoder:aDecoder]))
    {
        [self initialise:self.frame];
	}	
    return self;
}

- (id)initWithFrame:(CGRect)frame 
{	
    if ((self = [super initWithFrame:frame]))
    {
        [self initialise:frame];
	}	
    return self;
}

-(void) dealloc {
	[self setDelegate:nil];
}


-(void) setFrame:(CGRect)aFrame 
{
	[super setFrame:aFrame];
	
	CGFloat width = aFrame.size.width;
	[tokenField setWidth:width];
	
	[self updateHeight:YES];
	[self updateContentSize];
	
	[self layoutSubviews];
}

-(void) setContentOffset:(CGPoint)offset {
	
	[super setContentOffset:offset];
	[self layoutSubviews];
}


-(BOOL) canBecomeFirstResponder {
	return YES;
}

-(BOOL) becomeFirstResponder {
	return [tokenField becomeFirstResponder];
}

-(BOOL) resignFirstResponder {
	return [tokenField resignFirstResponder];
}

#pragma mark - Other locally declared methods

-(void) setPromptText:(NSString*)text
{
    UILabel * label = (UILabel*)self.tokenField.leftView;
    label.text = [text copy];
}

#pragma mark - Local methods
// FIXME: Un efficient. If we are running this when the field is loaded, we don't need to do much!
-(void) renderString
{
    // Remove all the tokens in the view
    NSArray * temp = [NSArray arrayWithArray:tokensArray];
	for (TIToken * token in temp) 
        [token removeFromSuperview];
	
	NSString * untokenized = [tokensArray count]>0? ((TIToken*)[tokensArray objectAtIndex:0]).title:@"";
    for (NSInteger i=1; i<[tokensArray count]; i++) {
        TIToken * t = [tokensArray objectAtIndex:i];
        untokenized = [untokenized stringByAppendingFormat:@", %@", t.title];
    }
	
	[self updateHeight:YES];
	
    if(summarise)
    {
        CGSize untokSize = [untokenized sizeWithFont:kSmallTokenFont];
        if (untokSize.width > self.frame.size.width - 120) {
            untokenized = [NSString stringWithFormat:@"%d %@", tokensArray.count, self.summaryText];
        }
	}
    tokenField.text = untokenized;
}

-(void) currentTokens:(NSSet*)tokens
{
    [self removeAllTokens];
    for(id obj in tokens)
    {
        [self setToken:(NSString*)[obj valueForKey:@"name"]];
    }
    [self renderString];
}

- (void)updateContentSize {	
    [self setContentSize:CGSizeMake(tokenField.frame.size.width, tokenField.frame.size.height) ];
}

#pragma mark - addButtonAction

-(void) addButtonAction:(id)control
{
    if(!self.popoverSelector)
    {
        [self.tokenField becomeFirstResponder];
    }
    else {
        UIButton * button = (UIButton*)control;
        [self.popoverSelector presentPopoverFromRect:button.frame 
                                              inView:button.superview
                            permittedArrowDirections:UIPopoverArrowDirectionUp 
                                            animated:YES];
    }
}

#pragma mark - TextField Methods

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField {

    return YES;
}

- (void)textFieldDidBeginEditing:(UITextField *)textField {
	
	if (![textField.text isEqualToString:kTextEmpty] && 
        ![textField.text isEqualToString:kTextHidden] && 
        ![textField.text isEqualToString:@""]){
		for (TIToken * t in tokensArray) 
            [tokenField addSubview:t];
	}
	
	[tokenField setText:kTextEmpty];
	[self updateHeight:NO];
}

- (BOOL)textFieldShouldEndEditing:(UITextField *)textField {
	[self processLeftoverText:textField.text];
	return YES;
}


-(void) textFieldDidEndEditing:(UITextField *)textField 
{	
    //NSArray * temp = [NSArray arrayWithArray:tokensArray];
	for (TIToken * token in tokensArray) 
    {
        [token removeFromSuperview];
    }
	    
	[self updateHeight:YES];
	
    [self renderString];
}


// FIXME: Fix this to make sure it is the right controller
- (void)textFieldDidChange:(UITextField *)textField {
    
	if ([textField.text isEqualToString:@""] || textField.text.length == 0){
		[textField setText:kTextEmpty];
	}
	
	if ([delegate respondsToSelector:@selector(tokenFieldTextDidChange:)]){
		[delegate tokenFieldTextDidChange:tokenField];
	}
    
    if([popoverSelector.contentViewController conformsToProtocol:@protocol(TITokenFieldSearchDelegate)])
    {
        NSString * trimmedText = [textField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
        id<TITokenFieldSearchDelegate> p = (id<TITokenFieldSearchDelegate>)popoverSelector.contentViewController;
        [p modifyPredicate:trimmedText];
    }
}

// !!!: Tokens are created here!
// !!!: Tokens are deleted here too!
- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string 
{	
	if ([string isEqualToString:@""] && [textField.text isEqualToString:kTextEmpty] && tokensArray.count)
    {
		//When the backspace is pressed, we capture it, highlight the last token, and hide the cursor.
		TIToken * tok = [tokensArray lastObject];
		tok.highlighted = YES;
		tokenField.text = kTextHidden;
		[self updateHeight:NO];
		
		return NO;
	}
	
	if ([textField.text isEqualToString:kTextHidden] && ![string isEqualToString:@""]) {
        // When the text is hidden, we don't want the user to be able to type anything.
        return NO;
	}
	
	if ([textField.text	isEqualToString:kTextHidden] && [string isEqualToString:@""]) {
        // When the user presses backspace and the text is hidden,
        // we find the highlighted token, and remove it.
        NSArray * temp = [NSArray arrayWithArray:tokensArray];
        for (TIToken * tok in temp) 
        {
            if (tok.highlighted) 
            {
                NSString * title = [tok.title copy];
                [self removeToken:tok];
                [delegate tokenField:tokenField removedToken:title];
                return NO;
            }
        }
    }
	
	if ([string isEqualToString:@","]){
		[self processLeftoverText:textField.text];
		return NO;
	}
	
    // Add token if they enter a space.
    // This should not be here
    if([string isEqualToString:@" "])
    {        
        [self processLeftoverText:textField.text];
        return NO;
    }
    
    CGPoint point = tokenField.cursorLocation;
    CGRect frame = textField.frame;
    CGRect pof = CGRectMake(point.x, point.y, 0.0, frame.size.height);
    
    [popoverSelector presentPopoverFromRect:pof
                                     inView:self
                   permittedArrowDirections:UIPopoverArrowDirectionUp
                                   animated:YES];
	return YES;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
	
	[self processLeftoverText:textField.text];
	
	if ([delegate respondsToSelector:@selector(tokenFieldShouldReturn:)]){
		return [delegate tokenFieldShouldReturn:tokenField];
	}
	
	return YES;
}

//Called when some sort of delimiter character is typed
- (void)processLeftoverText:(NSString *)text
{
    [popoverSelector dismissPopoverAnimated:YES];
    NSString * trimmedText = [text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
        
	if (![trimmedText isEqualToString:kTextEmpty] && ![trimmedText isEqualToString:kTextHidden] && 
		[[trimmedText stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] length] != 0)
    {
        //NSUInteger loc = [[text substringWithRange:NSMakeRange(0, 1)] isEqualToString:@" "] ? 1 : 0;
        //[tokenField addToken:[text substringWithRange:NSMakeRange(loc, text.length - 1)]];
        
        [self addToken:trimmedText];
	}
}

- (void)tokenFieldResized:(TITokenField *)aTokenField {
	//[self setContentSize:CGSizeMake(self.frame.size.width, self.contentView.frame.origin.y + self.contentView.frame.size.height + 2)];
	[self updateContentSize];
	if ([delegate respondsToSelector:@selector(tokenField:didChangeToFrame:)]){
		[delegate tokenField:aTokenField didChangeToFrame:aTokenField.frame];
	}
}

- (NSString *)description {
	return [NSString stringWithFormat:@"<TITokenFieldView %p 'Token count: %d'>", self, [tokensArray count]];
}

#pragma mark - UIPopoverControllerDelegate

-(void) popoverControllerDidDismissPopover:(UIPopoverController *)popoverController
{
    
}

- (BOOL)popoverControllerShouldDismissPopover:(UIPopoverController *)popoverController
{
    return YES;
}

#pragma mark - custom setters

-(void) setAddButton:(UIButton *)addButton
{
    _addButton = addButton;
    [_addButton addTarget:self action:@selector(addButtonAction:) forControlEvents:UIControlEventTouchUpInside];
}


#pragma mark - methods that used to be in the TITokenField

// ???: kTextEmpty
-(void) setToken:(NSString *)title
{
    if (title)
    {
		TIToken * token = [[TIToken alloc] initWithTitle:title];
		[token setDelegate:self];
		[tokensArray addObject:token];
	}
}

- (void)addToken:(NSString *)title
{	
    if (title)
    {
        if([delegate tokenField:tokenField shouldAddToken:title])
        {
            TIToken * token = [[TIToken alloc] initWithTitle:title];
            [token setDelegate:self];
            [tokensArray addObject:token];
         
            [delegate tokenField:tokenField addedToken:title];
            
            if ([tokenField isFirstResponder]) {
                [tokenField addSubview:token];
                [self updateHeight:NO];
                [tokenField setText:kTextEmpty];
            }
            else
                [self renderString];//tokenField.text = [tokenField.text stringByAppendingFormat:@", %@", title];
        }
    }
}

-(void) removeToken:(TIToken *)token
{
    [token removeFromSuperview];
	[tokensArray removeObject:token];
	tokenField.text = kTextEmpty;
	[self updateHeight:NO];
}

-(void) removeAllTokens
{
    NSArray * temp = [NSArray arrayWithArray:tokensArray];
    for(TIToken * tok in temp)
        [self removeToken:tok];
}

- (CGFloat)layoutTokens 
{	
	// Adapted from Joe Hewitt's Three20 layout method.
	CGFloat fontHeight = (tokenField.font.ascender - tokenField.font.descender) + 1;
	//CGFloat lineHeight = fontHeight + 15;
	CGFloat topMargin = floor(fontHeight / 1.75);
	CGFloat leftMargin = 8;//self.leftView ? self.leftView.frame.size.width + 12 : 8;
	//CGFloat rightMargin = 16;
	//CGFloat rightMarginWithButton = self.rightView.hidden ? 8 : self.rightView.frame.size.width+12;
	//CGFloat initialPadding = leftMargin;
	CGFloat tokenPadding = 4;
	
	tokenField.numberOfLines = 1;
	CGFloat cursorLocationX = leftMargin;//tokenField.cursorLocation.x = leftMargin;
	CGFloat cursorLocationY = topMargin-1;//tokenField.cursorLocation.y = topMargin - 1;
	
	NSArray * tokens = [[NSArray alloc] initWithArray:tokensArray];
	
    if(tokenField.isFirstResponder)
    {
        for (TIToken * token in tokens)
        {
            /*
             CGFloat lineWidth = cursorLocation.x + token.frame.size.width + rightMargin;
             if (lineWidth >= self.frame.size.width)
             {
             numberOfLines++;
             cursorLocation.x = leftMargin;
             
             if (numberOfLines > 1)
             cursorLocation.x = initialPadding;
             cursorLocation.y += lineHeight;
             }
             */
            CGRect oldFrame = CGRectMake(token.frame.origin.x, token.frame.origin.y, token.frame.size.width, token.frame.size.height);
            CGRect newFrame = CGRectMake(cursorLocationX, cursorLocationY, token.frame.size.width, token.frame.size.height);
            
            if (!CGRectEqualToRect(oldFrame, newFrame)) {
                [token setFrame:newFrame];
                [token setAlpha:0.6];
                [UIView animateWithDuration:0.3 animations:^{[token setAlpha:1];}];
            }
            
            cursorLocationX += token.frame.size.width + tokenPadding;
        }
	}
    /*
     CGFloat leftoverWidth = self.frame.size.width - (cursorLocation.x + rightMarginWithButton);
     if (leftoverWidth < 50)
     {
     numberOfLines++;
     cursorLocation.x = leftMargin;
     
     if (numberOfLines > 1) cursorLocation.x = initialPadding;
     cursorLocation.y += lineHeight;
     }
     */
    
	CGFloat cl = round(cursorLocationY + fontHeight + topMargin + 5);
    
    if(cursorLocationX+160 > self.frame.size.width)
        tokenField.frame = CGRectMake(tokenField.frame.origin.x, tokenField.frame.origin.y, cursorLocationX+160, tokenField.frame.size.height);
    else if(cursorLocationX+160 < self.frame.size.width)
        tokenField.frame = CGRectMake(tokenField.frame.origin.x, tokenField.frame.origin.y, self.frame.size.width, tokenField.frame.size.height);
    
    
    tokenField.cursorLocation = CGPointMake(cursorLocationX, cursorLocationY);
    [self setContentSize:CGSizeMake(tokenField.frame.size.width, tokenField.frame.size.height)];
    return cl;
}

#pragma mark - Previously Private Methods

typedef void (^AnimationBlock)();

- (void)updateHeight:(BOOL)scrollToTop {
	
	CGFloat previousHeight = tokenField.frame.size.height;
	CGFloat newHeight = [self layoutTokens];
	
	if (previousHeight && previousHeight != newHeight)
    {
		// Animating this seems to invoke the triple-tap-delete-key-loop-problem-thing™
		// No idea why, but for now, obviously we won't animate this stuff.
		
		AnimationBlock animationBlock = ^{
			[self setHeight:newHeight];
		};
		
		if (previousHeight < newHeight)
			[UIView animateWithDuration:0.3 animations:^{animationBlock();}];
		else
			animationBlock();
		
		[self tokenFieldResized:tokenField];
	}
	
	if (scrollToTop) 
        [self setContentOffset:CGPointMake(0, 0) animated:YES];
}

- (void)scrollForEdit:(BOOL)shouldMove
{
	TITokenFieldView * parentView = (TITokenFieldView *)self.superview;
    
	[parentView setScrollsToTop:!shouldMove];
	[parentView setScrollEnabled:!shouldMove];
    
	CGFloat offset = tokenField.numberOfLines == 1 || !shouldMove ? 0 : (self.frame.size.height - kTokenFieldHeight) + 1;
	[parentView setContentOffset:CGPointMake(0, self.frame.origin.y + offset) animated:YES];
}


#pragma mark - TITokenDelegate

//-(void) tokenLostFocus:(TIToken *)token

//???: This used to copy the tokens
- (void)tokenGotFocus:(TIToken *)token 
{	
	//NSArray * tokens = [[NSArray alloc] initWithArray:tokensArray];
	for (TIToken * tok in tokensArray)
		if (tok != token)
            [tok setHighlighted:NO];
    
	if (!tokenField.isFirstResponder)
        [tokenField becomeFirstResponder];
    
	tokenField.text = kTextHidden;
}

-(void) deselectAll
{
    for (TIToken * token in tokensArray) 
        [token setHighlighted:NO];

}


-(UIView *)hitTest:(CGPoint)point withEvent:(UIEvent*)event {
    UIView *hitView = [super hitTest:point withEvent:event];
    
    if([hitView class] == [TITokenField class]) {
        [(TITokenField *) hitView handleTap:point];
        [self deselectAll];
        return self;
    } 
    else if([hitView class] == [TIToken class]) {
        [(TIToken *) hitView handleTap:point];
        //[tokenField handleTap:point];
        return self;
    }
    else {
        NSLog(@"HitView Failed: %@", [hitView.class description]);
    }
    
    return hitView;    
}

-(void) backgroundColor:(UIColor*)color
{
    super.backgroundColor = color;
    tokenField.backgroundColor = color;
}

@end
