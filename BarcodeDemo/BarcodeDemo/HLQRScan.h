//
//  HLQRScanView.h
//  BarcodeDemo
//
//  Created by 侯卫磊 on 2017/6/2.
//  Copyright © 2017年 houweilei. All rights reserved.
//

#import <UIKit/UIKit.h>

@class HLQRScan;

@protocol HLQRScanDelegate <NSObject>

@optional
- (void)qrScan:(HLQRScan *)qrScan metadataObjects:(NSArray *)metadataObjects;
@end


@interface HLQRScan : UIView
// 扫描范围
@property (nonatomic, assign) CGRect scanRect;

@property (nonatomic, weak) id <HLQRScanDelegate> delegate;


/**
 初始化扫描对象

 @param superView 父视图

 @return 当前对象的实例
 */
- (instancetype)initWithSuperView:(UIView *)superView;

- (void)resetScanState;

// 开始扫描
- (void)startScan;

// 停止扫描 
- (void)stopScan;

// 开始线的动画
- (void)startLineAnimation;

// 暂停线的动画
- (void)stopLineAnimation;

@end
