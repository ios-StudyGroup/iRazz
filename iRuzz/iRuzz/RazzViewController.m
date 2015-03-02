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
- (IBAction)connectClick:(id)sender;

@end

@implementation RazzViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
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

- (IBAction)connectClick:(id)sender {
    
    
    
    // 次画面を指定して遷移
    ConnectTableViewController *tableViewController = [[ConnectTableViewController alloc] init];
    
    
//    tableViewController.modalTransitionStyle = UIModalTransitionStyleFlipHorizontal;
    
    [self presentViewController:tableViewController animated:YES completion:^ {
        // 完了時の処理をここに書きます
    }];
}
@end

