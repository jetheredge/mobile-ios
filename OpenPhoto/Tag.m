//
//  Tag.m
//  OpenPhoto
//
//  Created by Patrick Santana on 11/08/11.
//  Copyright 2011 OpenPhoto. All rights reserved.
//

#import "Tag.h"

@implementation Tag

@synthesize tagName,quantity,selected;

- (id)initWithTagName:(NSString*) name Quantity:(NSInteger) qtd{
    self = [super init];
    if (self) {
        // Initialization code here.
        self.tagName=name;
        self.quantity = qtd;
        // by default no tag is selected. This is used for READ ONLY proposal
        self.selected = NO;
    }
    
    return self;
}


///////////////// 
-(void) dealloc{
    [tagName release];
    [super dealloc];
}

@end
