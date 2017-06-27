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
            NSLog(@"%ld, %d, %d", i, __LINE__, [NSThread isMainThread]);
            NSNumber *idx = @(i);
            [_array1 addObject:idx];
        }
        
    }
    NSDate* Start = [NSDate date];
    _array2 = [_array1 mutableCopy];
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        [_array2 enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            NSLog(@"%ld, %d, %d", idx, __LINE__, [NSThread isMainThread]);
            [_array1 removeLastObject];
            
            
        }];
        // NSMutableArray: 2017-06-25 19:52:38.368 SynchronizedMutableArray[64944:586330] ＊＊＊＊＊＊cost time = 2.062732
        // SynchronizedMutableArray: SynchronizedMutableArray[64976:588536] ＊＊＊＊＊＊cost time = 4.450191
        double deltaTime = [[NSDate date] timeIntervalSinceDate:Start];
        NSLog(@"＊＊＊＊＊＊cost time = %f", deltaTime);
        
    });
    
    dispatch_async(dispatch_queue_create("123", DISPATCH_QUEUE_CONCURRENT), ^{
        [_array2 enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            NSLog(@"%ld, %d, %d", idx, __LINE__, [NSThread isMainThread]);
            [_array1 addObject:@(idx)];
            
            
        }];
    });
    
//    [_array2 enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
//        NSLog(@"%ld, %d, %d", idx, __LINE__, [NSThread isMainThread]);
//        [_array1 removeLastObject];
//        
//    }];
    
    
}

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
