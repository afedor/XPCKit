//
//  XPCIOSurface.m
//  XPCKit
//
//  Created by Adam Fedor on 5/9/16.
//  Copyright © 2016 Mustacheware. All rights reserved.
//

#import "XPCIOSurface.h"

@implementation XPCIOSurface

-(xpc_object_t)newXPCObject
{
  if (self.surfaceRef == NULL) {
    [NSException raise: @"XPCNotNSCodingConformantException" format: @"No IOSurfaceID set"];
  }
  return IOSurfaceCreateXPCObject(self.surfaceRef);
}

-(NSString *)description
{
  return [NSString stringWithFormat:@"<%@ %p>",[self class], self.surfaceRef];
}

-(BOOL)isEqual:(id)object
{
  if ([object isKindOfClass: [XPCIOSurface class]] == NO)
    return NO;
  return (IOSurfaceGetID(self.surfaceRef) == IOSurfaceGetID([(XPCIOSurface *)object surfaceRef]));
}

-(NSUInteger)hash
{
  return (NSInteger)self.surfaceRef;
}

- (id)initWithSurfaceRef: (IOSurfaceRef)surfaceRef
{
  if ((self = [super init]) == nil)
    return self;
  _surfaceRef = surfaceRef;
  return self;
}

+ (XPCIOSurface *) surfaceRefWithXPCObject:(xpc_object_t)xpc
{
  IOSurfaceRef newSurface = IOSurfaceLookupFromXPCObject(xpc);
  return [[XPCIOSurface alloc] initWithSurfaceRef: newSurface];
}

@end
