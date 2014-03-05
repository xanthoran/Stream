//
//  NewRipple.m
//  StreamApps
//
//  Created by PETER LEACH on 1/20/14.
//  Copyright (c) 2014 PETER LEACH. All rights reserved.
//

#import "NewRipple.h"

@interface NewRipple ()
    @property (weak, nonatomic) IBOutlet UITextView *textViewContent;

    @property (nonatomic, strong) PFObject *anchorForRipple;

@end

@implementation NewRipple

- (BOOL)prefersStatusBarHidden {
    return YES;
}



- (IBAction)cancelButtonPressed:(id)sender {
    
    [self dismissViewControllerAnimated:YES completion:nil];
    
}


- (IBAction)createButtonPressed:(id)sender {
    //Create a new ripple object and create relationship with both PFuser and Anchor
    PFObject *newRipple = [PFObject objectWithClassName:@"Ripple"];
    [newRipple setObject:[_textViewContent text] forKey:@"textContent"];
    
    [newRipple setObject:[PFUser currentUser] forKey:@"author"];
    
    [newRipple setObject:_anchorForRipple forKey:@"anchor"];
    
    NSString* first_name = [PFUser currentUser] [@"fb_first_name"];
    [newRipple setObject:first_name forKey:@"author_first_name"];
    
    //Set ACL permissions for added security
    PFACL *rippleACL = [PFACL ACLWithUser:[PFUser currentUser]];
    [rippleACL setPublicReadAccess:YES];
    [newRipple setACL:rippleACL];
        
    // Save new Ripple object in Parse
    [newRipple saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        if (!error) {
            
            NSLog(@"ripple saved");

            [self dismissViewControllerAnimated:YES completion:nil]; // Dismiss the viewController upon success
            
        }
    }];

}




- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [_textViewContent becomeFirstResponder];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void) setAnchor:(PFObject *) anchor
{
    self.anchorForRipple = anchor;
}

@end
