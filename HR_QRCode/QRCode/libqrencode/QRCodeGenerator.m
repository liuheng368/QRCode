//
// QR Code Generator - generates UIImage from NSString
//
// Copyright (C) 2012 http://moqod.com Andrew Kopanev <andrew@moqod.com>
//
// Permission is hereby granted, free of charge, to any person obtaining a copy 
// of this software and associated documentation files (the "Software"), to deal 
// in the Software without restriction, including without limitation the rights 
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies 
// of the Software, and to permit persons to whom the Software is furnished to do so, 
// subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in all 
// copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, 
// INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR 
// PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE
// FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR 
// OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER 
// DEALINGS IN THE SOFTWARE.
//

#import "QRCodeGenerator.h"
#import "qrencode.h"


#define PI 3.14159265358979323846
enum {
	qr_margin = 3
};

@implementation QRCodeGenerator

+ (void)drawQRCode:(QRcode *)code context:(CGContextRef)ctx size:(CGFloat)size {
	unsigned char *data = 0;
	int width;
	data = code->data;
	width = code->width;
	float zoom = (double)size / (code->width + 2.0 * qr_margin);
	CGRect rectDraw = CGRectMake(0, 0, zoom, zoom);
	
	// draw
	CGContextSetFillColor(ctx, CGColorGetComponents([UIColor redColor].CGColor));
	for(int i = 0; i < width; ++i) {
		for(int j = 0; j < width; ++j) {
			if(*data & 1) {
				rectDraw.origin = CGPointMake((j + qr_margin) * zoom,(i + qr_margin) * zoom);
				CGContextAddRect(ctx, rectDraw);
			}
			++data;
		}
	}
	CGContextFillPath(ctx);
}

+ (UIImage *)qrImageForString:(NSString *)string imageSize:(CGFloat)size {
	if (![string length]) {
		return nil;
	}
	
	QRcode *code = QRcode_encodeString([string UTF8String], 0, QR_ECLEVEL_H, QR_MODE_8, 1);
	if (!code) {
		return nil;
	}
	
	// create context
	CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
	CGContextRef ctx = CGBitmapContextCreate(0, size, size, 8, size * 4, colorSpace, kCGImageAlphaPremultipliedLast);
	
	CGAffineTransform translateTransform = CGAffineTransformMakeTranslation(0, -size);
	CGAffineTransform scaleTransform = CGAffineTransformMakeScale(1, -1);
	CGContextConcatCTM(ctx, CGAffineTransformConcat(translateTransform, scaleTransform));
	
	// draw QR on this context	
	[QRCodeGenerator drawQRCode:code context:ctx size:size];
	
	// get image
	CGImageRef qrCGImage = CGBitmapContextCreateImage(ctx);
	UIImage * qrImage = [UIImage imageWithCGImage:qrCGImage];
	
	// some releases
	CGContextRelease(ctx);
	CGImageRelease(qrCGImage);
	CGColorSpaceRelease(colorSpace);
	QRcode_free(code);
	
	return qrImage;
}

#pragma mark - custom method

typedef NS_OPTIONS(NSInteger, CodePointMask) {
    OutTopLeft           = 1 << 0,
    InTopLeft            = 1 << 1,
    OutTopRight          = 1 << 2,
    InTopRight           = 1 << 3,
    OutBottomLeft        = 1 << 4,
    InBottomLeft        = 1 << 5,
};

+ (UIImage *)qrImageForString:(NSString *)string imageSize:(CGFloat)size PointType:(QRPointType)pointType Color:(UIColor *)color withRandomPercent:(int)percent withRandomColor:(UIColor *)randomColor  logoImage:(UIImage *)logoImage{
    if (![string length]) {
        return nil;
    }
    QRcode *code = QRcode_encodeString([string UTF8String], 0, QR_ECLEVEL_Q, QR_MODE_8, 1);
    if (!code) {
        return nil;
    }
    
    // create context
    float scaleFactor = [[UIScreen mainScreen] scale];
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    CGContextRef ctx = CGBitmapContextCreate(0, size * scaleFactor, size * scaleFactor, 8, size * 4 * scaleFactor, colorSpace, kCGImageAlphaPremultipliedFirst);
    CGContextScaleCTM(ctx, scaleFactor, scaleFactor);
    
    CGAffineTransform translateTransform = CGAffineTransformMakeTranslation(0, -size);
    CGAffineTransform scaleTransform = CGAffineTransformMakeScale(1, -1);
    CGContextConcatCTM(ctx, CGAffineTransformConcat(translateTransform, scaleTransform));
    
    // draw QR on this context
    [QRCodeGenerator drawQRCode:code context:ctx size:size withPointType:pointType withColor:color withRandomPercent:percent withRandomColor:randomColor];
    
    // get qrcode image
    CGImageRef qrCGImage = CGBitmapContextCreateImage(ctx);
    UIImage * qrcodeImage = [UIImage imageWithCGImage:qrCGImage];
    
    // 增加logo
    UIImage *resultImage = [self addQRCodeLogoImage:qrcodeImage logoImage:logoImage];
    
    // some releases
    CGContextRelease(ctx);
    CGImageRelease(qrCGImage);
    CGColorSpaceRelease(colorSpace);
    QRcode_free(code);
    
    return resultImage;
}

