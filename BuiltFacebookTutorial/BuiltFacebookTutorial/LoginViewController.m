//
//  LoginViewController.m
//  BuiltFacebookTutorial
//


#import "LoginViewController.h"
#import "AppDelegate.h"
#import "HomeViewController.h"

@interface LoginViewController ()
@property (nonatomic, strong) UIButton *facebookButton;
@property (nonatomic, assign) BOOL isFBLogged;
@end

@implementation LoginViewController

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
    
    self.navigationController.navigationBarHidden = YES;
    
    [self prepareViews];
	// Do any additional setup after loading the view.
}

- (void)prepareViews{
    self.facebookButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    
    [self.facebookButton setFrame:CGRectMake(0, 0, 170, 40)];
    [self.facebookButton setCenter:CGPointMake(self.view.frame.size.width / 2, self.view.frame.size.height / 2)];
    [self.facebookButton setBackgroundColor:[UIColor colorWithRed:66.0f/255.0f green:85.0f/255.0f blue:145.0f/255.0f alpha:1.0]];
    [self.facebookButton setTitle:@"Login with Facebook" forState:UIControlStateNormal];
    [self.facebookButton addTarget:self action:@selector(authenticateWithFacebook:) forControlEvents:UIControlEventTouchUpInside];
    [self.facebookButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [self.facebookButton setTitleColor:[UIColor whiteColor] forState:UIControlStateSelected];
    self.facebookButton.titleLabel.shadowColor = [UIColor whiteColor];
    
    [self.view addSubview:self.facebookButton];
}

#pragma mark
#pragma mark authenticate with facebook
-(void)authenticateWithFacebook:(id)sender{
    AppDelegate *delegate = [AppDelegate sharedAppDelegate];
    
    // Check if user has logged in with facebook
    //
    //   BuiltUser is a special class that allows adding the users functionality to our application. It features such as registration, logging in, logging out live here.
    
    //Gets user session stored on disk.
    BuiltUser *user = [[AppDelegate sharedAppDelegate].builtApplication currentUser];
    if (user != nil) {
        NSDictionary *facebookData = [[user objectForKey:@"auth_data"] objectForKey:@"facebook"];
        if (facebookData != nil) {
            self.isFBLogged = YES;
        }else{
            self.isFBLogged = NO;
        }
    }else{
        self.isFBLogged = NO;
    }
    // Check if user is logged in with facebook
    if (!self.isFBLogged) {
        [delegate openSession:^(FBSession *session) {
            if (session) {
                BuiltUser *builtUser = [[AppDelegate sharedAppDelegate].builtApplication currentUser];
                [builtUser loginInBackgroundWithFacebookAccessToken:[delegate.session accessTokenData].accessToken completion:^(ResponseType responseType, NSError *error) {
                    if (!error) {
                        [builtUser setAsCurrentUser];
                        [self callForDetailView];

                    }else {
                        UIAlertView *fbErrorAlert = [[UIAlertView alloc]initWithTitle:@"Facebook Login Error" message:@"Please try again in a short while..." delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil];
                        [fbErrorAlert show];

                    }

                }];
            }else{
                UIAlertView *fbErrorAlert = [[UIAlertView alloc]initWithTitle:@"Facebook Login Error" message:@"Please try again in a short while..." delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil];
                [fbErrorAlert show];
            }
            
        } onError:^(NSError *error) {
            UIAlertView *fbErrorAlert = [[UIAlertView alloc]initWithTitle:@"Login Error" message:@"Please try again in a bit." delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil];
            [fbErrorAlert show];
            
        }];
    }else{
        [self callForDetailView];
    }
}

-(void)callForDetailView{
    HomeViewController *homeViewcontroller = [[HomeViewController alloc]initWithNibName:nil bundle:nil];
    [self.navigationController pushViewController:homeViewcontroller animated:YES];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
