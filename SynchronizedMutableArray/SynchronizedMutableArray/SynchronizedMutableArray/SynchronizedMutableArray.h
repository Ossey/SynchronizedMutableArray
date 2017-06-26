//
//  SynchronizedMutableArray.h
//  SynchronizedMutableArray
//
//  Created by Ossey on 2017/6/25.
//  Copyright © 2017年 Ossey. All rights reserved.
//

#import "TreadSafetyList.h"

NS_ASSUME_NONNULL_BEGIN


@interface SynchronizedMutableArray<__covariant ObjectType>  : TreadSafetyList<NSCopying, NSMutableCopying, NSFastEnumeration, NSSecureCoding>

@property (readonly) NSUInteger count;

- (ObjectType)objectAtIndex:(NSUInteger)index;
- (void)addObject:(ObjectType)anObject;
/// 在指定索引处插入一个元素，原来的元素后移
- (void)insertObject:(ObjectType)anObject atIndex:(NSUInteger)index;
- (void)removeLastObject;
/// 删除对应索引位置/范围的元素（索引/范围必须有效
- (void)removeObjectAtIndex:(NSUInteger)index;
/// 替换对应索引位置的元素（索引必须有效
- (void)replaceObjectAtIndex:(NSUInteger)index withObject:(ObjectType)anObject;
- (instancetype)init NS_DESIGNATED_INITIALIZER;
- (instancetype)initWithCapacity:(NSUInteger)numItems NS_DESIGNATED_INITIALIZER;
- (nullable instancetype)initWithCoder:(NSCoder *)aDecoder NS_DESIGNATED_INITIALIZER;
+ (instancetype)arrayWithCapacity:(NSUInteger)numItems;
- (NSMutableArray *)toNativeMutableArray;

@end

@interface SynchronizedMutableArray<ObjectType> (ExtendedArray)

/// 在当前数组追加元素或数组，并返回新数组对象
- (NSArray<ObjectType> *)arrayByAddingObject:(ObjectType)anObject;
- (NSArray<ObjectType> *)arrayByAddingObjectsFromArray:(NSArray<ObjectType> *)otherArray;
- (NSString *)componentsJoinedByString:(NSString *)separator;
/// 方法用于按值搜索查询数组是否包含某个元素，用于一些预判防止重复 addObject 的场合
- (BOOL)containsObject:(ObjectType)anObject;
@property (readonly, copy) NSString *description;
- (NSString *)descriptionWithLocale:(nullable id)locale;
- (NSString *)descriptionWithLocale:(nullable id)locale indent:(NSUInteger)level;
/// 查找与给定数组中第一个相同的对象（按值）
- (nullable ObjectType)firstObjectCommonWithArray:(NSArray<ObjectType> *)otherArray;
- (NSUInteger)indexOfObject:(ObjectType)anObject;
- (NSUInteger)indexOfObject:(ObjectType)anObject inRange:(NSRange)range;
- (NSUInteger)indexOfObjectIdenticalTo:(ObjectType)anObject;
- (NSUInteger)indexOfObjectIdenticalTo:(ObjectType)anObject inRange:(NSRange)range;
- (BOOL)isEqualToArray:(NSArray<ObjectType> *)otherArray;
@property (nullable, nonatomic, readonly) ObjectType firstObject NS_AVAILABLE(10_6, 4_0);
@property (nullable, nonatomic, readonly) ObjectType lastObject;
- (NSEnumerator<ObjectType> *)objectEnumerator;
- (NSEnumerator<ObjectType> *)reverseObjectEnumerator;
@property (readonly, copy) NSData *sortedArrayHint;
- (NSArray<ObjectType> *)sortedArrayUsingFunction:(NSInteger (NS_NOESCAPE *)(ObjectType, ObjectType, void * _Nullable))comparator context:(nullable void *)context;
- (NSArray<ObjectType> *)sortedArrayUsingFunction:(NSInteger (NS_NOESCAPE *)(ObjectType, ObjectType, void * _Nullable))comparator context:(nullable void *)context hint:(nullable NSData *)hint;
- (NSArray<ObjectType> *)sortedArrayUsingSelector:(SEL)comparator;
/// 返回指定范围（起始索引、长度）的子数组
- (NSArray<ObjectType> *)subarrayWithRange:(NSRange)range;
- (BOOL)writeToFile:(NSString *)path atomically:(BOOL)useAuxiliaryFile;
- (BOOL)writeToURL:(NSURL *)url atomically:(BOOL)atomically;

