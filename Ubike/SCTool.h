//
//  SCTool.h
//  Ubike
//
//  Created by Prince on 5/10/14.
//  Copyright (c) 2014 wpsteak. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SCTool : NSObject

+ (UIImage *)imageWithImage:(UIImage *)image scaledToSize:(CGSize)newSize;
+ (NSDictionary *) TWD97TM2toWGS84:(double )x :(double)y;

@end
