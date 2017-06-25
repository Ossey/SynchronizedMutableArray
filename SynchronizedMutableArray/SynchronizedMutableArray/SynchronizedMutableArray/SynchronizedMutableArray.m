//
//  SynchronizedMutableArray.m
//  SynchronizedMutableArray
//
//  Created by Ossey on 2017/6/25.
//  Copyright © 2017年 Ossey. All rights reserved.
//

#import "SynchronizedMutableArray.h"

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

    [self treadSafetyListPerformSelectorWithBlock:^{
        count = [_list count];
    }];
    return count;
}

- (id)firstObject {
    __block id obj = nil;
    [self treadSafetyListPerformSelectorWithBlock:^{
        obj = [_list firstObject];
    }];
    return obj;
}

- (id)lastObject {
    __block id obj = nil;
    [self treadSafetyListPerformSelectorWithBlock:^{
        obj = [_list lastObject];
    }];
    return obj;
}


- (NSData *)sortedArrayHint {
    __block NSData *sortedArrayHint = nil;
    [self treadSafetyListPerformSelectorWithBlock:^{
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
    
    NSUInteger idx = [_list countByEnumeratingWithState:state objects:buffer count:len];
    return idx;
}

- (void)enumerateObjectsUsingBlock:(void (^)(id _Nonnull, NSUInteger, BOOL * _Nonnull))block {
    if (!block) return;
    [_list enumerateObjectsUsingBlock:block];
}

- (void)enumerateObjectsWithOptions:(NSEnumerationOptions)opts usingBlock:(void (^)(id _Nonnull, NSUInteger, BOOL * _Nonnull))block {
    if (!block) return;
    [_list enumerateObjectsWithOptions:opts usingBlock:block];
}

- (void)enumerateObjectsAtIndexes:(NSIndexSet *)s options:(NSEnumerationOptions)opts usingBlock:(void (^)(id _Nonnull, NSUInteger, BOOL * _Nonnull))block {
    if (!block) return;
    [_list enumerateObjectsAtIndexes:s options:opts usingBlock:block];
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
    [self treadSafetyListPerformSelectorWithBlock:^{
        array = [_list mutableCopy];
    }];
    return array;
}

- (BOOL)synchronized {
    return NO;
}

@end


@implementation NSArray (SynchronizedMutableArray)

- (SynchronizedMutableArray *)synchronizedMutableArray {
    return [SynchronizedMutableArray arrayWithArray:self];
}

@end
