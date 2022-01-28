//
//  XYPHQRCodeObtainConfigure.m
//  Halo
//
//  Created by gaohui on 2018/10/17.
//  Copyright © 2018年 XingIn. All rights reserved.
//

#import "XYPHQRCodeObtainConfigure.h"

@implementation XYPHQRCodeObtainConfigure

+ (instancetype)obtainConfigureManager {
    return [[self alloc] init];
}

- (NSString *)sessionPreset {
    if (!_sessionPreset) {
        _sessionPreset = AVCaptureSessionPreset1920x1080;
    }
    return _sessionPreset;
}

- (NSArray *)metadataObjectTypes {
    if (!_metadataObjectTypes) {
        _metadataObjectTypes = @[AVMetadataObjectTypeQRCode];
    }
    return _metadataObjectTypes;
}


@end
