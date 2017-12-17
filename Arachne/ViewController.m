//
//  ViewController.m
//  Arachne
//
//  Created by york on 2017/12/5.
//  Copyright © 2017年 zero. All rights reserved.
//
#import <Vision/Vision.h>
#import "ViewController.h"
#import "ARManagerView.h"
#import "SubMenu.h"



@interface ViewController () <UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, strong) IBOutlet ARManagerView *sceneView;

@property (weak, nonatomic) IBOutlet UIButton *subMenuButton;
@property (weak, nonatomic) IBOutlet SubMenu *subMenu;
@property (nonatomic , strong)NSArray *data;


@end

    
@implementation ViewController {
    NSString *selectBlockName;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [_sceneView ARManagerViewLoaded];
    
    _data = [NSArray arrayWithObjects:
                          @"ADD" ,
                          @"MINES" ,
                          @"MUTIPLE" ,
                          @"AND" ,
                          @"OR"
                        ,nil];
    selectBlockName = [_data firstObject];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [_sceneView ARManagerViewConfigureSession];

}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [_sceneView ARManagerViewStop];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

#pragma mark - TableView
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *tablecell = [[UITableViewCell alloc] init];
    [tablecell.textLabel setText:[_data objectAtIndex:indexPath.row]];
    return  tablecell;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return [_data count];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    NSLog(@"%d", indexPath.row);
}

- (void)rowClickedWithIndex: (NSInteger) index {
    selectBlockName = [_data objectAtIndex:index];
    [_sceneView setSelectBlockName:selectBlockName];
}


#pragma mark - SubMenuButton
- (IBAction)subMenuButtonClicked:(id)sender {
    
}


@end
