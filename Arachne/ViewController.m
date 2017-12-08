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



@interface ViewController ()

@property (nonatomic, strong) IBOutlet ARManagerView *sceneView;

@property (weak, nonatomic) IBOutlet UIButton *subMenuButton;
@property (weak, nonatomic) IBOutlet SubMenu *subMenu;

@end

    
@implementation ViewController {
    
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [_sceneView ARManagerViewLoaded];
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

#pragma mark - SubMenuButton
- (IBAction)subMenuButtonClicked:(id)sender {
    
}

@end
