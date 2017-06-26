//
//  TreadSafetyList.h
//  SynchronizedMutableArray
//
//  Created by Ossey on 2017/6/25.
//  Copyright © 2017年 Ossey. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface TreadSafetyList : NSObject {
    id _list;
    dispatch_queue_t _dispatchQueue;
}

@property (nonatomic) id list;
@property (readonly) BOOL synchronized;

/// 执行数组增删改查的队列
- (void)treadSafetyListPerformSelectorWithBlock:(dispatch_block_t)block;
/// 执行数组遍历的队列
- (void)treadSafetyListEnumerateWithBlock:(dispatch_block_t)block;

@end

NS_ASSUME_NONNULL_END
