//
//  SynchronizedMutableArray.m
//  SynchronizedMutableArray
//
//  Created by Ossey on 2017/6/25.
//  Copyright © 2017年 Ossey. All rights reserved.
//


#import "SynchronizedMutableArray.h"

/*
 * 通过OC的消息转发机制，实现一个同步执行的数组，将SynchronizedMutableArray中未实现的方法转发给NSMutableArray执行，且创建的对象会同步执行
 * 目的是为了防止多线程并发操作数组引发的crash，解决线程安全问题
 * 经测试此数组的操作速度是NSMutableArray的60%，非高并发操作，不建议使用
 */


#pragma clang diagnostic ignored "-Wobjc-property-implementation"
#pragma clang diagnostic ignored "-Wincomplete-implementatio"
#pragma clang diagnostic ignored "-Wprotocol"
#pragma clang diagnostic ignored "-Wincomplete-implementation"

@implementation SynchronizedMutableArray

#pragma mark *** initialize ***

- (instancetype)init
{
    self = [super init];
    if (self) {
        _list = [NSMutableArray array];
    }
    return self;
}

+ (instancetype)array {
    return [[self alloc] init];
}

- (instancetype)initWithCapacity:(NSUInteger)numItems {
    if (self = [super init]) {
        _list = [[NSMutableArray alloc] initWithCapacity:numItems];
    }
    return self;
}

+ (instancetype)arrayWithCapacity:(NSUInteger)numItems {
    return [[self alloc] initWithCapacity:numItems];
}


- (instancetype)initWithArray:(NSArray *)array {
    if (self = [self init]) {
        if (!array) {
            _list = [NSMutableArray array];
        } else {
            _list = [array mutableCopy];
        }
    }
    return self;
}
+ (instancetype)arrayWithArray:(NSArray *)array {
    return [[self alloc] initWithArray:array];
}

#pragma mark *** getter ***

- (NSUInteger)count {
    __block NSUInteger count = 0;
    
    [self performBlockOnTreadSafetyQueue:^{
        count = [_list count];
    }];
    return count;
}

- (id)firstObject {
    __block id obj = nil;
    [self performBlockOnTreadSafetyQueue:^{
        obj = [_list firstObject];
    }];
    return obj;
}

- (id)lastObject {
    __block id obj = nil;
    [self performBlockOnTreadSafetyQueue:^{
        obj = [_list lastObject];
    }];
    return obj;
}


- (NSData *)sortedArrayHint {
    __block NSData *sortedArrayHint = nil;
    [self performBlockOnTreadSafetyQueue:^{
        sortedArrayHint = [_list sortedArrayHint];
    }];
    return sortedArrayHint;
}


#pragma mark *** NSSecureCoding ***

+ (BOOL)supportsSecureCoding {
    return [NSMutableArray supportsSecureCoding];
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    if (self = [super init]) {
        _list = [aDecoder decodeObjectForKey:NSStringFromSelector(@selector(list))];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder {
    if (_list) {
        [aCoder encodeObject:_list forKey:NSStringFromSelector(@selector(array))];
    }
}

#pragma mark *** NSFastEnumeration ***

- (NSUInteger)countByEnumeratingWithState:(NSFastEnumerationState *)state objects:(id  _Nullable __unsafe_unretained [])buffer count:(NSUInteger)len {
    
    __block NSUInteger idx = 0;
    [self enumerateUsingBlockOnTreadSafetyQueue:^{
        idx = [_list countByEnumeratingWithState:state objects:buffer count:len];
    }];
    return idx;
}

- (void)enumerateObjectsUsingBlock:(void (^)(id _Nonnull, NSUInteger, BOOL * _Nonnull))block {
    if (!block) return;
    [self enumerateUsingBlockOnTreadSafetyQueue:^{
        [_list enumerateObjectsUsingBlock:block];
    }];
}

- (void)enumerateObjectsWithOptions:(NSEnumerationOptions)opts usingBlock:(void (^)(id _Nonnull, NSUInteger, BOOL * _Nonnull))block {
    if (!block) return;
    [self enumerateUsingBlockOnTreadSafetyQueue:^{
        [_list enumerateObjectsWithOptions:opts usingBlock:block];
    }];
}

- (void)enumerateObjectsAtIndexes:(NSIndexSet *)s options:(NSEnumerationOptions)opts usingBlock:(void (^)(id _Nonnull, NSUInteger, BOOL * _Nonnull))block {
    if (!block) return;
    [self enumerateUsingBlockOnTreadSafetyQueue:^{
        [_list enumerateObjectsAtIndexes:s options:opts usingBlock:block];
    }];
    
}

#pragma mark *** NSCopying, NSMutableCopying ***

- (id)copyWithZone:(NSZone *)zone {
    return self;
}

- (id)mutableCopyWithZone:(NSZone *)zone {
    SynchronizedMutableArray *obj = [SynchronizedMutableArray array];
    obj.list = [_list mutableCopy];
    return obj;
}


#pragma mark *** Other ***

- (NSMutableArray *)toNativeMutableArray {
    __block NSMutableArray *array = nil;
    [self performBlockOnTreadSafetyQueue:^{
        array = [_list mutableCopy];
    }];
    return array;
}

- (BOOL)synchronized {
    return YES;
}

@end


@implementation NSArray (SynchronizedMutableArray)

- (SynchronizedMutableArray *)synchronizedMutableArray {
    return [SynchronizedMutableArray arrayWithArray:self];
}

@end


@interface TreadSafetyQueue () {
    dispatch_semaphore_t _signal;
    NSThread *_signalThread;
}

@end

@implementation TreadSafetyQueue

- (instancetype)init
{
    self = [super init];
    if (self) {
        _synchronized = NO;
        _signal = dispatch_semaphore_create(1);
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
        [self enumerateUsingBlockOnTreadSafetyQueue:block];
    } else {  // 无返回值
        [self enumerateUsingBlockOnTreadSafetyQueue:block];
    }
}

- (void)performBlockOnTreadSafetyQueue:(dispatch_block_t)block {
    if (self.synchronized) {
        [self performSync:block];
    } else {
        block();
    }
}

/// 遍历操作时执行的block，经过各种并发和非并发操作同一数组时，使用dispatch_semaphore是最好的方案
/// 子线程使用dispatch_semaphore是最安全的，都会等待dispatch_semaphore_signal
/// 注意：当在主线程中使用dispatch_barrier_sync执行遍历操作，此时子线程也在执行遍历操作时，会造成线程死锁，引发crash
/// 虽然sync不会开启子线程，但是当其在子线程中执行时，还是会引发线程安全问题crash
- (void)enumerateUsingBlockOnTreadSafetyQueue:(dispatch_block_t)block {
    if (self.synchronized) {
        [self performSync:block];
    } else {
        block();
    }
}

- (void)performSync:(dispatch_block_t)block {
    if ([NSThread currentThread] == _signalThread) {
        block();
    }else{
        if ([NSThread isMainThread]) {
            block();
            return;
        }
        dispatch_semaphore_wait(_signal, DISPATCH_TIME_FOREVER);
        _signalThread = [NSThread currentThread];
        block();
        _signalThread = nil;
        dispatch_semaphore_signal(_signal);
    }
}

- (NSString *)description {
    return [_list description];
}

- (void)dealloc {
    _list = nil;
}

@end

