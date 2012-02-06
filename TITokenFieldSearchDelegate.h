//
//  TITokenFieldSearchDelegate.h
//  RecipeBook
//
//  Created by Marc Winoto on 26/06/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol TITokenFieldSearchDelegate <NSObject>
-(void) modifyPredicate:(NSString*)searchString;
@end
