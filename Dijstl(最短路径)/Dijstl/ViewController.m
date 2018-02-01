//
//  ViewController.m
//  Dijstl
//
//  Created by LeoLai on 2018/1/31.
//  Copyright © 2018年 LeoLai. All rights reserved.
//

#import "ViewController.h"
#import "LWMap.h"

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    LWMap *map = [LWMap randomMap:1000];
    NSMutableArray *mArray = [map smallestDistinceFrom:0 to:990];
    NSLog(@"%@", mArray);
    
    // Do any additional setup after loading the view.
}




- (void)setRepresentedObject:(id)representedObject {
    [super setRepresentedObject:representedObject];

    // Update the view, if already loaded.
}


@end
