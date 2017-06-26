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
@property (nonatomic, strong) dispatch_queue_t enumerateQueue;

@end

@implementation TreadSafetyList
- (instancetype)init
{
    self = [super init];
    if (self) {
        _dispatchQueue = dispatch_queue_create("com.boobuz.TreadSafetyList", NULL);
        _enumerateQueue = dispatch_queue_create("com.boobuz.TreadSafetyList.asyncQueue", NULL);
        _synchronized = NO;
    }
    return self;
}


#pragma mark *** 消息转发 ***
/*
 在给程序添加消息转发功能以前，必须覆盖下面两个方法：
 即methodSignatureForSelector:和forwardInvocation:
 */

/// 另_list的类实现的消息创建一个有效的方法签名，并且返回不为空的methodSignature，否则会crash
- (NSMethodSignature *)methodSignatureForSelector:(SEL)aSelector {
    
    return [[_list class] instanceMethodSignatureForSelector:aSelector];
}

/// 将选择器转发给_list对象
- (void)forwardInvocation:(NSInvocation *)anInvocation {
    
    NSMethodSignature *signature = [anInvocation valueForKey:@"_signature"];
    const char *returnType = signature.methodReturnType;
    dispatch_block_t block = ^{
        [anInvocation invokeWithTarget:_list];
    };
    if (!strcmp(returnType, "v")) { // 有返回值
        [self treadSafetyListPerformSelectorWithBlock:block];
    } else {  // 无返回值
        [self treadSafetyListPerformSelectorWithBlock:block];
    }
}

- (void)treadSafetyListPerformSelectorWithBlock:(dispatch_block_t)block {
    if (self.synchronized) {
        dispatch_barrier_sync(_dispatchQueue, block);
    } else {
        dispatch_barrier_async(_dispatchQueue, block);
    }
}

- (void)treadSafetyListEnumerateWithBlock:(dispatch_block_t)block {
    if (self.synchronized) {
        dispatch_barrier_sync(_enumerateQueue, block);
    } else {
        dispatch_barrier_async(_enumerateQueue, block);
    }
}

- (NSString *)description {
    return [_list description];
}

- (void)dealloc {
    _dispatchQueue = nil;
    _enumerateQueue = nil;
    _list = nil;
}

@end
