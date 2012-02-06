//
//  TITokenFieldView.h
//  TITokenFieldView
//
//  Created by Tom Irving on 16/02/2010.
//  Copyright 2010 Tom Irving. All rights reserved.
//
//	Redistribution and use in source and binary forms, with or without modification,
//	are permitted provided that the following conditions are met:
//
//		1. Redistributions of source code must retain the above copyright notice, this list of
//		   conditions and the following disclaimer.
//
//		2. Redistributions in binary form must reproduce the above copyright notice, this list
//         of conditions and the following disclaimer in the documentation and/or other materials
//         provided with the distribution.
//
//	THIS SOFTWARE IS PROVIDED BY TOM IRVING "AS IS" AND ANY EXPRESS OR IMPLIED
//	WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND
//	FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL TOM IRVING OR
//	CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR
//	CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR
//	SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON
//	ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING
//	NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF
//	ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
//

#import <UIKit/UIKit.h>
#import "TITokenFieldShadow.h"
#import "TITokenField.h"
#import "TIToken.h"
#import "UIView+TITokenUIView.h"
#import "UIColor+TITokenUIColor.h"
#import "TITokenFieldSearchDelegate.h"

extern NSString * const kTextEmpty;
extern NSString * const kTextHidden;

extern CGFloat const kShadowHeight;
extern CGFloat const kTokenFieldHeight;
extern CGFloat const kSeparatorHeight;

#pragma mark - Delegate Methods

@class TITokenField, TIToken, TITokenFieldShadow;
@protocol TITokenFieldViewDelegate <UIScrollViewDelegate>
@required
// A token was added, tell the delegate
-(BOOL) tokenField:(TITokenField*)tokenField shouldAddToken:(NSString*)token;
-(void) tokenField:(TITokenField*)tokenField addedToken:(NSString*)token;
-(void) tokenField:(TITokenField*)tokenField removedToken:(NSString*)token;

//-(void) tokenField:(TITokenField*)tokenField removedToken:(NSString*)token representingObject:(id)object;
// A new token was created. Tell the delegate and expect an object that represents the object to be created
@optional

- (BOOL)tokenFieldShouldReturn:(TITokenField *)tokenField;
- (void)tokenField:(TITokenField *)tokenField didChangeToFrame:(CGRect)frame;
- (void)tokenFieldTextDidChange:(TITokenField *)tokenField;
- (void)tokenField:(TITokenField *)tokenField didFinishSearch:(NSArray *)matches;

//FIXME: No more results table
- (UITableViewCell *)tokenField:(TITokenField *)tokenField resultsTableView:(UITableView *)tableView cellForObject:(id)object;
- (CGFloat)tokenField:(TITokenField *)tokenField resultsTableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath;

@end

#pragma mark - TITokenFieldView

@class TITokenField;
@interface TITokenFieldView : UIScrollView <UITextFieldDelegate, TITokenDelegate> {
}

@property (nonatomic, assign) BOOL showAlreadyTokenized;
@property (nonatomic, unsafe_unretained) id <TITokenFieldViewDelegate> delegate;

// Need to get rid of this
@property (nonatomic, strong, readonly) TITokenField * tokenField;

@property (nonatomic, strong) UIPopoverController * popoverSelector;
@property (nonatomic, assign) BOOL summarise;
@property (nonatomic, strong) NSString * summaryText;

@property (nonatomic, strong) UIButton * addButton;

-(void) setPromptText:(NSString *)text;
-(void) renderString;
-(void) currentTokens:(NSSet*)tokens;
-(void) updateContentSize;
-(void) addToken:(NSString*)title;

#pragma mark - Formerly Private

-(void) processLeftoverText:(NSString *)text;
-(void) tokenFieldResized:(TITokenField *)aTokenField;

#pragma mark - Add Button
-(void) addButtonAction:(id)control;

-(void) deselectAll;

@end
