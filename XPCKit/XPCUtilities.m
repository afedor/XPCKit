//
//  XPCUtilities.m
//  XPCKit
//
//  Created by Jörg Jacobsen on 3/7/12. Copyright 2012 XPCKit.
//
//  Licensed under the Apache License, Version 2.0 (the "License");
//  you may not use this file except in compliance with the License.
//  You may obtain a copy of the License at
//
//  http://www.apache.org/licenses/LICENSE-2.0
//
//  Unless required by applicable law or agreed to in writing, software
//  distributed under the License is distributed on an "AS IS" BASIS,
//  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
//  See the License for the specific language governing permissions and
//  limitations under the License.
//

#import "XPCUtilities.h"

#pragma mark - Message Dispatching

// Dispatch a message with optional argument object to a target object asynchronously.
// When XPConnection is not nil the message will be transfered to XPC service for execution
//     (i.e. target and object must conform to NSCoding when connection is not nil).
// When XPCConnection is nil (e.g. running on Snow Leopard) message will be dispatched asynchronously via GCD.

void XPCPerformSelectorAsync(XPCConnection *inConnection,
                                   id inTarget, SEL inSelector, id inObject,
                                   XPCReturnValueHandler inReturnHandler)
{
    // If we are running sandboxed on Lion (or newer), then send a request to perform selector on target to our XPC
    // service and hand the results to the supplied return handler block...
    
    if (inConnection)
    {
        [inConnection sendSelector:inSelector
                        withTarget:inTarget
                            object:inObject
                returnValueHandler:inReturnHandler];
    }
    
    // If we are not sandboxed (e.g. running on Snow Leopard) we'll just do the work directly (but asynchronously)
    // via GCD queues. Once again the result is handed over to the return handler block...
    
    else
    {
        // Copy target and object so they are dispatched under same premises as XPC (XPC uses archiving)
        
        id targetCopy = [NSKeyedUnarchiver unarchiveObjectWithData:[NSKeyedArchiver archivedDataWithRootObject:inTarget]];
        id objectCopy = [NSKeyedUnarchiver unarchiveObjectWithData:[NSKeyedArchiver archivedDataWithRootObject:inObject]];
        
        dispatch_queue_t currentQueue = dispatch_get_current_queue();
      
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT,0),^()
                       {
                           NSError* error = nil;
                           id result = XPCKitInvokeSelector(targetCopy, inSelector, objectCopy, &error);
                           dispatch_async(currentQueue,^()
                                          {
                                              inReturnHandler(result, error);
                                          });
                       });
    }
}

id XPCKitInvokeSelector(id inTarget, SEL inSelector, id inObject, NSError **perror)
{
  __unsafe_unretained id ierror = nil;
  __unsafe_unretained id *errorPtr = &ierror;
  void *tempResult;
  int index = 2;
  __unsafe_unretained id unsafeObject = inObject;
  NSInvocation *invocation = [NSInvocation invocationWithMethodSignature: [inTarget methodSignatureForSelector: inSelector]];
  [invocation setTarget: inTarget];
  [invocation setSelector: inSelector];
  // Note: Indexes 0 and 1 correspond to the implicit arguments self and _cmd,
  // which are set using setTarget and setSelector.
  if (inObject)
    [invocation setArgument: &unsafeObject atIndex: index++];
  [invocation setArgument: &errorPtr atIndex: index++];
  [invocation retainArguments];
  [invocation invoke];
  [invocation getReturnValue: &tempResult];
  if (perror)
    *perror = ierror;
  return (__bridge id)tempResult;
}

#pragma mark - Log Levels

static XPCLogLevel sLogLevel = XPCLogLevelErrors;

XPCLogLevel XPCGetLogLevel(void)
{
    return sLogLevel;
}


void XPCSetLogLevel(XPCLogLevel inLogLevel)
{
    sLogLevel = inLogLevel;
}


