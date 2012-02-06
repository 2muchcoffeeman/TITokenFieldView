//
//  TITokenField.h
//  RecipeBook
//
//  Created by Marc Winoto on 29/01/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TITokenFieldView.h"
#import "TIToken.h"
#import "TagTableViewController.h"

@interface TITokenField : UITextField {
}

@property (nonatomic, assign) int numberOfLines;
@property (nonatomic, assign) CGPoint cursorLocation;

-(void) handleTap:(CGPoint) point;

@end
