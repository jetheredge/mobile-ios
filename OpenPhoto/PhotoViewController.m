//
//  PhotoViewController.m
//  OpenPhoto
//
//  Created by Patrick Santana on 29/07/11.
//  Copyright 2011 OpenPhoto. All rights reserved.
//

#import "PhotoViewController.h"

@interface PhotoViewController()
-(void) doTheTransfer:(NSDictionary*) values;
@end



@implementation PhotoViewController
@synthesize detailsPictureTable;
@synthesize statusBar;
@synthesize imageToSend;


static NSString *cellIdentifierTitle = @"cellIdentifierTitle";
static NSString *cellIdentifierDescription = @"cellIdentifierDescription";
static NSString *cellIdentifierTags=@"cellIdentifierTags";
static NSString *cellIdentifierFilter=@"cellIdentifierFilter";
static NSString *cellIdentifierPrivate=@"cellIdentifierPrivate";


- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil photo:(UIImage *) imageFromPicker
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        imageToSend = imageFromPicker;
        // it will be necessary to send the 
       [imageToSend retain];
    }
    return self;
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}



#pragma mark - View lifecycle

- (void)viewDidLoad
{        statusBar.hidden = YES;  
    [[UIApplication sharedApplication] setStatusBarHidden:NO withAnimation:UIStatusBarAnimationFade];
    [self.navigationController setNavigationBarHidden:NO animated:YES];
    [super viewDidLoad];
}



- (void)viewDidUnload
{
    [imageTitle release];
    imageTitle = nil;
    [imageDescription release];
    imageDescription = nil;
    [statusBar release];
    statusBar = nil;
    
    [self setStatusBar:nil];
    [self setDetailsPictureTable:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (void)dealloc {
    [imageTitle release];
    [imageDescription release];
    [statusBar release];
    [imageToSend release];
    [statusBar release];
    [detailsPictureTable release];
    [super dealloc];
}

- (IBAction)upload:(id)sender {
    statusBar.hidden = NO;
    [statusBar startAnimating];
    
    
    NSArray *keys = [NSArray arrayWithObjects:@"image", @"title", @"description", nil];
    NSArray *objects = [NSArray arrayWithObjects:imageToSend, @"this is the tile", @"this is the description", nil];
    
    NSDictionary *values = [NSDictionary dictionaryWithObjects:objects forKeys:keys];
    
    // to send the request we add a thread.
    [NSThread detachNewThreadSelector:@selector(doTheTransfer:) 
                             toTarget:self 
                           withObject:values];    
}

-(void) doTheTransfer:(NSDictionary*) values
{
    NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
    
    
    for (id key in values) {
        NSLog(@"key: %@, value: %@", key, [values objectForKey:key]);
    }
    
    // send message to the site. it is pickedImage
    NSData *imageData = UIImageJPEGRepresentation([values objectForKey:@"image"] ,0.7);
    //Custom implementations, no built in base64 or HTTP escaping for iPhone
    NSString *imageB64   = [QSStrings encodeBase64WithData:imageData]; 
    NSString* imageEscaped = [OpenPhotoBase64Utilities pictureEscape:imageB64];
    
    
    // set all details to send
    NSString *uploadCall = [NSString stringWithFormat:@"photo=%@",imageEscaped];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:@"http://current.openphoto.me/photo/upload.json"]];
    [request setHTTPMethod:@"POST"];
    [request setValue:[NSString stringWithFormat:@"%d",[uploadCall length]] forHTTPHeaderField:@"Content-length"];
    [request setHTTPBody:[uploadCall dataUsingEncoding:NSUTF8StringEncoding allowLossyConversion:NO]];
    
    
    NSURLResponse *response;
    NSError *error = nil;
    
    NSData *XMLResponse= [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&error];
    
	NSString *jsonString = [[NSString alloc] initWithData:XMLResponse encoding:NSUTF8StringEncoding];
    NSLog(@"Result = %@",jsonString);   
    
    [statusBar stopAnimating];
    statusBar.hidden = YES;
    
    [self dismissModalViewControllerAnimated:YES];
    [pool release];
    
}


#pragma mark - Table
- (NSInteger)tableView:(UITableView *)tableView
 numberOfRowsInSection:(NSInteger)section{
    return kNumbersRow;
}

- (UITableViewCell *)tableView:(UITableView *)tableView
         cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell;
    
    
    NSUInteger row = [indexPath row];
    switch (row) {
        case 0:
            // title
            cell=[tableView dequeueReusableCellWithIdentifier:cellIdentifierTitle];
            if (cell == nil)
            {
                cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifierTitle] autorelease];
                // Do anything that should be the same on EACH cell here.  Fonts, colors, etc.
            }
            
            cell.textLabel.text=@"Title";
            break;
        case 1:
            // description
            cell=[tableView dequeueReusableCellWithIdentifier:cellIdentifierDescription];
            if (cell == nil)
            {
                cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifierDescription] autorelease];
                // Do anything that should be the same on EACH cell here.  Fonts, colors, etc.
            }
            
            cell.textLabel.text=@"Description";
            cell.textLabel.numberOfLines=3;
            break;
        case 2:
            // tags
            cell=[tableView dequeueReusableCellWithIdentifier:cellIdentifierTags];
            if (cell == nil)
            {
                cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifierTags] autorelease];
                // Do anything that should be the same on EACH cell here.  Fonts, colors, etc.
            }
            
            cell.textLabel.text=@"Tags";
            break;
        case 3:
            // filter: disclosure button
            cell=[tableView dequeueReusableCellWithIdentifier:cellIdentifierFilter];
            if (cell == nil)
            {
                cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifierFilter] autorelease];
                // Do anything that should be the same on EACH cell here.  Fonts, colors, etc.
            }
            
            cell.textLabel.text=@"Filter";
            break;
        case 4:
            // private flag
            cell=[tableView dequeueReusableCellWithIdentifier:cellIdentifierPrivate];
            if (cell == nil)
            {
                cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifierPrivate] autorelease];
                // Do anything that should be the same on EACH cell here.  Fonts, colors, etc.
            }
            
            cell.textLabel.text=@"Private";
            break;
            
        default:
            break;
    }
    /*
     
     
     [[cell textLabel] setText:@"Bla"];
     
     
     
     
     
     UITextField* title = [[[UITextField alloc] init] autorelease];
     title.placeholder = @"Tittle";
     title.font = TTSTYLEVAR(font);
     
     
     
     
     TTTextEditor* description = [[[TTTextEditor alloc] init] autorelease];
     description.font = TTSTYLEVAR(font);
     description.backgroundColor = TTSTYLEVAR(backgroundColor);
     description.autoresizesToText = NO;
     description.minNumberOfLines = 3;
     description.placeholder = @"Description";
     
     
     UISwitch* private = [[[UISwitch alloc] init] autorelease];
     TTTableControlItem* privateItem = [TTTableControlItem itemWithCaption:@"Private" control:private];
     
     
     */
    return cell;
}


@end
