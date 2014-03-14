

#import "MainScreen.h"
#import "LogIn.h"


#import "Anchor.h"


@interface MainScreen()

    @property (strong, nonatomic) IBOutlet UIView *rootView;
    @property (strong, nonatomic) Anchor *anchorView;

    @property (weak, nonatomic) IBOutlet UIImageView *createAnchorView;
    @property (weak, nonatomic) IBOutlet UITextView *inputTitle;
    @property (weak, nonatomic) IBOutlet UITextView *inputContent;
    @property (weak, nonatomic) IBOutlet UILabel *anchorTitlePrompt;
    @property (weak, nonatomic) IBOutlet UILabel *anchorContentPrompt;

    @property (weak, nonatomic) IBOutlet UIView *meMenuView;
    @property (weak, nonatomic) IBOutlet UIButton *userNameButton;
    @property (weak, nonatomic) IBOutlet UIImageView *userPhotoView;
    @property BOOL meMenuOut;

    @property BOOL homeIsDisplayed;

    @property (weak, nonatomic) IBOutlet UIButton *buttonFriends;
    @property (weak, nonatomic) IBOutlet UIView *friendsView;

    @property (weak, nonatomic) IBOutlet UIButton *sortAlertsButton;
    @property (weak, nonatomic) IBOutlet UIButton *sortHomeButton;


    @property (weak, nonatomic) IBOutlet UICollectionView *collectionView;
    @property (weak, nonatomic) IBOutlet UICollectionViewFlowLayout *layout;

    @property NSMutableArray * friendList;
    @property NSMutableArray * selectedFriends;

@property (weak, nonatomic) IBOutlet UITextView *textViewFriendsSelected;



@end

@implementation MainScreen

@synthesize anchorArray;


#pragma mark - UIViewController

- (BOOL)prefersStatusBarHidden {
    return YES;
}

- (void)viewWillAppear:(BOOL)animated {
    
    //HIDE STATUS BAR
    if ([self respondsToSelector:@selector(setNeedsStatusBarAppearanceUpdate)]) {
        // iOS 7
        [self performSelector:@selector(setNeedsStatusBarAppearanceUpdate)];
    } else {
        // iOS 6
        [[UIApplication sharedApplication] setStatusBarHidden:YES withAnimation:UIStatusBarAnimationSlide];
    }
    
    [self.navigationController setNavigationBarHidden:YES animated:animated];
    
    [super viewWillAppear:animated];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(titleTextViewDidChange:) name:UITextViewTextDidChangeNotification object:_inputTitle];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(contentTextViewDidStartEditing:) name:UITextViewTextDidBeginEditingNotification object:_inputContent];
    
    if ([PFUser currentUser]) {
        
        NSString* name = [PFUser currentUser] [@"fb_name"];
        [_userNameButton setTitle:name forState:UIControlStateNormal];
        [self refreshButtonHandler:nil];
        
        NSString* ImageURL = [PFUser currentUser] [@"fb_pic_url"];

        NSData *imageData = [NSData dataWithContentsOfURL:[NSURL URLWithString:ImageURL]];
        UIImage *image = [[UIImage alloc] initWithData:imageData];
        _userPhotoView.image = image;
        
        float widthMod = 50 / image.size.width;
        CGRect frame = _userPhotoView.frame;
        frame.size.width = image.size.width * widthMod;
        frame.size.height = image.size.height * widthMod;
        _userPhotoView.frame = frame;
        
        
        _homeIsDisplayed = YES;
        
        
    } else {
        [_userNameButton setTitle:@"Not Logged In" forState:UIControlStateNormal];
    }
}

- (void)viewDidLoad
{
    [_collectionView setDataSource:self];
    [_collectionView setDelegate:self];
    
    _collectionView.allowsMultipleSelection = YES;
    
    //myCollectionView.allowsMultipleSelection = YES;
    
    [_collectionView registerClass:[UICollectionViewCell class] forCellWithReuseIdentifier:@"FB_cell"];
    //[_collectionView setBackgroundColor:[UIColor redColor]];
    
    
    [super viewDidLoad];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    // Check if user is logged in
    if (![PFUser currentUser]) {
        [self showLoginView:false];
    }
    else {
        [self facebookInit];
    }
    
}



- (void)titleTextViewDidChange:(NSNotification *)notification {
    [_anchorTitlePrompt setHidden:YES];
}

- (void)contentTextViewDidStartEditing:(NSNotification *)notification {
    [_anchorContentPrompt setHidden:YES];
}

