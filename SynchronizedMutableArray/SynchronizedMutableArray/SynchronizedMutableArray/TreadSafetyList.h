//
//  TreadSafetyList.h
//  SynchronizedMutableArray
//
//  Created by Ossey on 2017/6/25.
//  Copyright © 2017年 Ossey. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface TreadSafetyList : NSObject {
@protected
    id _list;
    dispatch_queue_t _dispatchQueue;
}

@property (nonatomic) id list;
@property (readonly) BOOL synchronized;

- (void)treadSafetyListPerformSelectorWithBlock:(void (^)())block;

@end