- (void)makeObjectsPerformSelector:(SEL)aSelector NS_SWIFT_UNAVAILABLE("Use enumerateObjectsUsingBlock: or a for loop instead");
- (void)makeObjectsPerformSelector:(SEL)aSelector withObject:(nullable id)argument NS_SWIFT_UNAVAILABLE("Use enumerateObjectsUsingBlock: or a for loop instead");
/*
 返回数组指定索引集的元素组成的子数组
 实例: 以下代码获取第2、4、6个元素子数组：
 NSMutableIndexSet* indexSet = [NSMutableIndexSet indexSet];
 [indexSet addIndex:1];
 [indexSet addIndex:3];
 [indexSet addIndex:5];
 NSArray* subArray = [array objectsAtIndexes:indexSet];
 NSLog(@"subArray= %@", subArray);
 等效于：
 NSArray* subArray = [NSArray arrayWithObjects:[array objectAtIndex:1], [array objectAtIndex:3], [array objectAtIndex:5], nil nil];
 
 NSArray* subArray = [NSArray arrayWithObjects:array[1], array[3], array[5], nil nil];
 简化字面量语法
 NSArray* subArray = @[array[1], array[3], array[5]];
 */
- (NSArray<ObjectType> *)objectsAtIndexes:(NSIndexSet *)indexes;
/// operator []：相当于中括号下标访问格式（array[index]），返回指定索引元素。等效于 objectAtIndex。
/// Returns the object at the specified index.
- (ObjectType)objectAtIndexedSubscript:(NSUInteger)idx NS_AVAILABLE(10_8, 6_0);

- (void)enumerateObjectsUsingBlock:(void (NS_NOESCAPE ^)(ObjectType obj, NSUInteger idx, BOOL *stop))block NS_AVAILABLE(10_6, 4_0);
- (void)enumerateObjectsWithOptions:(NSEnumerationOptions)opts usingBlock:(void (NS_NOESCAPE ^)(ObjectType obj, NSUInteger idx, BOOL *stop))block NS_AVAILABLE(10_6, 4_0);
- (void)enumerateObjectsAtIndexes:(NSIndexSet *)s options:(NSEnumerationOptions)opts usingBlock:(void (NS_NOESCAPE ^)(ObjectType obj, NSUInteger idx, BOOL *stop))block NS_AVAILABLE(10_6, 4_0);

/// 查找数组中第一个符合条件的对象（代码块过滤），返回对应索引, 找不到就返回NSNotFound
- (NSUInteger)indexOfObjectPassingTest:(BOOL (NS_NOESCAPE ^)(ObjectType obj, NSUInteger idx, BOOL *stop))predicate NS_AVAILABLE(10_6, 4_0);
- (NSUInteger)indexOfObjectWithOptions:(NSEnumerationOptions)opts passingTest:(BOOL (NS_NOESCAPE ^)(ObjectType obj, NSUInteger idx, BOOL *stop))predicate NS_AVAILABLE(10_6, 4_0);
- (NSUInteger)indexOfObjectAtIndexes:(NSIndexSet *)s options:(NSEnumerationOptions)opts passingTest:(BOOL (NS_NOESCAPE^)(ObjectType obj, NSUInteger idx, BOOL *stop))predicate NS_AVAILABLE(10_6, 4_0);
/// 查找数组中所有符合条件的对象（代码块过滤），返回对应索引集合, 默认是顺序同步遍历, 找不到就无返回
- (NSIndexSet *)indexesOfObjectsPassingTest:(BOOL (NS_NOESCAPE ^)(ObjectType obj, NSUInteger idx, BOOL *stop))predicate NS_AVAILABLE(10_6, 4_0);

- (NSIndexSet *)indexesOfObjectsWithOptions:(NSEnumerationOptions)opts passingTest:(BOOL (NS_NOESCAPE ^)(ObjectType obj, NSUInteger idx, BOOL *stop))predicate NS_AVAILABLE(10_6, 4_0);
- (NSIndexSet *)indexesOfObjectsAtIndexes:(NSIndexSet *)s options:(NSEnumerationOptions)opts passingTest:(BOOL (NS_NOESCAPE ^)(ObjectType obj, NSUInteger idx, BOOL *stop))predicate NS_AVAILABLE(10_6, 4_0);

