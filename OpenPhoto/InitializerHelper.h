//
//  InitializerHelper.h
//  OpenPhoto
//
//  Created by Patrick Santana on 04/09/11.
//  Copyright (c) 2011 OpenPhoto. All rights reserved.
//

#import <UIKit/UIKit.h>

// this class helps with initializer routines
@interface InitializerHelper : NSObject

- (BOOL) isInitialized;
- (void) initialize;
- (void) resetInitialization;

@end
