

#import "LogIn.h"
#import <QuartzCore/QuartzCore.h>

@interface LogIn ()
@property (nonatomic, strong) UIImageView *fieldsBackground;
@end

@implementation LogIn

@synthesize fieldsBackground;

- (BOOL)prefersStatusBarHidden {
    return YES;
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    
    UIImageView *bgImage = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"log-in-background.png"]];
    
    CGRect frame = bgImage.frame;
    frame.size.height = 568;
    frame.size.width = 320;
    bgImage.frame = frame;
 
    [self.logInView addSubview:bgImage];
    [self.logInView bringSubviewToFront:self.logInView.facebookButton];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    
    
    
    [self.logInView setBackgroundColor:[UIColor blackColor]];
    
    [self.logInView setLogo:[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"hyla_green_logo_png.png"]]];
    
    [self.logInView.facebookButton setImage:nil forState:UIControlStateNormal];
    [self.logInView.facebookButton setImage:nil forState:UIControlStateHighlighted];
    
    [self.logInView.facebookButton setBackgroundImage:[UIImage imageNamed:@"Connect with Facebook_down.png"] forState:UIControlStateHighlighted];
    [self.logInView.facebookButton setBackgroundImage:[UIImage imageNamed:@"Connect with Facebook.png"] forState:UIControlStateNormal];
    
    [self.logInView.facebookButton setTitle:@"" forState:UIControlStateNormal];
    [self.logInView.facebookButton setTitle:@"" forState:UIControlStateHighlighted];
    
    
    
    
   
    
    
    
}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    
    CGRect screenBound = [[UIScreen mainScreen] bounds];
    CGSize screenSize = screenBound.size;
    CGFloat screenWidth = screenSize.width;
    // CGFloat screenHeight = screenSize.height;
    
    int logoWidth = 123;
    int logoHeight = 83;
    
    int logoX = screenWidth/2 - logoWidth/2;
    
    int logoY = 125;
    
    [self.logInView.logo setFrame:CGRectMake( logoX , logoY, logoWidth, logoHeight)];
    
    self.logInView.logo.hidden = true;
    
    
    int fbWidth = 125;
    int fbHeight = 125;
    
    int fbX = screenWidth/2 - fbWidth/2;
    
    int fbY = 250;
    
    [self.logInView.facebookButton setFrame:CGRectMake( fbX , fbY, fbWidth, fbHeight)];
    
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

@end
