//
//  com_tenkoro614ViewController.h
//  mytestapp
//
//  Created by HirokiNakamura on 2014/02/27.
//  Copyright (c) 2014年 HirokiNakamura. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <GoogleMaps/GoogleMaps.h>

@interface MainViewController : UIViewController <CLLocationManagerDelegate, UITextFieldDelegate>
@property (weak, nonatomic) IBOutlet UIView *gMapView;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *indicator;

- (void) startTask;
- (void) stopTask;
- (BOOL) isStartTask;
- (BOOL) isConfig;
- (IBAction)refresh:(id)sender;

@end
