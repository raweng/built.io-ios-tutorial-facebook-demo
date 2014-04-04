//
//  AppDelegate.m
//  BuiltFacebookTutorial


#import "AppDelegate.h"
#import "LoginViewController.h"
#import "HomeViewController.h"
NSString * const kFBAPIKEY = @"305970426143095";
NSString * const kAppAPI_key = @"blt54bb6fddb6a8a4be";
NSString * const cAppUID = @"photofairapp";


@interface AppDelegate()
@property (nonatomic, strong) LoginViewController *loginViewController;
@property (nonatomic, strong) HomeViewController *homeViewController;
@end

// ****************************************************************************
// BuiltFacebookTutorial app gives Login with Built.io to facebook account
// ****************************************************************************

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    
    //Sets the api key and application uid of your application
    [Built initializeWithApiKey:kAppAPI_key andUid:cAppUID];
    
    // Initiate FBSession with API key with tokenCacheStrategy
    self.session = [[FBSession alloc]initWithAppID:kFBAPIKEY permissions:nil urlSchemeSuffix:nil tokenCacheStrategy:[[FBSessionTokenCachingStrategy alloc] initWithUserDefaultTokenInformationKeyName:@"FBAccessTokenInformationKey"]];
    
    // An application may get or set the current active session
    [FBSession setActiveSession:self.session];
    
    NSLog(@"[BuiltUser getSession]  %@",[BuiltUser getSession]);
    
    if ([BuiltUser getSession] == nil) {
        self.loginViewController = [[LoginViewController alloc]initWithNibName:nil bundle:nil];
        
        self.navigationController = [[UINavigationController alloc]initWithRootViewController:self.loginViewController];
    }else{
        self.homeViewController = [[HomeViewController alloc]initWithNibName:nil bundle:nil];
        
        self.navigationController = [[UINavigationController alloc]initWithRootViewController:self.homeViewController];
    }
    
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    self.window.rootViewController = self.navigationController;
    self.window.backgroundColor = [UIColor whiteColor];
    [self.window makeKeyAndVisible];
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application
{
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    [FBAppCall handleDidBecomeActiveWithSession:self.session];
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    [self.session close];
}

-(BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation{
    //For the proper processing of responses during interaction with the native Facebook app
    return [FBAppCall handleOpenURL:url sourceApplication:sourceApplication withSession:self.session];
}

+(AppDelegate *)sharedAppDelegate{
    return (AppDelegate*)[[UIApplication sharedApplication] delegate];
}

- (void)openSession:(void (^) (FBSession *session))successBlock onError:(void (^) (NSError *error))errorBlock{
    
    AppDelegate *appDelegate = [AppDelegate sharedAppDelegate];
    
    if (!appDelegate.session.isOpen) {
        appDelegate.session = [[FBSession alloc]initWithAppID:kFBAPIKEY permissions:[NSArray arrayWithObjects:@"status_update", @"publish_stream", nil] urlSchemeSuffix:nil tokenCacheStrategy:[[FBSessionTokenCachingStrategy alloc] initWithUserDefaultTokenInformationKeyName:@"FBAccessTokenInformationKey"]];
    }
    
    [appDelegate.session openWithCompletionHandler:^(FBSession *session, FBSessionState status, NSError *error) {
        if (!error && session && status != FBSessionStateClosedLoginFailed) {
            successBlock(session);
        }else{
            errorBlock(error);
        }
        [self sessionStateChanged:session state:status error:error];
    }];
}

-(void)sessionStateChanged:(FBSession *)session state:(FBSessionState)state error:(NSError *)error{
    switch (state) {
        case FBSessionStateOpen: {
            UIViewController *topViewController = [self.navigationController topViewController];
            if ([topViewController isKindOfClass:[LoginViewController class]]) {
                [topViewController dismissViewControllerAnimated:YES completion:nil];
            }
        }
            break;
        case FBSessionStateClosed:
        case FBSessionStateClosedLoginFailed:
            // Once the user has logged in, we want them to
            // be looking at the root view.
            [self.navigationController popToRootViewControllerAnimated:NO];
            
            [FBSession.activeSession closeAndClearTokenInformation];
            
            [self presentLoginController];
            break;
        default:
            break;
    }
    
}

-(void)presentLoginController{
    self.loginViewController = [[LoginViewController alloc]initWithNibName:nil bundle:nil];
    //    UINavigationController *loginNavigationController = [[UINavigationController alloc]initWithRootViewController:self.loginViewController];
    [self.navigationController pushViewController:self.loginViewController animated:YES];
}




+ (NSBundle *)frameworkBundle {
    
    static NSBundle* frameworkBundle = nil;
    
    static dispatch_once_t predicate;
    
    dispatch_once(&predicate, ^{
        
        NSString* mainBundlePath = [[NSBundle mainBundle] resourcePath];
        
        NSString* frameworkBundlePath = [mainBundlePath stringByAppendingPathComponent:@"BuiltIO.bundle"];
        
        frameworkBundle = [NSBundle bundleWithPath:frameworkBundlePath];
        
    });
    
    return frameworkBundle;
    
}

@end
