//
//  com_tenkoro614AppDelegate.m
//  mytestapp
//
//  Created by HirokiNakamura on 2014/02/27.
//  Copyright (c) 2014年 HirokiNakamura. All rights reserved.
//

#import "AppDelegate.h"
#import <GoogleMaps/GoogleMaps.h>

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    // Override point for customization after application launch.
    
    [GMSServices provideAPIKey:@"AIzaSyAieNRnrUiKC9IrsNASAWAo8fcdnplSAP8"];
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSString *devid = [defaults stringForKey:@"devid"];
    if(devid == nil || [devid isEqualToString:@""]) {
        devid = [[[UIDevice currentDevice] identifierForVendor] UUIDString];
//        devid = [devid stringByReplacingOccurrencesOfString:@"-" withString:@""];
        [defaults setObject:devid forKey:@"devid"];
    }
    
    // バッジ、サウンド、アラートをリモート通知対象として登録する
    // (画面にはプッシュ通知許可して良いかの確認画面が出る)
    [application unregisterForRemoteNotifications];
    [application registerForRemoteNotificationTypes: (UIRemoteNotificationTypeBadge|
                                                      UIRemoteNotificationTypeSound|
                                                      UIRemoteNotificationTypeAlert)];
//    [application setMinimumBackgroundFetchInterval:UIApplicationBackgroundFetchIntervalMinimum];
    
    return YES;
}
							
- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    
    NSLog(@"applicationDidEnterBackground");
    [self.myViewController stopTask];
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    NSLog(@"applicationDidBecomeActive");
    [self.myViewController startTask];
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSString *deviceTokenString = [defaults stringForKey:@"deviceToken"];
    if(deviceTokenString == nil || [deviceTokenString isEqualToString:@""]) {
        NSString *deviceTokenString = [deviceToken description];
        //        devid = [devid stringByReplacingOccurrencesOfString:@"-" withString:@""];
        [defaults setObject:deviceTokenString forKey:@"deviceToken"];
    }
    
//    // デバイストークンの両端の「<>」を取り除く
//    NSString *deviceTokenString = [[deviceToken description] stringByTrimmingCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@"<>"]];
//    
//    // デバイストークン中の半角スペースを除去する
//    deviceTokenString = [deviceTokenString stringByReplacingOccurrencesOfString:@" " withString:@""];
    
    NSLog(@"%@",deviceTokenString);
}

- (void)application:(UIApplication *)application didFailToRegisterForRemoteNotificationsWithError:(NSError *)error
{
    NSLog(@"Error: %@", error);
}

- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo {
    
}

- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo fetchCompletionHandler:(void (^)(UIBackgroundFetchResult))completionHandler{
    NSLog(@"サーバーから届いている中身一覧: %@",[userInfo description]);
    if(application.applicationState == UIApplicationStateInactive){
        //バックグラウンドにいる状態
        NSLog(@"remote push recieved (inactive)");
    }
    else if(application.applicationState == UIApplicationStateActive){
        //ばりばり動いている時
        NSLog(@"remote push recieved (active)");
    }
    
    /*
    // セッションの種類を決めます
    NSURLSessionConfiguration *defaultConfigObject = [NSURLSessionConfiguration defaultSessionConfiguration];
    // セッションを作ります
    NSURLSession *urlSession = [NSURLSession sessionWithConfiguration: defaultConfigObject delegate: nil delegateQueue: [NSOperationQueue mainQueue]];
    // データタスクを作成して実行します
//    [[urlSession dataTaskWithURL: [NSURL URLWithString: @"http://localhost/api/v1/hello?aaa"]
    [[urlSession dataTaskWithURL: [NSURL URLWithString: @"http://testapp614.herokuapp.com/api/v1/hello?aaa"]
                completionHandler:^(NSData *data, NSURLResponse *response,NSError *error) {
                    NSLog(@"Got response %@ with error %@.\n", response, error);
                    NSLog(@"DATA:\n%@\nEND DATA\n",[[NSString alloc] initWithData: data encoding: NSUTF8StringEncoding]);
                }] resume];
     */
    
    if([self.myViewController isConfig] && ![self.myViewController isStartTask]) {
        [self.myViewController startTask];
    
        // タイマーを生成しスタート
        [NSTimer
              scheduledTimerWithTimeInterval:30.f
              target:self
              selector:@selector(stopTask:)
              userInfo:nil
              repeats:NO];
    }
}

// タイマーが動作した時の処理
- (void)stopTask:(NSTimer *)timer {
    [self.myViewController stopTask];
}

@end
