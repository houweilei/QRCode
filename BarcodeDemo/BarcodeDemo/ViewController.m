//
//  ViewController.m
//  BarcodeDemo
//
//  Created by 侯卫磊 on 2017/6/2.
//  Copyright © 2017年 houweilei. All rights reserved.
//

#import "ViewController.h"
#import "HLQRScan.h"


@interface ViewController () <HLQRScanDelegate>
@property (nonatomic, strong) HLQRScan *qrScan;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.qrScan = [[HLQRScan alloc] initWithSuperView:self.view];
    self.qrScan.scanRect = CGRectMake(40, 100, CGRectGetWidth(self.view.bounds) - 80, CGRectGetWidth(self.view.bounds) - 80);
    self.qrScan.delegate = self;
    // Do any additional setup after loading the view, typically from a nib.
}

- (void)qrScan:(HLQRScan *)qrScan metadataObjects:(NSArray *)metadataObjects {
    [qrScan stopScan];
    [qrScan stopLineAnimation];
    
    sleep(5);
    [qrScan resetScanState];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
