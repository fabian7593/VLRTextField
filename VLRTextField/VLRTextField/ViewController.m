//
//  ViewController.m
//  VLRTextField
//
//  Created by Marian Paul on 2015-01-01.
//  Copyright (c) 2015 RezZza. All rights reserved.
//

#import "ViewController.h"
#import "VLRTextField.h"
#import "VLRFormService.h"

#import "VLRTextField+Form.h"

#import <PPHelpMe/PPHelpMe.h>

#import "VLRAutoCompleteManager.h"

static CGFloat kXOffset         = 10.0f;
static CGFloat kYOffset         = 7.0f;
static CGFloat kTextFieldHeight = 40.0f;

static NSString *REGULAR_EXPRESSION_EMAIL = @"[a-zA-Z0-9!#$%&'*+/=?^_`{|}~-]+(\\.[a-zA-Z0-9!#$%&'*+/=?^_`{|}~-]+)*@([a-zA-Z0-9-]+\\.)+[a-zA-Z]{2,6}";

@interface ViewController () <UITextFieldDelegate>

@property (nonatomic, strong) VLRFormService *registerFormManager;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    CGFloat width = PPScreenWidth() - 2.0f * kXOffset;
    
    VLRTextField *name          = [VLRTextField formTextFieldWithFrame:CGRectMake(kXOffset, kYOffset + 40.0f, width, kTextFieldHeight) placeholder:@"Enter your first name"];
    name.autocapitalizationType = UITextAutocapitalizationTypeWords;
    name.formKeyPath            = @"name";
    name.messageRequired        = @"Your first name is required";

    VLRTextField *email          = [VLRTextField formTextFieldWithFrame:CGRectMake(kXOffset, kYOffset + CGRectGetMaxY(name.frame), width, kTextFieldHeight) placeholder:@"Enter an email to reach you"];
    email.keyboardType           = UIKeyboardTypeEmailAddress;
    email.regex                  = REGULAR_EXPRESSION_EMAIL;
    email.messageInvalid         = @"Your email address is invalid";
    email.messageRequired        = @"Please enter an email adress";
    email.formKeyPath            = @"email_address";
    email.autocompleteDataSource = [VLRAutoCompleteManager sharedManager];
    email.autocompleteType       = VLRAutocompleteTypeEmail;
    
    VLRTextField *password             = [VLRTextField formTextFieldWithFrame:CGRectMake(kXOffset, kYOffset + CGRectGetMaxY(email.frame), width, kTextFieldHeight) placeholder:@"Enter a password"];
    password.minimumNumberOfCharacters = 8;
    password.messageRequired           = @"The password should be 8 characters long";
    password.formKeyPath               = @"password_1";
    password.secureTextEntry           = YES;
    
    VLRTextField *passwordConfirmation             = [VLRTextField formTextFieldWithFrame:CGRectMake(kXOffset, kYOffset + CGRectGetMaxY(password.frame), width, kTextFieldHeight) placeholder:@"Re enter your password"];
    passwordConfirmation.messageInvalid            = @"The two passwords should match";
    passwordConfirmation.messageRequired           = @"Please re enter your password";
    passwordConfirmation.minimumNumberOfCharacters = password.minimumNumberOfCharacters;
    passwordConfirmation.formKeyPath               = @"password_2";
    passwordConfirmation.secureTextEntry           = YES;
    passwordConfirmation.validateBlock             = ^BOOL(VLRTextField *textField) {
        return [[password text] isEqualToString:textField.text];
    };

    VLRTextField *company          = [VLRTextField formTextFieldWithFrame:CGRectMake(kXOffset, kYOffset + CGRectGetMaxY(passwordConfirmation.frame), width, kTextFieldHeight) placeholder:@"Enter the company you work for"];
    company.fillRequired           = NO;
    company.formKeyPath            = @"company_name";
    company.autocompleteDataSource = [VLRAutoCompleteManager sharedManager];
    company.autocompleteType       = VLRAutoCompleteCompany;
    company.autocapitalizationType = UITextAutocapitalizationTypeSentences;
    company.returnKeyType          = UIReturnKeyDone;
    
    [self.view addSubview:name];
    [self.view addSubview:email];
    [self.view addSubview:password];
    [self.view addSubview:passwordConfirmation];
    [self.view addSubview:company];
    
    self.registerFormManager          = [VLRFormService new];
    
    // The order does matter (for next behavior)
    [self.registerFormManager addTextField:name];
    [self.registerFormManager addTextField:email];
    [self.registerFormManager addTextField:password];
    [self.registerFormManager addTextField:passwordConfirmation];
    [self.registerFormManager addTextField:company];
    
    // We only need company to have self as delegate since the send is done here
    company.delegate = self;
    
    UIButton *sendButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [sendButton setSize:CGSizeMake(80.0f, 30.0f)];
    [sendButton setTitle:@"Send" forState:UIControlStateNormal];
    [sendButton setTitleColor:[UIColor blueColor] forState:UIControlStateNormal];
    [sendButton addTarget:self action:@selector(send) forControlEvents:UIControlEventTouchUpInside];
    [sendButton setCenter:CGPointMake(PPScreenWidth() / 2.0f, CGRectGetMaxY(company.frame) + 40.0f)];
    [self.view addSubview:sendButton];
}


- (void) send {
    BOOL formValid = [self.registerFormManager checkForm]; // Will check and display errors
    if (formValid) {
        [self.registerFormManager.activeField resignFirstResponder];
        [self safelySend];
    }
}

- (void) safelySend {
    
    // Check one last time just to be sure
    BOOL formValid = [self.registerFormManager checkFormAndShowErrors:NO];
    
    if (formValid) {
        NSDictionary *json = [self.registerFormManager extractFieldsAsJson];
        NSLog(@"You would be ready to send: \n %@", json);
    }
    
}

#pragma mark - UITextField delegate

// Next behavior is natively handled by `VLRFormService`
- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    if (textField.returnKeyType == UIReturnKeyDone) {
        [self send];
    }
    
    return YES;
}

@end
