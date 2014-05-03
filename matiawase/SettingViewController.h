//
//  settingViewController.h
//  mytestapp
//
//  Created by HirokiNakamura on 2014/03/03.
//  Copyright (c) 2014年 HirokiNakamura. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SettingViewController : UIViewController
- (IBAction)backButtonAction:(id)sender;
@property (weak, nonatomic) IBOutlet UITextField *groupname;
@property (weak, nonatomic) IBOutlet UITextField *username;
@property (weak, nonatomic) IBOutlet UISwitch *isUpdate;
@property (weak, nonatomic) IBOutlet UISegmentedControl *iconSelect;

@end