- (void) saveUserData:(NSDictionary *) userData {
    NSString *facebookID = userData[@"id"];
    NSString *name = userData[@"name"];
    NSString *location = userData[@"location"][@"name"];
    NSString *first_name = userData[@"first_name"];
    NSURL *pictureURL = [NSURL URLWithString:[NSString stringWithFormat:@"https://graph.facebook.com/%@/picture?type=small&return_ssl_resources=1", facebookID]];
    NSString *pictureURLstring = [pictureURL absoluteString];
    
    [PFUser currentUser][@"fb_name"] = name;
    [PFUser currentUser][@"fb_id"] = facebookID;
    [PFUser currentUser][@"fb_location"] = location;
    [PFUser currentUser][@"fb_pic_url"] = pictureURLstring;
    [PFUser currentUser][@"fb_first_name"] = first_name;
    
    [[PFUser currentUser] saveInBackground];
}

-(void) saveUserFriendData:(NSMutableArray *) friends{
    NSLog(@"saving user friend data...");
    
    _friendList = [[NSMutableArray alloc] init];
    
    for (NSMutableDictionary *friend in friends) {
        NSNumber * friendFB_UID = friend[@"uid"];
        NSString* friendPictureUrlString = [NSString stringWithFormat:@"https://graph.facebook.com/%@/picture?type=small&return_ssl_resources=1", [friendFB_UID stringValue]];
        
        [friend setObject:friendPictureUrlString forKey:@"friendFBPictureUrl"];
        
       // [friend setObject:@NO forKey:@"isSelected"];
        
        [_friendList addObject:friend];
    }
    
    [PFUser currentUser][@"fb_friends_with_app"] = _friendList;
    [[PFUser currentUser] saveInBackground];
    
    [self.collectionView reloadData];
}


- (IBAction)refreshButtonHandler:(id)sender {
    NSLog(@"Refreshing main table...");
    
    //Create query for all Anchor object by the current user
    PFQuery *anchorQuery = [PFQuery queryWithClassName:@"Anchor"];
   // [anchorQuery whereKey:@"author" equalTo:[PFUser currentUser]];
    
    // Run the query
    [anchorQuery findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if (!error) {
            //Save results and update the table
            anchorArray = objects;
            [_anchorsTableView reloadData];
        }
    }];
}

-(void)slideBackAnchorView{
    
    NSLog(@"slide back anchor view");
    
    float width = self.view.frame.size.width;
    float height = self.view.frame.size.height;
    
    [UIView animateWithDuration:0.33f
                          delay:0.0f
                        options:UIViewAnimationOptionCurveEaseInOut | UIViewAnimationOptionAllowUserInteraction
                     animations:^{
                         [self.anchorView.view setFrame:CGRectMake(width, 0.0, width, height)];
                         //[_rootView setFrame:CGRectMake(-width, 0.0, width, height)];
                     }
                     completion:^(BOOL finished){
                        // do whatever post processing you want (such as resetting what is "current" and what is "next")
                        //  [self presentViewController:anchorView animated:NO completion:NULL];
                         
                         NSLog(@"finished.. here..");
                         
                     }];
}

- (IBAction)addButtonHandler:(id)sender {
    
    NSLog(@"pressed add new anchor");
    
    [self slideOutNewAnchor];
}



-(void)showLoginView:(BOOL)animated{
    // Customize the Log In View Controller
    LogIn *logInViewController = [[LogIn alloc] init];
    logInViewController.delegate = self;
    logInViewController.facebookPermissions = @[@"user_about_me", @"user_relationships", @"user_location"];
    logInViewController.fields =  PFLogInFieldsFacebook;
        
    // Present Log In View Controller
    [self presentViewController:logInViewController animated:animated completion:NULL];
}

