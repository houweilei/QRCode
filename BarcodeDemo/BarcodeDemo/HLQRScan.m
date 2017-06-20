//
//  HLQRScanView.m
//  BarcodeDemo
//
//  Created by 侯卫磊 on 2017/6/2.
//  Copyright © 2017年 houweilei. All rights reserved.
//

#import "HLQRScan.h"
#import <AVFoundation/AVFoundation.h>

@interface HLQRScan () <AVCaptureMetadataOutputObjectsDelegate>
@property (nonatomic, strong) AVCaptureSession *session;
@property (nonatomic, strong) AVCaptureVideoPreviewLayer *previewLayer;
@property (nonatomic, strong) AVCaptureMetadataOutput *output;


@property (nonatomic, strong) UIView *superView;
// 扫描区域的视图
@property (nonatomic, strong) UIView *contentView;


@property (nonatomic, strong) UIView *animationLine;

@end

@implementation HLQRScan

- (instancetype)initWithSuperView:(UIView *)superView {
    self = [super init];
    if (self) {
        _superView = superView;
        [self initScanWithSuperView:superView];
    }
    return self;
}

#pragma mark - 扫描控件的初始化
- (void)initScanWithSuperView:(UIView *)superView {
    
    NSError *error = nil;
    
    AVCaptureDevice *device = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    AVCaptureDeviceInput *deviceInput = [AVCaptureDeviceInput deviceInputWithDevice:device error:&error];
    
    self.output = [[AVCaptureMetadataOutput alloc] init];
    [self.output setMetadataObjectsDelegate:self queue:dispatch_get_main_queue()];
    
    
    self.session = [[AVCaptureSession alloc] init];
    [self.session setSessionPreset:AVCaptureSessionPresetHigh];
    
    [self.session addInput:deviceInput];
    [self.session addOutput:self.output];
    
    self.output.metadataObjectTypes = @[AVMetadataObjectTypeQRCode];

    
    self.previewLayer = [AVCaptureVideoPreviewLayer layerWithSession:self.session];
    self.previewLayer.videoGravity = AVLayerVideoGravityResizeAspectFill;
    self.previewLayer.frame = superView.bounds;
    
    [superView.layer insertSublayer:self.previewLayer atIndex:0];
    
    [self startScan];
}

- (void)startScan {
    [self.session startRunning];
}

- (void)stopScan {
    [self.session stopRunning];
}

- (void)resetScanState {
    [self startScan];
    [self startLineAnimation];
}

#pragma mark - <AVCaptureMetadataOutputObjectsDelegate>
- (void)captureOutput:(AVCaptureOutput *)captureOutput didOutputMetadataObjects:(NSArray *)metadataObjects fromConnection:(AVCaptureConnection *)connection {
    
    if ([self.delegate respondsToSelector:@selector(qrScan:metadataObjects:)]) {
        [self.delegate qrScan:self metadataObjects:metadataObjects];
    }
}



#pragma mark - 添加遮罩
- (void)addMaskLayerWithScanRect:(CGRect)rect {
    CALayer *topLayer = [CALayer layer];
    CGFloat topLayerX = 0.0f;
    CGFloat topLayerY = 0.0f;
    CGFloat topLayerWidth = CGRectGetWidth(self.superView.bounds);
    CGFloat topLayerHeight = rect.origin.y;
    topLayer.frame = CGRectMake(topLayerX, topLayerY, topLayerWidth, topLayerHeight);
    topLayer.backgroundColor = [UIColor blackColor].CGColor;
    topLayer.opacity = 0.7;
    [self.superView.layer addSublayer:topLayer];
    
    CALayer *leftLayer = [CALayer layer];
    CGFloat leftLayerX = 0.0f;
    CGFloat leftLayerY = rect.origin.y;
    CGFloat leftLayerWidth = rect.origin.x;
    CGFloat leftLayerHeight = rect.size.height;
    leftLayer.frame = CGRectMake(leftLayerX, leftLayerY, leftLayerWidth, leftLayerHeight);
    leftLayer.backgroundColor = [UIColor blackColor].CGColor;
    leftLayer.opacity = 0.7;
    [self.superView.layer addSublayer:leftLayer];
    
    CALayer *bottomLayer = [CALayer layer];
    CGFloat bottomLayerX = 0.0f;
    CGFloat bottomLayerY = CGRectGetMaxY(rect);
    CGFloat bottomLayerWidth = topLayerWidth;
    CGFloat bottomLayerHeight = CGRectGetHeight(self.superView.bounds) - bottomLayerY;
    bottomLayer.frame = CGRectMake(bottomLayerX, bottomLayerY, bottomLayerWidth, bottomLayerHeight);
    bottomLayer.backgroundColor = [UIColor blackColor].CGColor;
    bottomLayer.opacity = 0.7;
    [self.superView.layer addSublayer:bottomLayer];
    
    CALayer *rightLayer = [CALayer layer];
    CGFloat rightLayerX = CGRectGetMaxX(rect);
    CGFloat rightLayerY = leftLayerY;
    CGFloat rightLayerWidth = leftLayerWidth;
    CGFloat rightLayerHeight = leftLayerHeight;
    rightLayer.frame = CGRectMake(rightLayerX, rightLayerY, rightLayerWidth, rightLayerHeight);
    rightLayer.backgroundColor = [UIColor blackColor].CGColor;
    rightLayer.opacity = 0.7;
    [self.superView.layer addSublayer:rightLayer];
}

#pragma mark - 设置扫描区域
- (void)setScanRect:(CGRect)scanRect {
    CGFloat superViewWidth = CGRectGetWidth(self.superView.bounds);
    CGFloat superViewHeight = CGRectGetHeight(self.superView.bounds);
    
    self.output.rectOfInterest = CGRectMake(scanRect.origin.x / superViewWidth, scanRect.origin.y / superViewHeight, scanRect.size.width / superViewWidth, scanRect.size.height / superViewWidth);
    
    // 设置了扫描范围，将会添加遮罩
    [self addMaskLayerWithScanRect:scanRect];
    
    // 初始化扫描区域的视图
    [self initContentViewWithScanRect:scanRect];

    [self addAnimation];
}

- (void)initContentViewWithScanRect:(CGRect)scanRect {
    if (!_contentView) {
        _contentView = [[UIView alloc] initWithFrame:scanRect];
    }
    
    [self.superView addSubview:self.contentView];
}

#pragma mark - animation
- (void)addAnimation {
    [self.contentView addSubview:self.animationLine];
    
    [UIView animateWithDuration:2 delay:0 options:UIViewAnimationOptionRepeat | UIViewAnimationOptionCurveLinear animations:^{
        self.animationLine.frame = CGRectMake(0, CGRectGetHeight(self.contentView.bounds), CGRectGetWidth(self.contentView.bounds), 1);

    } completion:^(BOOL finished) {
        if (finished) {
            self.animationLine = [[UIView alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(self.contentView.bounds), 1)];
        }

    }];
    
}

- (void)startLineAnimation {
    self.contentView.layer.speed = 1;
}

- (void)stopLineAnimation {
    self.contentView.layer.speed = 0;
}

#pragma mark - lazy init
- (UIView *)animationLine {
    if (!_animationLine) {
        _animationLine = [[UIView alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(self.contentView.bounds), 1)];
        _animationLine.backgroundColor = [UIColor blueColor];
    }
    return _animationLine;
}

@end
