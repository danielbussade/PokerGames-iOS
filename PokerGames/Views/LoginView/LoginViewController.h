//
//  LoginViewController.h
//
//
//  Created by Tope Abayomi on 22/01/2013.
//  Copyright (c) 2013 App Design Vault. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface LoginViewController : UIViewController<UITableViewDataSource, UITableViewDelegate, UITextFieldDelegate>

@property (nonatomic, strong) IBOutlet UITextField *userTextField;
@property (nonatomic, strong) IBOutlet UITextField *passwordTextField;
@property (nonatomic, strong) IBOutlet UITableView *loginTableView;
@property (nonatomic, weak) IBOutlet UIButton *loginButton;

-(IBAction)logInPressed:(id)sender;

@end