-(void) facebookInit{
    
    
    //PERSONAL DATA
    FBRequest *request = [FBRequest requestForMe];
    // Send request to Facebook
    [request startWithCompletionHandler:^(FBRequestConnection *connection, id result, NSError *error) {
        // handle response
        NSDictionary *userData = (NSDictionary *)result;
        [self saveUserData:userData];
    }];
    
    
    //FRIENDS WITH THE APP
    NSString *query = @"select uid, name, is_app_user "
    @"from user "
    @"where is_app_user AND uid in (select uid2 from friend where uid1=me() )";
    NSDictionary *queryParam =
    [NSDictionary dictionaryWithObjectsAndKeys:query, @"q", nil];
    // Make the API request that uses FQL
    [FBRequestConnection startWithGraphPath:@"/fql"
                                 parameters:queryParam
                                 HTTPMethod:@"GET"
                          completionHandler:^(FBRequestConnection *connection,
                                              id result,
                                              NSError *error) {
                              
                              if (error) {
                                  
                                  NSLog(@"Error: %@", [error localizedDescription]);
                                  
                                  //DLog(@"Error: %@", [error localizedDescription]);
                                  //[self.delegate FBDidFailedLoadFriends:error];
                                  
                                  
                              } else {
                                 // NSLog(@"Result: %@", result);
                                 //NSDictionary *friendData = (NSDictionary *)result;
                                 //[self saveUserFriendData:(FBGraphObject*)result];
                                  
                                  NSMutableArray *friends = ((FBGraphObject*)result)[@"data"];
                                  [self saveUserFriendData:friends];
                              }
                          }];
}


#pragma mark - PFLogInViewControllerDelegate

