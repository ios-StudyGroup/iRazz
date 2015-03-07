//
//  RazzViewController.m
//  iRazz
//
//  Created by cat on 2014/08/09.
//  Copyright (c) 2014年 cat. All rights reserved.
//
#import "RazzViewController.h"
#import "ConnectTableViewController.h"

@interface RazzViewController ()

- (IBAction)start:(id)sender;


@end

@implementation RazzViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    
    // NSUserDefaultsのdisplayNameに値がセットされていなければ、デバイス名を入れておく
    NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];  // 取得
    if ([ud stringForKey:@"displayName"] == nil){
        NSString * deviceName = [[UIDevice currentDevice] name];
        // displayName は UTF-8 の文字列で、63 byte 以内
        NSString *encodedString = [deviceName stringByAddingPercentEscapesUsingEncoding:
                                   NSUTF8StringEncoding];
        [ud setObject:encodedString forKey:@"displayName"];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
 #pragma mark - Navigation
 
 // In a storyboard-based application, you will often want to do a little preparation before navigation
 - (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
 // Get the new view controller using [segue destinationViewController].
 // Pass the selected object to the new view controller.
 }
 */

- (IBAction)start:(id)sender {
    
    ConnectTableViewController *tableViewController = [[ConnectTableViewController alloc] init];
 
    UINavigationController *navigationController = [[ UINavigationController alloc] initWithRootViewController:tableViewController];
    [self presentViewController:navigationController animated:YES completion:^ {
        // 完了時の処理をここに書きます
    }];
}

@end

