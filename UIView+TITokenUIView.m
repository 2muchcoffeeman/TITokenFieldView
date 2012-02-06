//
//  UIView+TITokenUIView.m
//  RecipeBook
//
//  Created by Marc Winoto on 29/01/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "UIView+TITokenUIView.h"

@implementation UIView (TITokenUIView)

- (void)setHeight:(CGFloat)height {
	
	CGRect newFrame = self.frame;
	newFrame.size.height = height;
	[self setFrame:newFrame];
}

- (void)setWidth:(CGFloat)width {
	
	CGRect newFrame = self.frame;
	newFrame.size.width = width;
	[self setFrame:newFrame];
}

- (void)setOriginY:(CGFloat)originY {
	
	CGRect newFrame = self.frame;
	newFrame.origin.y = originY;
	[self setFrame:newFrame];
}

@end
