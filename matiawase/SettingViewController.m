//
//  settingViewController.m
//  mytestapp
//
//  Created by HirokiNakamura on 2014/03/03.
//  Copyright (c) 2014年 HirokiNakamura. All rights reserved.
//

#import "SettingViewController.h"

@interface SettingViewController ()

@end

@implementation SettingViewController

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
	// Do any additional setup after loading the view.
}

- (void)viewWillAppear:(BOOL)animated
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    self.groupname.text = [defaults stringForKey:@"groupname"];
    self.username.text = [defaults stringForKey:@"username"];
    self.isUpdate.on = [defaults boolForKey:@"isUpdate"];
    self.iconSelect.selectedSegmentIndex = [defaults integerForKey:@"iconSelect"];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)backButtonAction:(id)sender {
    NSString *groupname = self.groupname.text;
    NSString *username = self.username.text;
    BOOL isUpdate = self.isUpdate.on;
    int iconSelect = (int)self.iconSelect.selectedSegmentIndex;
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject:groupname forKey:@"groupname"];
    [defaults setObject:username forKey:@"username"];
    [defaults setBool:isUpdate forKey:@"isUpdate"];
    [defaults setInteger:iconSelect forKey:@"iconSelect"];
    
    [self dismissViewControllerAnimated:YES completion:nil];
}
@end
