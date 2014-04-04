//
//  AppDelegate.h
//  BuiltFacebookTutorial


#import <UIKit/UIKit.h>

@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;
@property (strong, nonatomic) FBSession *session;
@property (nonatomic, strong) UINavigationController *navigationController;


+ (AppDelegate *)sharedAppDelegate;

- (void)openSession:(void (^) (FBSession *session))successBlock onError:(void (^) (NSError *error))errorBlock;
- (void)sessionStateChanged:(FBSession *)session state:(FBSessionState) state error:(NSError *)error;
- (void)showLoginView;
+ (NSBundle *)frameworkBundle;

@end
