//
//  GalleryViewController.m
//  OpenPhoto
//
//  Created by Patrick Santana on 11/07/11.
//  Copyright 2011 OpenPhoto. All rights reserved.
//

#import "GalleryViewController.h"

@implementation GalleryViewController
@synthesize service, tagName;

- (id)init{
    self = [super init];
    if (self) {
        // Custom initialization
        self.view.backgroundColor = [UIColor blackColor];
        self.tabBarItem.image=[UIImage imageNamed:@"tab-gallery.png"];
        self.tabBarItem.title=@"Gallery";
        self.title=@"Gallery";
        self.hidesBottomBarWhenPushed = NO;
        self.wantsFullScreenLayout = YES;
        
        // create service and the delegate
        self.service = [[WebService alloc]init];
        [service setDelegate:self];
        
        self.photoSource = [[[PhotoSource alloc]
                             initWithTitle:@"Gallery"
                             photos:nil size:0 tag:nil] autorelease];
    }
    return self;
}

- (id) initWithTagName:(NSString*) tag{
    self = [self init];
    if (self) {
        self.tagName = tag;
    }
    return self;
}

-(void) viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
    
    if (self.tagName != nil){
        [service loadGallery:25 withTag:self.tagName onPage:1];
    }else{
        [service loadGallery:25 onPage:1];
    }
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // set the tile of the table
    self.title=@"Gallery";     
}

// delegate
-(void) receivedResponse:(NSDictionary *)response{
    // check if message is valid
    if (![WebService isMessageValid:response]){
        NSString* message = [WebService getResponseMessage:response];
        NSLog(@"Invalid response = %@",message);
        
        // show alert to user
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Response Error" message:message delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil];
        [alert show];
        [alert release];
        
        return;
    }
    
    NSArray *responsePhotos = [response objectForKey:@"result"] ;
    
    // result can be null
    if ([responsePhotos class] != [NSNull class]) {
        
        NSMutableArray *photos = [[NSMutableArray alloc] init];
        BOOL first=YES;
        int totalRows=0;
        
        // Loop through each entry in the dictionary and create an array of MockPhoto
        for (NSDictionary *photo in responsePhotos){
            
            // for the first, get how many pictures is in the server
            if (first == YES){
                totalRows = [[photo objectForKey:@"totalRows"] intValue];
                first = NO;
            }
            
            // Get title of the image
            NSString *title = [photo objectForKey:@"title"];
            if ([title class] == [NSNull class])
                title = @"";
            
#ifdef DEVELOPMENT_ENABLED      
            NSLog(@"Photo Thumb url [%@] with tile [%@]", [photo objectForKey:@"path200x200"], title);
#endif            
            
            float width = [[photo objectForKey:@"width"] floatValue];
            float height = [[photo objectForKey:@"height"] floatValue];
            
            // calculate the real size of the image. It will keep the aspect ratio.
            float realWidth = 0;
            float realHeight = 0;
            
            if(width/height >= 1) { 
                // portrait or square
                realWidth = 640;
                realHeight = height/width*640;
            } else { 
                // landscape
                realHeight = 960;
                realWidth = width/height*960;
            }
            
            [photos addObject: [[[Photo alloc]
                                 initWithURL:[NSString stringWithFormat:@"%@", [photo objectForKey:@"path640x960"]]
                                 smallURL:[NSString stringWithFormat:@"%@",[photo objectForKey:@"path200x200"]] 
                                 size:CGSizeMake(realWidth, realHeight) caption:title] autorelease]];
        } 
        
        
        self.photoSource = [[[PhotoSource alloc]
                             initWithTitle:@"Gallery"
                             photos:photos size:totalRows tag:self.tagName] autorelease];
        
        [photos release];
    }
    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
    
#ifdef TEST_FLIGHT_ENABLED
    [TestFlight passCheckpoint:@"Gallery Loaded"];
#endif
    
}

- (void) notifyUserNoInternet{
    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
    // problem with internet, show message to user
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Internet error" message:@"Couldn't reach the server. Please, check your internet connection" delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil];
    [alert show];
    [alert release];
}

- (void) dealloc {
    [service release];
    [tagName release];
    [super dealloc];
}

@end
