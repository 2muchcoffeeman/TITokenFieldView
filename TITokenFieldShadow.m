//
//  TITokenFieldShadow.m
//  RecipeBook
//
//  Created by Marc Winoto on 29/01/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "TITokenFieldShadow.h"

#pragma mark - TITokenFieldShadow

@implementation TITokenFieldShadow

- (id)initWithFrame:(CGRect)frame {
	
    if ((self = [super initWithFrame:frame])){
		[self setBackgroundColor:[UIColor clearColor]];
    }
	
    return self;
}


- (void)drawRect:(CGRect)rect {
	
	CGContextRef context = UIGraphicsGetCurrentContext();
	CGFloat components[8] = {0, 0, 0, 0.23, 0, 0, 0, 0};
	
	CGColorSpaceRef space = CGBitmapContextGetColorSpace(context);
	CGGradientRef gradient = CGGradientCreateWithColorComponents(space, components, nil, 2);
	
	CGPoint finish = CGPointMake(rect.origin.x, rect.origin.y + rect.size.height);
	CGContextDrawLinearGradient(context, gradient, rect.origin, finish, kCGGradientDrawsAfterEndLocation);
	
	CGGradientRelease(gradient);
}

@end
