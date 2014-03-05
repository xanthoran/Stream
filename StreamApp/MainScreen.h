//
//  SubclassConfigViewController.h
//  LogInAndSignUpDemo
//
//  Created by Mattieu Gamache-Asselin on 6/15/12.
//  Copyright (c) 2013 Parse. All rights reserved.
//

@interface MainScreen : UIViewController <PFLogInViewControllerDelegate, PFSignUpViewControllerDelegate, UICollectionViewDataSource,UICollectionViewDelegateFlowLayout>

@property (weak, nonatomic) IBOutlet UITableView *anchorsTableView;

//@property (nonatomic, strong) IBOutlet UILabel *welcomeLabel;

@property (nonatomic, strong) NSArray *anchorArray;

- (IBAction)logOutButtonTapAction:(id)sender;

@end
