//
//  ViewController.m
//  SynchronizedMutableArray
//
//  Created by Ossey on 2017/6/25.
//  Copyright © 2017年 Ossey. All rights reserved.
//

#import "ViewController.h"
#import "SynchronizedMutableArray.h"
#import "SuspensionControl.h"

@interface ViewController () <SuspensionMenuViewDelegate>
{
    SynchronizedMutableArray *_array1;
    SynchronizedMutableArray *_array2;
}

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    [self showSuspensionView];
}


- (void)testSynchronizedMutableArray {
    _array1 = [SynchronizedMutableArray array];
    for (NSInteger i = 0; i < 100000; ++i) {
        @autoreleasepool {
            NSLog(@"+%ld, %d, %d", i, __LINE__, [NSThread isMainThread]);
            NSNumber *idx = @(i);
            [_array1 addObject:idx];
        }
        
    }
    NSDate* Start = [NSDate date];
    _array2 = [_array1 mutableCopy];
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        [_array2 enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            NSLog(@"%-ld, %d, %d", idx, __LINE__, [NSThread isMainThread]);
            [_array1 removeLastObject];
            
            
        }];
        // NSMutableArray: 2017-06-25 19:52:38.368 SynchronizedMutableArray[64944:586330] ＊＊＊＊＊＊cost time = 2.062732
        // SynchronizedMutableArray: SynchronizedMutableArray[64976:588536] ＊＊＊＊＊＊cost time = 4.450191
        double deltaTime = [[NSDate date] timeIntervalSinceDate:Start];
        NSLog(@"＊＊＊＊＊＊cost time = %f", deltaTime);
        
    });
    
    dispatch_async(dispatch_queue_create("123", DISPATCH_QUEUE_CONCURRENT), ^{
        [_array2 enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            NSLog(@"+%ld, %d, %d", idx, __LINE__, [NSThread isMainThread]);
            [_array1 addObject:@(idx)];
            
            
        }];
    });

    [_array2 enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        NSLog(@"-%ld, %d, %d", idx, __LINE__, [NSThread isMainThread]);
        [_array1 removeLastObject];
        
    }];
    
}

- (void)test1 {
    // 这样在同一个同步队列中遍历数组，又对数组进行增删改查的操作，会造成死锁的，当然如果不在同一个队列(非主队列)中执行就不会造成死锁的
    NSMutableArray *array0 = [NSMutableArray arrayWithObjects:@"1", @"2", @"3", @"4", @"5", nil];
    dispatch_queue_t syncQueue = dispatch_queue_create("sync", NULL);
    dispatch_sync(syncQueue, ^{
        [array0 enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            dispatch_sync(syncQueue, ^{
                [array0 replaceObjectAtIndex:idx withObject:@(idx)];
            });
        }];
    });

}

////////////////////////////////////////////////////////////////////////
#pragma mark - GCD Demo
////////////////////////////////////////////////////////////////////////

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
//    [self testSyncGCD];
//    [self testAsyncGCD];
    [self testGCDSpecific];
}


/// 在主线程中获取当前线程和当前队列
- (void)testSyncGCD {
   
    dispatch_queue_t queue = dispatch_queue_create("queue", NULL);
    dispatch_sync(queue, ^{
        NSLog(@"currentThread: %@\n currentQueue: %@",[NSThread currentThread], dispatch_get_current_queue());
    });
  
}

/// 在子线程中获取当前线程和当前队列
- (void)testAsyncGCD {
    dispatch_queue_t queue = dispatch_queue_create("queue1", DISPATCH_QUEUE_CONCURRENT);
    dispatch_async(queue, ^{
        NSLog(@"currentThread: %@\n currentQueue: %@",[NSThread currentThread], dispatch_get_current_queue());
    });
    
}


/// 给队列标记，通过标记获取队列，执行任务，解决线程安全问题
- (void)testGCDSpecific {
    dispatch_queue_t queue = dispatch_queue_create("specific", DISPATCH_QUEUE_CONCURRENT);
    void *queueSpecificKey = &queueSpecificKey;
    void *queueContext = (__bridge void *)self;
    // 使用dispatch_queue_set_specific 标记队列
    dispatch_queue_set_specific(queue, queueSpecificKey, queueContext, NULL);
    
    dispatch_async(queue, ^{
        dispatch_block_t block = ^{
            NSLog(@"currentThread: %@\n ",[NSThread currentThread]);
        };
        
        // dispatch_get_specific就是在当前队列中取出标识,如果是在当前队列就执行，非当前队列，就同步执行，防止死锁
        if (dispatch_get_specific(queueSpecificKey)) {
            block();
        } else {
            dispatch_sync(queue, block);
        }
    });
    
}

////////////////////////////////////////////////////////////////////////
#pragma mark -
////////////////////////////////////////////////////////////////////////



- (void)showSuspensionView {
    
    
    
    SuspensionMenuWindow *menuView = [[SuspensionMenuWindow alloc] initWithFrame:CGRectMake(0, 0, 300, 300)];
    menuView.isOnce = YES;
    menuView.shouldShowWhenViewWillAppear = NO;
    menuView.shouldHiddenCenterButtonWhenShow = YES;
    menuView.shouldDismissWhenDeviceOrientationDidChange = YES;
    MenuBarHypotenuseItem *item = [[MenuBarHypotenuseItem alloc] initWithButtonType:OSButtonType1];
    [item.hypotenuseButton setTitle:NSStringFromSelector(@selector(testSynchronizedMutableArray)) forState:UIControlStateNormal];
    [menuView setMenuBarItems:@[item] itemSize:CGSizeMake(50, 50)];
    menuView.delegate = self;
    
    UIImage *image = [UIImage imageNamed:@"mm.jpg"];
    menuView.backgroundImageView.image = image;
    [menuView.centerButton setImage:[UIImage imageNamed:@"aws-icon"] forState:UIControlStateNormal];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

////////////////////////////////////////////////////////////////////////
#pragma mark - SuspensionMenuViewDelegate
////////////////////////////////////////////////////////////////////////


- (void)suspensionMenuView:(SuspensionMenuView *)suspensionMenuView clickedHypotenuseButtonAtIndex:(NSInteger)buttonIndex {
 
    if (buttonIndex == 0) {
        [self testSynchronizedMutableArray];
    }
}


@end
