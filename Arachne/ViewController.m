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
#import "JsonPaser.h"
#import "NetworkManager.h"



@interface ViewController () <UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, strong) IBOutlet ARManagerView *sceneView;

@property (weak, nonatomic) IBOutlet UIButton *subMenuButton;
@property (weak, nonatomic) IBOutlet SubMenu *subMenu;
@property (nonatomic , strong)NSArray *data;

@property (weak, nonatomic) IBOutlet UIButton *searchButton;
@property (weak, nonatomic) IBOutlet UITextField *searchText;
@property (weak, nonatomic) IBOutlet UIView *mask;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *waiter;
@property (weak, nonatomic) IBOutlet UIView *searchMenu;

@property (weak, nonatomic) IBOutlet UIView *addMenu;
@property (weak, nonatomic) IBOutlet UITextField *addText;

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
    
    NSString *search = [JsonPaser getSearchJson:@"jjj"];
    [[NetworkManager getInstance] sentMessage:@"getSearch" :search :^(NSString *data){
        NSLog(@"OVER");
    }];
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

- (IBAction)searchButtonClicked:(id)sender {
    NSString *keyword = [_searchText text];
    NSString *sentS =[JsonPaser getSearchJson:keyword];
    //[self startWaiting];
    [self.view endEditing:YES];
    
    [[NetworkManager getInstance] sentMessage:@"getSearch" :sentS :^(NSString *data) {
        if([data length] == 1) return ;
        NSDictionary *dic = [JsonPaser dictionaryWithJsonString:data];
        float pos[3];
        if([dic objectForKey:@"posX"] == nil || [dic objectForKey:@"posY"] == nil || [dic objectForKey:@"posZ"] == nil) return;
        
        pos[0] = [[dic objectForKey:@"posX"] floatValue];
        pos[1] = [[dic objectForKey:@"posY"] floatValue];
        pos[2] = [[dic objectForKey:@"posZ"] floatValue];
        
        [_sceneView CreateBlockWithPos:pos[0] :pos[1] :pos[2]];
    }];
}

- (IBAction)addButtonClicked:(id)sender {
    NSString *nameString = [_addText text];
    float *vector = [_sceneView getLastNodePos];
    NSDictionary *dic = @{
                     @"name": nameString,
                     @"posX": [NSNumber numberWithFloat:vector[0]],
                     @"posY": [NSNumber numberWithFloat:vector[1]],
                     @"posZ": [NSNumber numberWithFloat:vector[2]]
                     };
    NSString *outS = [JsonPaser dictToJsonStr:dic];
    //[self startWaiting];
    [[NetworkManager getInstance] sentMessage:@"newPos" :outS :^(NSString *data) {
        //[self stopWaitting];
    }];
}

- (IBAction)clearButtonClicked:(id)sender {
}

- (IBAction)labelTouched:(id)sender {
    bool addMenuHidden = [_addMenu isHidden];
    bool searchMenuHidden = [_searchMenu isHidden];
    
    [_addMenu setHidden:!addMenuHidden];
    [_searchMenu setHidden:!searchMenuHidden];
    
    if(addMenuHidden == false) {
        [_sceneView SetAbleToSetNewBlock:false];
    } else {
        [_sceneView SetAbleToSetNewBlock:true];
    }
}

- (void)startWaiting {
    [_waiter startAnimating];
    [_mask setHidden:false];
}

- (void)stopWaitting {
    [_waiter stopAnimating];
    [_mask setHidden:true];
}

@end
