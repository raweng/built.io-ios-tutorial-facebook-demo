//
//  HomeViewController.m
//  BuiltFacebookTutorial
//

#import "HomeViewController.h"
#import "AppDelegate.h"
#import "LoginViewController.h"
#import "UIImageView+AFNetworking.h"

@interface HomeViewController ()
@property (nonatomic, strong) UILabel *label;
@property (nonatomic, strong) UILabel *loggedInLabel;
@property (nonatomic, strong) UILabel *emailLabel;
@property (nonatomic, strong) BuiltUser *user;
@property (nonatomic, strong) UIImageView *imageView;
@end

@implementation HomeViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    
    self.navigationController.navigationBarHidden = NO;
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc]initWithTitle:@"Logout" style:UIBarButtonItemStylePlain target:self action:@selector(logout:)];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self prepareViews];
	// Do any additional setup after loading the view.
}

- (void)prepareViews{
    
    self.imageView = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, 100, 100)];
    self.imageView.layer.cornerRadius = 5.0f;
    self.imageView.layer.masksToBounds = YES;
    
    
    
    self.label = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, 320, 20)];
    self.label.text = @"You are logged in as";
    self.label.textAlignment = NSTextAlignmentCenter;
    [self.label setCenter:CGPointMake(self.view.frame.size.width / 2, self.view.frame.size.height / 2 - 30)];
    
    [self.imageView setCenter:CGPointMake(self.view.frame.size.width / 2, CGRectGetMinY(self.label.frame) - 75)];
    
    
    self.loggedInLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, CGRectGetMaxY(self.label.frame) + 25, 320, 20)];
    self.loggedInLabel.textAlignment = NSTextAlignmentCenter;
    self.loggedInLabel.font = [UIFont boldSystemFontOfSize:20.0f];
    
    self.emailLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, CGRectGetMaxY(self.loggedInLabel.frame) + 5, 320, 20)];
    self.emailLabel.textColor = [UIColor grayColor];
    self.emailLabel.textAlignment = NSTextAlignmentCenter;
    
    
    [self.view addSubview:self.imageView];
    [self.view addSubview:self.label];
    [self.view addSubview:self.loggedInLabel];
    [self.view addSubview:self.emailLabel];
    
    self.user = [BuiltUser getSession];
    
    BOOL isDataNull = NO;
    NSDictionary *authDataDict = [self.user objectForKey:@"auth_data"];
    
    isDataNull = authDataDict == nil ? true : false;
    
    if (!isDataNull) {
        NSDictionary *facebookDict = [authDataDict objectForKey:@"facebook"];
        isDataNull = facebookDict == nil ? true : false;
    }
    
    if (!isDataNull) {
        NSDictionary *userProfile = [[authDataDict objectForKey:@"facebook"] objectForKey:@"user_profile"];
        self.loggedInLabel.text = [NSString stringWithFormat:@"%@ %@",[userProfile objectForKey:@"first_name"],[userProfile objectForKey:@"last_name"]];
        NSString *imageURL = [NSString stringWithFormat:@"https://graph.facebook.com/%@/picture?type=large",[userProfile objectForKey:@"id"]];
        
        [self.imageView setImageWithURL:[NSURL URLWithString:imageURL] placeholderImage:[UIImage imageNamed:@"missing_person.png"]];
        
        [self.emailLabel setText:[userProfile objectForKey:@"email"]];
    }
}

- (void)logout:(id)sender{
    AppDelegate *appDelegate = [AppDelegate sharedAppDelegate];
    
    appDelegate.session = [[FBSession alloc]init];
    [FBSession.activeSession closeAndClearTokenInformation];
    [[AppDelegate sharedAppDelegate].session close];
    [FBSession setActiveSession:Nil];
    
        BuiltUser *user = [BuiltUser currentUser];
        [user clearSession];

        NSMutableArray *vcs =  [NSMutableArray arrayWithArray:self.navigationController.viewControllers];
        LoginViewController* loginViewController = [[LoginViewController alloc]initWithNibName:nil bundle:nil];
        [vcs insertObject:loginViewController atIndex:0];
        [[AppDelegate sharedAppDelegate].navigationController setViewControllers:vcs animated:NO];
    
    UIViewController *viewController = [[AppDelegate sharedAppDelegate].navigationController.viewControllers objectAtIndex:0];
    [[AppDelegate sharedAppDelegate].navigationController popToViewController:viewController animated:YES];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
