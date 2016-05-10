//
//  XPCIOSurface.h
//  XPCKit
//
//  Created by Adam Fedor on 5/9/16.
//  Copyright © 2016 Mustacheware. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface XPCIOSurface : NSObject
@property IOSurfaceRef surfaceRef;

+ (XPCIOSurface *) surfaceRefWithXPCObject:(xpc_object_t)xpc;
- (id)initWithSurfaceRef: (IOSurfaceRef)surfaceRef;

@end