+ (void)drawQRCode:(QRcode *)code context:(CGContextRef)ctx size:(CGFloat)size withPointType:(QRPointType)pointType withColor:(UIColor *)color  withRandomPercent:(int)percent withRandomColor:(UIColor *)randomColor {
    if (color) {
        const CGFloat *components = CGColorGetComponents(color.CGColor);
        if (CGColorGetNumberOfComponents(color.CGColor) == 2) {
            CGContextSetFillColor(ctx, CGColorGetComponents([UIColor colorWithWhite:components[0] alpha:components[1]].CGColor));
            CGContextSetStrokeColor(ctx, CGColorGetComponents([UIColor colorWithWhite:components[0] alpha:components[1]].CGColor));
        } else {
            CGContextSetRGBFillColor(ctx, components[0], components[1], components[2], components[3]);
            CGContextSetRGBStrokeColor(ctx, components[0], components[1], components[2], components[3]);
        }
    } else {
        CGContextSetFillColor(ctx, CGColorGetComponents([UIColor blackColor].CGColor));
        CGContextSetStrokeColor(ctx, CGColorGetComponents([UIColor blackColor].CGColor));
    }
    
	unsigned char *data = 0;
	int width;
    
    width = code->width;
    float zoom = (double)size / (double)width;
    CGRect rectDraw = CGRectMake(0, 0, zoom, zoom);
    int codePoint = 0;
    float emptyRoundRadius = size * 0.40 * 0.5; // 0.4： 中间logo外围空余  0.5： 半径
    // 码点内部
    data = code->data;
    CGContextSetLineWidth(ctx, zoom);
    for(int i = 0; i < width; ++i) {
        for(int j = 0; j < width; ++j) {
            if(*data & 1) {
                if (i >= 0 && i < 7 && j >= 0 && j < 7 && !(codePoint & InTopLeft)) {
                    CGContextBeginPath(ctx);
                    CGContextAddArc(ctx, 3.5 * zoom, 3.5 * zoom, 2.8 * zoom, 0, 2 * PI, 0);
                    CGContextDrawPath(ctx, kCGPathStroke);
                    codePoint |= InTopLeft;
                }
                else if (i >= width - 7 && i < width && j >= 0 && j < 7 && !(codePoint & InBottomLeft)) {
                    CGContextBeginPath(ctx);
                    CGContextAddArc(ctx, 3.5 * zoom, (width - 3.5) * zoom, 2.8 * zoom, 0, 2 * PI, 0);
                    CGContextDrawPath(ctx, kCGPathStroke);
                    codePoint |= InBottomLeft;
                }
                else if (i >= 0 && i < 7 && j >= width - 7 && j < width && !(codePoint & InTopRight)) {
                    CGContextBeginPath(ctx);
                    CGContextAddArc(ctx, (width - 3.5) * zoom, 3.5 * zoom, 2.8 * zoom, 0, 2 * PI, 0);
                    CGContextDrawPath(ctx, kCGPathStroke);
                    codePoint |= InTopRight;
                }
            }
            ++data;
        }
    }
    
    // 码点外部 + 其他点
	data = code->data;
    NSMutableArray *arrRandamColorPoint = [NSMutableArray array];
	for(int i = 0; i < width; ++i) {
		for(int j = 0; j < width; ++j) {
			if(*data & 1) {
                if (i > 1 && i < 5 && j > 1 && j < 5 && !(codePoint & OutTopLeft)) {
                    CGRect rectDraw2 = CGRectMake(2 * zoom, 2 * zoom, 3 * zoom, 3 * zoom);
                    switch (pointType) {
                        case QRPointRect:
                            CGContextAddRect(ctx, rectDraw2);
                            break;
                        case QRPointRound:
                            CGContextAddEllipseInRect(ctx, rectDraw2);
                            break;
                        default:
                            break;
                    }
                    codePoint |= OutTopLeft;
                }
                else if (i > 1 && i < 5 && j > width-6 && j < width-2 && !(codePoint & OutBottomLeft))
                {
                    CGRect rectDraw2 = CGRectMake(2 * zoom, (width-5) * zoom, 3 * zoom, 3 * zoom);
                    switch (pointType) {
                        case QRPointRect:
                            CGContextAddRect(ctx, rectDraw2);
                            break;
                        case QRPointRound:
                            CGContextAddEllipseInRect(ctx, rectDraw2);
                            break;
                        default:
                            break;
                    }
                    codePoint |= OutBottomLeft;
                }
                else if (i > width-6 && i < width-2 && j > 1 && j < 5 && !(codePoint & OutTopRight))
                {
                    CGRect rectDraw2 = CGRectMake((width-5) * zoom, 2 * zoom, 3 * zoom, 3 * zoom);
                    switch (pointType) {
                        case QRPointRect:
                            CGContextAddRect(ctx, rectDraw2);
                            break;
                        case QRPointRound:
                            CGContextAddEllipseInRect(ctx, rectDraw2);
                            break;
                        default:
                            break;
                    }
                    codePoint |= OutTopRight;
                }
                else if (pointType == QRPointRound &&
                        ((i >= 0 && i < 7 && j >= 0 && j < 7) ||
                        (i >= width - 7 && i < width && j >= 0 && j < 7) ||
                        (i >= 0 && i < 7 && j >= width - 7 && j < width))) {
                    // 顶端码点
                }
                else
                {
                    rectDraw.origin = CGPointMake((j) * zoom,(i) * zoom);
                    // 中心留空
                    if (sqrt((rectDraw.origin.x - (size / 2)) * (rectDraw.origin.x - (size / 2)) + (rectDraw.origin.y - (size / 2)) * (rectDraw.origin.y - (size / 2))) > emptyRoundRadius) {
                        if (arc4random() % 100 < percent) {
                            // 添加随机色
                            [arrRandamColorPoint addObject:[NSValue valueWithCGRect:rectDraw]];
                        } else {
                            switch (pointType) {
                                case QRPointRect:
                                    CGContextAddRect(ctx, rectDraw);
                                    break;
                                case QRPointRound:
                                    CGContextAddEllipseInRect(ctx, rectDraw);
                                    break;
                                default:
                                    break;
                            }
                        }
                    }
                }
			}
			++data;
		}
	}
	CGContextFillPath(ctx);
    
    // 随机颜色点
    if (randomColor) {
        const CGFloat *components = CGColorGetComponents(randomColor.CGColor);
        if (CGColorGetNumberOfComponents(randomColor.CGColor) == 2) {
            CGContextSetFillColor(ctx, CGColorGetComponents([UIColor colorWithWhite:components[0] alpha:components[1]].CGColor));
            CGContextSetStrokeColor(ctx, CGColorGetComponents([UIColor colorWithWhite:components[0] alpha:components[1]].CGColor));
        } else {
            CGContextSetRGBFillColor(ctx, components[0], components[1], components[2], components[3]);
            CGContextSetRGBStrokeColor(ctx, components[0], components[1], components[2], components[3]);
        }
    } else {
        CGContextSetFillColor(ctx, CGColorGetComponents([UIColor blackColor].CGColor));
        CGContextSetStrokeColor(ctx, CGColorGetComponents([UIColor blackColor].CGColor));
    }
    [arrRandamColorPoint enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        switch (pointType) {
            case QRPointRect:
                CGContextAddRect(ctx, [obj CGRectValue]);
                break;
            case QRPointRound:
                CGContextAddEllipseInRect(ctx, [obj CGRectValue]);
                break;
            default:
                break;
        }
    }];
    
    CGContextFillPath(ctx);
}

+ (UIImage *)addQRCodeLogoImage:(UIImage *)image logoImage:(UIImage *)logoImage{
    CGFloat logoImageW = image.size.width * 0.3;
    CGFloat logoImageH = logoImageW;
    CGFloat logoImageX = 0.5 * (image.size.width - logoImageW);
    CGFloat logoImageY = 0.5 * (image.size.height - logoImageH);
    CGRect logoImageRect = CGRectMake(logoImageX, logoImageY, logoImageW, logoImageH);
    // 绘制logo
    UIGraphicsBeginImageContextWithOptions(image.size, false, 0);
    [image drawInRect:CGRectMake(0, 0, image.size.width, image.size.height)];
    
    UIBezierPath *path = [UIBezierPath bezierPathWithRoundedRect:logoImageRect cornerRadius: logoImageW / 2];
    [path addClip];
    [logoImage drawInRect:logoImageRect];
    UIImage *QRCodeImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return  QRCodeImage;
}

@end

/*
    
 */
