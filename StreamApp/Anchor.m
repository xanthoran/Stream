//
//  AnchorViewController.m
//  StreamApps
//
//  Created by PETER LEACH on 1/16/14.
//  Copyright (c) 2014 PETER LEACH. All rights reserved.
//

#import "Anchor.h"
#import "NewRipple.h"

@interface Anchor()
    @property (weak, nonatomic) IBOutlet UILabel *textViewTitle;
    @property (weak, nonatomic) IBOutlet UITextView *textViewContent;

    @property (nonatomic, strong) PFObject *anchorToDisplay;

    @property (weak, nonatomic) IBOutlet UITableView *tableViewRipples;

    @property (weak, nonatomic) IBOutlet UIView *createRippleView;

    @property (weak, nonatomic) IBOutlet UITextView *inputContent;



@end

@implementation Anchor

@synthesize rippleArray;

#pragma mark - UIViewController


- (void)refreshHandler {
    
    //Create query for all Ripple object by the current anchor
    PFQuery *rippleQuery = [PFQuery queryWithClassName:@"Ripple"];
     [rippleQuery whereKey:@"anchor" equalTo: _anchorToDisplay ];
    
    // Run the query
    [rippleQuery findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if (!error) {
            //Save results and update the table
            rippleArray = objects;
            [_tableViewRipples reloadData];
        }
    }];
}

#pragma mark - Table view data source
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return rippleArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    /*
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"MyIdentifier"];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"MyIdentifier"];
        
    }
    
    // Configure the cell with the textContent of the Anchor as the cell's text label
    PFObject *ripple = [rippleArray objectAtIndex:indexPath.row];
    
    NSString *rippleString = [NSString stringWithFormat:@"%@", [ripple objectForKey:@"author_first_name"]];
    
    [cell.textLabel setText: rippleString];
    [cell.detailTextLabel setText: [ripple objectForKey:@"textContent"]];
    
    return cell;
    */
    
    static NSString *CellIdentifier = @"RippleCell";
    
    // try to dequeue a cell from the tableview, for reuse:
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    // dequeue failed
    
    if (cell == nil) {
        // create new cell:
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
        
        //CONTENT
        UILabel *contentTextView = [[UILabel alloc]initWithFrame:CGRectMake(5, 5, [[UIScreen mainScreen] bounds].size.width - 10, 90)];
        contentTextView.tag = 43;
        contentTextView.textAlignment = NSTextAlignmentLeft;
        contentTextView.lineBreakMode = NSLineBreakByWordWrapping;
        contentTextView.numberOfLines = 0;
        contentTextView.textColor =  [UIColor blackColor];
        contentTextView.backgroundColor = [UIColor lightGrayColor];
        [contentTextView setFont:[UIFont systemFontOfSize:14]];
        [cell.contentView addSubview:contentTextView];
        
        //NAME
        UILabel *nameLabel = [[UILabel alloc]initWithFrame:CGRectMake(220, 70, 80, 20)];
        nameLabel.tag = 42;
        nameLabel.textAlignment = NSTextAlignmentLeft;
        nameLabel.textColor =  [UIColor blackColor];
        nameLabel.backgroundColor = [UIColor blueColor];
        [nameLabel setFont:[UIFont systemFontOfSize:10]];
        [cell.contentView addSubview:nameLabel];
    }
    else {
        // Nothing to do here. Because in either way we change the values of the cell later.
    }
    
    // Configure the cell with the textContent of the Anchor as the cell's text label
    PFObject *ripple = [rippleArray objectAtIndex:indexPath.row];
    
    UILabel *nameLabel = (UILabel *)[cell.contentView viewWithTag:42];
    nameLabel.text = [NSString stringWithFormat:@"by %@", [ripple objectForKey:@"author_first_name"]];
    
    UILabel *contentTextView = (UILabel *)[cell.contentView viewWithTag:43];
    contentTextView.text = [NSString stringWithFormat:@"%@", [ripple objectForKey:@"textContent"]];
    
    
    return cell;
}

- (IBAction)rippleButtonPressed:(id)sender {
    
    NSLog(@"ripple pressed");
    
    [self slideOutNewRipple];
    
}

- (IBAction)cancelRippleButtonPressed:(id)sender {
    NSLog(@"pressed cancel");
    [self slideBackNewRippple];
}

- (IBAction)createRippleButtonPressed:(id)sender {
    NSLog(@"pressed create");
    
    //Create a new ripple object and create relationship with both PFuser and Anchor
    PFObject *newRipple = [PFObject objectWithClassName:@"Ripple"];
    [newRipple setObject:[_inputContent text] forKey:@"textContent"];
    
    [newRipple setObject:[PFUser currentUser] forKey:@"author"];
    
    [newRipple setObject:_anchorToDisplay forKey:@"anchor"];
    
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
            [self slideBackNewRippple];
            
         //   [self dismissViewControllerAnimated:YES completion:nil]; // Dismiss the viewController upon success
            
            
            
        }
    }];
}

-(void)slideOutNewRipple{
    
    [_inputContent becomeFirstResponder];
    
    [UIView animateWithDuration:0.5f
                          delay:0.0f
                        options:UIViewAnimationOptionCurveEaseInOut
                     animations:^{
                         CGRect frame = _createRippleView.frame;
                         frame.origin.y = 200;
                         _createRippleView.frame =frame;
                     }
                     completion:^(BOOL finished){
                         //NSLog(@"completed");
                     }
     ];
}

-(void)slideBackNewRippple{
    
    // [_inputTitle resignFirstResponder];
    [_inputContent resignFirstResponder];
    
    [UIView animateWithDuration:0.5f
                          delay:0.0f
                        options:UIViewAnimationOptionCurveEaseInOut
                     animations:^{
                         CGRect frame = _createRippleView.frame;
                         frame.origin.y = 570;
                         _createRippleView.frame =frame;
                     }
                     completion:^(BOOL finished){
                         //NSLog(@"completed");
                         [self refreshHandler];
                     }
     ];
}

- (IBAction)backButtonPressed:(id)sender {
    
    NSLog(@"BACK ON ANCHOR");
    
    [_inputContent resignFirstResponder];
    
    if ([self.parentViewController respondsToSelector:@selector(slideBackAnchorView)])
        [self.parentViewController performSelector:@selector(slideBackAnchorView)];
    
}

- (BOOL)prefersStatusBarHidden {
    return YES;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}


- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    

    [self.textViewTitle setText:[_anchorToDisplay objectForKey:@"textTitle"]];
    [self.textViewContent setText:[_anchorToDisplay objectForKey:@"textContent"]];
    
     [self refreshHandler];
    
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void) setAnchor:(PFObject *) anchor
{
    self.anchorToDisplay = anchor;
}

@end
