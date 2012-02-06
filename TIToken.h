//
//  TIToken.h
//  RecipeBook
//
//  Created by Marc Winoto on 29/01/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UIColor+TITokenUIColor.h"

#define kSmallTokenFont [UIFont fontWithName:@"Verdana" size:14.0]
#define kMediumTokenFont [UIFont fontWithName:@"Verdana" size:15.0]
#define kLargeTokenFont [UIFont fontWithName:@"Verdana" size:17.0]

// TODO: Will anything other than the TokenField ever implement this? 
@class TIToken;

@protocol TITokenDelegate <NSObject>
@optional
- (void)tokenGotFocus:(TIToken *)token;
- (void)tokenLostFocus:(TIToken *)token;

@end

@interface TIToken : UIView {
	
}

@property (nonatomic, unsafe_unretained) id <TITokenDelegate> delegate;
@property (nonatomic, getter=isHighlighted) BOOL highlighted;
@property (nonatomic, copy) NSString * title;
@property (nonatomic, copy) NSString * croppedTitle;
@property (nonatomic, strong) UIColor * tintColor;

- (id)initWithTitle:(NSString *)aTitle;

-(void) handleTap:(CGPoint) point;

@end