- (NSArray<ObjectType> *)sortedArrayUsingComparator:(NSComparator NS_NOESCAPE)cmptr NS_AVAILABLE(10_6, 4_0);
- (NSArray<ObjectType> *)sortedArrayWithOptions:(NSSortOptions)opts usingComparator:(NSComparator NS_NOESCAPE)cmptr NS_AVAILABLE(10_6, 4_0);


- (NSUInteger)indexOfObject:(ObjectType)obj inSortedRange:(NSRange)r options:(NSBinarySearchingOptions)opts usingComparator:(NSComparator NS_NOESCAPE)cmp NS_AVAILABLE(10_6, 4_0); // binary search

@end

@interface SynchronizedMutableArray<ObjectType> (ArrayCreation)

+ (instancetype)array;
+ (instancetype)arrayWithArray:(NSArray<ObjectType> *)array;
- (instancetype)initWithArray:(NSArray<ObjectType> *)array;


@end


@interface SynchronizedMutableArray<ObjectType> (ExtendedMutableArray)

- (void)addObjectsFromArray:(NSArray<ObjectType> *)otherArray;
/// 交换对应索引位置的元素（索引必须有效）
- (void)exchangeObjectAtIndex:(NSUInteger)idx1 withObjectAtIndex:(NSUInteger)idx2;
- (void)removeAllObjects;
- (void)removeObject:(ObjectType)anObject inRange:(NSRange)range;
- (void)removeObject:(ObjectType)anObject;
- (void)removeObjectIdenticalTo:(ObjectType)anObject inRange:(NSRange)range;
- (void)removeObjectIdenticalTo:(ObjectType)anObject;
- (void)removeObjectsFromIndices:(NSUInteger *)indices numIndices:(NSUInteger)cnt NS_DEPRECATED(10_0, 10_6, 2_0, 4_0);
- (void)removeObjectsInArray:(NSArray<ObjectType> *)otherArray;
- (void)removeObjectsInRange:(NSRange)range;
- (void)replaceObjectsInRange:(NSRange)range withObjectsFromArray:(NSArray<ObjectType> *)otherArray range:(NSRange)otherRange;
- (void)replaceObjectsInRange:(NSRange)range withObjectsFromArray:(NSArray<ObjectType> *)otherArray;
/// 等效于先removeAllObjects后addObjectsFromArray
- (void)setArray:(NSArray<ObjectType> *)otherArray;
- (void)sortUsingFunction:(NSInteger (NS_NOESCAPE *)(ObjectType,  ObjectType, void * _Nullable))compare context:(nullable void *)context;
- (void)sortUsingSelector:(SEL)comparator;

/// 在指定索引集合处插入一个数组元素，相当于批次insertObject: atIndex:
- (void)insertObjects:(NSArray<ObjectType> *)objects atIndexes:(NSIndexSet *)indexes;
- (void)removeObjectsAtIndexes:(NSIndexSet *)indexes;
/// 替换对应索引集合位置的元素，相当于批次replaceObjectAtIndex: withObject:
- (void)replaceObjectsAtIndexes:(NSIndexSet *)indexes withObjects:(NSArray<ObjectType> *)objects;

/// 等效于replaceObjectAtIndex，支持中括号下标格式（array[index]）赋值替换。
/// index取值范围=[0, count]，index=count时相当于addObject
- (void)setObject:(ObjectType)obj atIndexedSubscript:(NSUInteger)idx NS_AVAILABLE(10_8, 6_0);

- (void)sortUsingComparator:(NSComparator NS_NOESCAPE)cmptr NS_AVAILABLE(10_6, 4_0);
- (void)sortWithOptions:(NSSortOptions)opts usingComparator:(NSComparator NS_NOESCAPE)cmptr NS_AVAILABLE(10_6, 4_0);

@end



@interface NSArray (SynchronizedMutableArray)

- (SynchronizedMutableArray *)synchronizedMutableArray;

@end

NS_ASSUME_NONNULL_END
