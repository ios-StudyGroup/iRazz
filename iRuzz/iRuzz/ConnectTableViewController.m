//
//  ConnectTableViewController.m
//  iRazz
//
//  Created by ryo on 2015/03/02.
//  Copyright (c) 2015年 cat. All rights reserved.
//

#import "ConnectTableViewController.h"

@interface ConnectTableViewController()<UITableViewDelegate, UITableViewDataSource>

    @property NSArray *sectionList;
    @property NSDictionary *dataSource;


@end




@implementation ConnectTableViewController


/**
 * ビューがロードし終わったとき
 */
- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // セクション名を設定する
    self.sectionList =  [NSArray arrayWithObjects:@"人間", @"犬", @"その他", nil];
    
    // セルの項目を作成する
    NSArray *peple = [NSArray arrayWithObjects:@"Charlie", @"Sally", @"Lucy", nil];
    NSArray *dogs = [NSArray arrayWithObjects:@"Snoopy", @"Spike", @"Olaf", nil];
    NSArray *others = [NSArray arrayWithObjects:@"Woodstock", nil];
    
    // セルの項目をまとめる
    NSArray *datas = [NSArray arrayWithObjects:peple, dogs, others, nil];
    
    self.dataSource = [NSDictionary dictionaryWithObjects:datas forKeys:self.sectionList];
}

/**
 * テーブル全体のセクションの数を返す
 */
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return [self.sectionList count];
}

/**
 * 指定されたセクションのセクション名を返す
 */
- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    return [self.sectionList objectAtIndex:section];
}

/**
 * 指定されたセクションの項目数を返す
 */
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSString *sectionName = [self.sectionList objectAtIndex:section];
    return [[self.dataSource objectForKey:sectionName ]count];
}

/**
 * 指定された箇所のセルを作成する
 */
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *cellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    
    // セルが作成されていないか?
    if (!cell) { // yes
        // セルを作成
        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
    }
    
    // セクション名を取得する
    NSString *sectionName = [self.sectionList objectAtIndex:indexPath.section];
    
    // セクション名をキーにしてそのセクションの項目をすべて取得
    NSArray *items = [self.dataSource objectForKey:sectionName];
    
    // セルにテキストを設定
    cell.textLabel.text = [items objectAtIndex:indexPath.row];
    
    return cell;
}

/**
 * セルが選択されたとき
 */
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    // セクション名を取得する
    NSString *sectionName = [self.sectionList objectAtIndex:indexPath.section];
    
    // セクション名をキーにしてそのセクションの項目をすべて取得
    NSArray *items = [self.dataSource objectForKey:sectionName];
    
    NSLog(@"「%@」が選択されました", [items objectAtIndex:indexPath.row]);
}

@end