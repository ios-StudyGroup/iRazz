//
//  ConnectViewController.m
//  iRazz
//
//  Created by Ryou Inoue on 2015/02/24.
//  Copyright (c) 2015年 cat. All rights reserved.
//
/**
 @todo
 
 
 */
#import "ConnectViewController.h"

@interface ConnectViewController ()<UITextFieldDelegate>


@property (weak, nonatomic) IBOutlet UITextField *displayNameTextField;

- (IBAction)setDisplayButtonClick:(id)sender;

@end

@implementation ConnectViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.

    
    
    NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];  // 取得
    self.displayNameTextField.text = [ud stringForKey:@"displayName"];
    
    
    // UITextFieldDelegateの設定
    self.displayNameTextField.delegate = self;
    // 「改行（Return）」キーの設定
    self.displayNameTextField.returnKeyType = UIReturnKeyDone;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)setDisplayButtonClick:(id)sender {
    NSLog(@"%s", __func__);

    if ([self checkDisplayName:self.displayNameTextField.text] == YES){
        // NSUserDefaultsに登録
        NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];  // 取得
        NSString *encodedString = [self.displayNameTextField.text stringByAddingPercentEscapesUsingEncoding:
                                   NSUTF8StringEncoding];
        [ud setObject:encodedString forKey:@"displayName"];
        
        
        [self dismissViewControllerAnimated:NO completion:nil]; /* Close */
    }
    
}


-(BOOL)checkDisplayName:(NSString *)displayName
{
    if ([displayName length] == 0){
        return NO;
    }else{
        return YES;
    }
}


# pragma mark - UITextFieldDelegate methods
// キーボードのDoneをタップすると、キーボードを閉じるように
-(BOOL)textFieldShouldReturn:(UITextField*)textField
{
    NSLog(@"%s", __func__);
    
    [self.displayNameTextField resignFirstResponder];
    return YES;
}





@end