// Sent to the delegate to determine whether the log in request should be submitted to the server.
- (BOOL)logInViewController:(PFLogInViewController *)logInController shouldBeginLogInWithUsername:(NSString *)username password:(NSString *)password {
    if (username && password && username.length && password.length) {
        return YES;
    }
    
    [[[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Missing Information", nil) message:NSLocalizedString(@"Make sure you fill out all of the information!", nil) delegate:nil cancelButtonTitle:NSLocalizedString(@"OK", nil) otherButtonTitles:nil] show];
    return NO;
}

// Sent to the delegate when a PFUser is logged in.
- (void)logInViewController:(PFLogInViewController *)logInController didLogInUser:(PFUser *)user {
    [self dismissViewControllerAnimated:YES completion:NULL];
}

// Sent to the delegate when the log in attempt fails.
- (void)logInViewController:(PFLogInViewController *)logInController didFailToLogInWithError:(NSError *)error {
    NSLog(@"Failed to log in...");
}

// Sent to the delegate when the log in screen is dismissed.
- (void)logInViewControllerDidCancelLogIn:(PFLogInViewController *)logInController {
    NSLog(@"User dismissed the logInViewController");
}


#pragma mark - PFSignUpViewControllerDelegate

// Sent to the delegate to determine whether the sign up request should be submitted to the server.
- (BOOL)signUpViewController:(PFSignUpViewController *)signUpController shouldBeginSignUp:(NSDictionary *)info {
    BOOL informationComplete = YES;
    for (id key in info) {
        NSString *field = [info objectForKey:key];
        if (!field || field.length == 0) {
            informationComplete = NO;
            break;
        }
    }
    
    if (!informationComplete) {
        [[[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Missing Information", nil) message:NSLocalizedString(@"Make sure you fill out all of the information!", nil) delegate:nil cancelButtonTitle:NSLocalizedString(@"OK", nil) otherButtonTitles:nil] show];
    }
    
    return informationComplete;
}

// Sent to the delegate when a PFUser is signed up.
- (void)signUpViewController:(PFSignUpViewController *)signUpController didSignUpUser:(PFUser *)user {
    [self dismissViewControllerAnimated:YES completion:NULL];
}

// Sent to the delegate when the sign up attempt fails.
- (void)signUpViewController:(PFSignUpViewController *)signUpController didFailToSignUpWithError:(NSError *)error {
    NSLog(@"Failed to sign up...");
}

// Sent to the delegate when the sign up screen is dismissed.
- (void)signUpViewControllerDidCancelSignUp:(PFSignUpViewController *)signUpController {
    NSLog(@"User dismissed the signUpViewController");
}




#pragma mark - ()



- (IBAction)meButtonTapAction:(id)sender {
    NSLog(@"pressed the ME buttnon");
    
    if (_meMenuOut) {
        [self slideBackInMeMenu];
    } else {
        [self slideOutMeMenu];
    }
    
    
    
    
}


-(void)slideOutMeMenu{
    
    _meMenuOut = YES;
    
    [UIView animateWithDuration:0.5f
                          delay:0.0f
                        options:UIViewAnimationOptionCurveEaseInOut
                     animations:^{
                         CGRect frame = _meMenuView.frame;
                         
                         frame.origin.y = -460;
                         _meMenuView.frame =frame;
                     }
                     completion:^(BOOL finished){
                         //NSLog(@"completed");
                         
                         
                         
                     }
     ];
}

-(void)slideBackInMeMenu{
    
    _meMenuOut = NO;
    
    [UIView animateWithDuration:0.5f
                          delay:0.0f
                        options:UIViewAnimationOptionCurveEaseInOut
                     animations:^{
                         CGRect frame = _meMenuView.frame;
                         
                         frame.origin.y = -548;
                         _meMenuView.frame =frame;
                     }
                     completion:^(BOOL finished){
                         //NSLog(@"completed");
                         
                         
                         
                     }
     ];
}

-(void)slideOutNewAnchor{
    
    [_inputTitle setText:@""];
    [_inputContent setText:@""];
    
    [_anchorTitlePrompt setHidden:NO];
    [_anchorContentPrompt setHidden:NO];
    
    
    [_inputTitle becomeFirstResponder];
    
    
    [UIView animateWithDuration:0.5f
                          delay:0.0f
                        options:UIViewAnimationOptionCurveEaseInOut
                     animations:^{
                         CGRect frame = _createAnchorView.frame;
                         frame.origin.y = 0;
                         _createAnchorView.frame =frame;
                     }
                     completion:^(BOOL finished){
                         //NSLog(@"completed");
                     }
     ];
}

-(void)slideBackNewAnchor{
    
    [_inputTitle resignFirstResponder];
    [_inputContent resignFirstResponder];

    [UIView animateWithDuration:0.5f
                          delay:0.0f
                        options:UIViewAnimationOptionCurveEaseInOut
                     animations:^{
                         CGRect frame = _createAnchorView.frame;
                         frame.origin.y = 570;
                         _createAnchorView.frame =frame;
                     }
                     completion:^(BOOL finished){
                         //NSLog(@"completed");
                         
                         [_inputTitle setText:@""];
                         [_inputContent setText:@""];
                         
                         
                         [self refreshButtonHandler:nil];
                     }
     ];
}




- (IBAction)logOutButtonTapAction:(id)sender {
    [self slideBackInMeMenu];
    
    [PFUser logOut];
    //[self.navigationController popViewControllerAnimated:YES];
    
    [self showLoginView:TRUE];
    
    
}

- (IBAction)createAnchorButtonTapAction:(id)sender {
    
    NSLog(@"pressed create anchor");
 
    // Create a new Anchor object and create relationship with PFUser
    PFObject *newAnchor = [PFObject objectWithClassName:@"Anchor"];
    [newAnchor setObject:[_inputTitle text] forKey:@"textTitle"];
    [newAnchor setObject:[_inputContent text] forKey:@"textContent"];
    [newAnchor setObject:[PFUser currentUser] forKey:@"author"]; // One-to-Many relationship created here!
    
    NSString* first_name = [PFUser currentUser] [@"fb_first_name"];
    [newAnchor setObject:first_name forKey:@"author_first_name"];
    
    //Set ACL permissions for added security
    PFACL *anchorACL = [PFACL ACLWithUser:[PFUser currentUser]];
    [anchorACL setPublicReadAccess:YES];
    [newAnchor setACL:anchorACL];
    
    // Save new Anchor object in Parse
    [newAnchor saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        if (!error) {
            [self slideBackNewAnchor];
        }
    }];

}


- (IBAction)cancelAnchorButtonTapAction:(id)sender {
    
    NSLog(@"pressed CANCEL anchor");
    [self slideBackNewAnchor];
    
}

- (IBAction)pageMarkerButtonTapAction:(id)sender {
    
    NSLog(@"pressed PAGE MARKER");
    
}

- (IBAction)friendsSelectionTapAction:(id)sender {
    
    NSLog(@"pressed FRIENDS SELECTION");
   
    [_buttonFriends setUserInteractionEnabled:NO];
    
    
    //slide down friends
    [self slideOutFriends];

    
}

-(void)slideOutFriends{
    
    [_inputTitle resignFirstResponder];
    [_inputContent resignFirstResponder];
    
    _selectedFriends = [[NSMutableArray alloc]init];
    
    //ANIMATE VIEW FROM TOP
    [UIView animateWithDuration:0.5f
                          delay:0.0f
                        options:UIViewAnimationOptionCurveEaseInOut
                     animations:^{
                         CGRect frame = _friendsView.frame;
                         frame.origin.y = 0;
                         _friendsView.frame =frame;
                     }
                     completion:^(BOOL finished){
                         //NSLog(@"completed");
                     }
     ];
}

-(void)slideBackInFriends{
    
    [UIView animateWithDuration:0.5f
                          delay:0.0f
                        options:UIViewAnimationOptionCurveEaseInOut
                     animations:^{
                         CGRect frame = _friendsView.frame;
                         frame.origin.y = -570;
                         _friendsView.frame =frame;
                     }
                     completion:^(BOOL finished){
                         [_buttonFriends setUserInteractionEnabled:YES];
                         
                     }
     ];
}

- (IBAction)friendsSubmitButtonTapAction:(id)sender {
    [self slideBackInFriends];
    [_inputTitle becomeFirstResponder];
    
    NSString * friendsString = @"";
    
    for (NSMutableDictionary *friend in _selectedFriends) {
        
        friendsString = [friendsString stringByAppendingString:friend[@"name"]];
        
        friendsString = [friendsString stringByAppendingString:@", "];
        
    }
    
    _textViewFriendsSelected.text = friendsString;
}


- (IBAction)sortAlertsTapAction:(id)sender {
    _sortHomeButton.hidden = NO;
}

- (IBAction)sortHomeTapAction:(id)sender {
    _sortHomeButton.hidden = YES;
}





//COLLECTION VIEW METHODS
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
   // NSMutableArray *friends = [PFUser currentUser][@"fb_friends_with_app"];
    return [self.friendList count];
}

// The cell that is returned must be retrieved from a call to -dequeueReusableCellWithReuseIdentifier:forIndexPath:
- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    UICollectionViewCell *cell=[collectionView dequeueReusableCellWithReuseIdentifier:@"FB_cell" forIndexPath:indexPath];
    
    cell.backgroundColor=[UIColor whiteColor];
    
    if (cell.selected) {
        cell.backgroundColor = [UIColor blueColor]; // highlight selection
    }
    
    //NAME
    UILabel *nameLabel = [[UILabel alloc]initWithFrame:CGRectMake(80, 2, 50, 50)];
    nameLabel.tag = 42;
    nameLabel.textAlignment = NSTextAlignmentLeft;
    nameLabel.textColor =  [UIColor blackColor];
    nameLabel.backgroundColor = [UIColor clearColor];
    nameLabel.numberOfLines = 0;
    [nameLabel setFont:[UIFont systemFontOfSize:14]];
    nameLabel.text = _friendList[indexPath.item][@"name"];
    [cell.contentView addSubview:nameLabel];

    //FACEBOOK IMAGE
    NSString *friendPicUrl = _friendList[indexPath.item][@"friendFBPictureUrl"];
    NSData *imageData = [NSData dataWithContentsOfURL:[NSURL URLWithString:friendPicUrl]];
    UIImage *image = [[UIImage alloc] initWithData:imageData];
    UIImageView *imageView = [[UIImageView alloc] initWithImage:image];
    
    float heightMod = 50 / image.size.height;
    CGRect frame = imageView.frame;
    frame.size.width = image.size.width * heightMod;
    frame.size.height = image.size.height * heightMod;
    imageView.frame = frame;
   
    [cell.contentView addSubview:imageView];
    
    return cell;
}

//SELECTED FACEBOOK FRIEND
-(void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath  {
    NSLog(@"selected");
    UICollectionViewCell *datasetCell =[collectionView cellForItemAtIndexPath:indexPath];
    datasetCell.selected = YES;
    datasetCell.backgroundColor = [UIColor blueColor]; // highlight selection
    
    //add the friend selected to the array of friends...
    
    NSMutableDictionary *friendSelected = _friendList[indexPath.item];
    
    [_selectedFriends addObject:friendSelected];
    
}

-(void)collectionView:(UICollectionView *)collectionView didDeselectItemAtIndexPath:(NSIndexPath *)indexPath {
    NSLog(@"DE selected");
    UICollectionViewCell *datasetCell =[collectionView cellForItemAtIndexPath:indexPath];
    datasetCell.selected = NO;
    datasetCell.backgroundColor = [UIColor whiteColor]; // Default color
    
    NSMutableDictionary *friendSelected = _friendList[indexPath.item];
    
    [_selectedFriends removeObject:friendSelected];
    
}










//TABLE VIEW METHODS
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

#pragma mark - Table view data source
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return anchorArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *CellIdentifier = @"AnchorCell";
    
    // try to dequeue a cell from the tableview, for reuse:
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    // dequeue failed
    
    if (cell == nil) {
        // create new cell:
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
        
        // you add your subviews here.
        
        //CELL BACKGROUND
        UIView *cellBackground = [[UIView alloc]initWithFrame:CGRectMake(5, 5, [[UIScreen mainScreen] bounds].size.width - 10, 90)];
        cellBackground.tag = 40;
        // r /g /b 225 / 232 / 241
        cellBackground.backgroundColor = [UIColor colorWithRed:225.0/255.0 green:232.0/255.0 blue:241.0/255.0 alpha:1];
        [cell.contentView addSubview:cellBackground];
        
        //TITLE
        UILabel *titleLabel = [[UILabel alloc]initWithFrame:CGRectMake(2, 0, 200, 20)];
        titleLabel.tag = 41;
        titleLabel.textAlignment = NSTextAlignmentLeft;
        titleLabel.textColor =  [UIColor blackColor];
        titleLabel.backgroundColor = [UIColor clearColor];
        [titleLabel setFont:[UIFont systemFontOfSize:16]];
        [cellBackground addSubview:titleLabel];
        //[cell.contentView addSubview:titleLabel];
        
        //NAME
        UILabel *nameLabel = [[UILabel alloc]initWithFrame:CGRectMake(2, 15, 80, 20)];
        nameLabel.tag = 42;
        nameLabel.textAlignment = NSTextAlignmentLeft;
        nameLabel.textColor =  [UIColor blackColor];
        nameLabel.backgroundColor = [UIColor clearColor];
        [nameLabel setFont:[UIFont systemFontOfSize:10]];
        [cellBackground addSubview:nameLabel];
        // [cell.contentView addSubview:nameLabel];
        
        //CONTENT
        UILabel *contentTextView = [[UILabel alloc]initWithFrame:CGRectMake(5, 40, [[UIScreen mainScreen] bounds].size.width - 10, 50)];
        
        contentTextView.tag = 43;
        contentTextView.textAlignment = NSTextAlignmentLeft;
        contentTextView.lineBreakMode = NSLineBreakByWordWrapping;
        contentTextView.numberOfLines = 0;
        contentTextView.textColor =  [UIColor blackColor];
        contentTextView.backgroundColor = [UIColor clearColor];
        [contentTextView setFont:[UIFont systemFontOfSize:14]];
        [cellBackground addSubview:contentTextView];
        // [cell.contentView addSubview:contentTextView];
        
        
    }
    else {
        // Nothing to do here. Because in either way we change the values of the cell later.
    }
    
    // Configure the cell with the textContent of the Anchor as the cell's text label
    PFObject *anchor = [anchorArray objectAtIndex:indexPath.row];
    
    UILabel *titleLabel = (UILabel *)[[cell.contentView viewWithTag:40] viewWithTag:41];
    titleLabel.text = [anchor objectForKey:@"textTitle"];
    
    UILabel *nameLabel = (UILabel *)[[cell.contentView viewWithTag:40] viewWithTag:42];
    nameLabel.text = [NSString stringWithFormat:@"by %@", [anchor objectForKey:@"author_first_name"]];
    
    UILabel *contentTextView = (UILabel *)[[cell.contentView viewWithTag:40] viewWithTag:43];
    contentTextView.text = [NSString stringWithFormat:@"%@", [anchor objectForKey:@"textContent"]];
    
    
    return cell;
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    
    [self slideBackNewAnchor];
    [self slideBackInMeMenu];
    
    float width = self.view.frame.size.width;
    float height = self.view.frame.size.height;
    
    self.anchorView = [[Anchor alloc] init];
    
    PFObject *anchorToSee = [anchorArray objectAtIndex:indexPath.row];
    
    [self.anchorView setAnchor:anchorToSee];
    
    [self.anchorView.view setFrame:CGRectMake(width, 0.0, width, height)];
    
    [self addChildViewController:self.anchorView];
    [self.view addSubview:self.anchorView.view];
    
    [UIView animateWithDuration:0.33f
                          delay:0.0f
                        options:UIViewAnimationOptionCurveEaseInOut | UIViewAnimationOptionAllowUserInteraction
                     animations:^{
                         [self.anchorView.view setFrame:_rootView.frame];
                         //[_rootView setFrame:CGRectMake(-width, 0.0, width, height)];
                     }
                     completion:^(BOOL finished){
                         // do whatever post processing you want (such as resetting what is "current" and what is "next")
                         
                         
                         //  [self presentViewController:anchorView animated:NO completion:NULL];
                         
                         
                     }];
}











@end
