//
//  TreadSafetyList.m
//  SynchronizedMutableArray
//
//  Created by Ossey on 2017/6/25.
//  Copyright © 2017年 Ossey. All rights reserved.
//

#import "TreadSafetyList.h"

@interface TreadSafetyList ()

@property (nonatomic, strong) dispatch_queue_t dispatchQueue;

@end

@implementation TreadSafetyList

- (instancetype)init
{
    self = [super init];
    if (self) {
        _dispatchQueue = dispatch_queue_create("com.ossey.TreadSafetyList", NULL);
    }
    return self;
}



- (NSMethodSignature *)methodSignatureForSelector:(SEL)aSelector {
    
    return [[_list class] instanceMethodSignatureForSelector:aSelector];
}

- (void)forwardInvocation:(NSInvocation *)anInvocation {
    
    NSMethodSignature *signature = [anInvocation valueForKey:@"_signature"];
    const char *returnType = signature.methodReturnType;
    NSLog(@"[%@ %@]", NSStringFromClass([anInvocation.target class]), NSStringFromSelector(anInvocation.selector));
    //    NSLog(@"%s", returnType);
    dispatch_block_t block = ^{
        [anInvocation invokeWithTarget:_list];
    };
    if (!strcmp(returnType, "v")) {
        // 没有返回值
        [self treadSafetyListPerformSelectorWithBlock:block];
    } else {
        // 有返回值
        [self treadSafetyListPerformSelectorWithBlock:block];
    }
}

- (void)treadSafetyListPerformSelectorWithBlock:(void (^)())block {
    if (self.synchronized) {
        dispatch_barrier_sync(_dispatchQueue, block);
    } else {
        dispatch_barrier_async(_dispatchQueue, block);
    }
}

- (BOOL)synchronized {
    return NO;
}

- (NSString *)description {
    return [_list description];
}

- (void)dealloc {
    _dispatchQueue = nil;
    _list = nil;
}

@end
