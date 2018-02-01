//
//  Map.h
//  Dijstl
//
//  Created by LeoLai on 2018/1/31.
//  Copyright © 2018年 LeoLai. All rights reserved.
//

#import <Foundation/Foundation.h>
@class LWPoint;
@class LWLine;

@interface LWMap : NSObject

@property (nonatomic, strong, readonly) NSMutableArray<LWPoint *> *points;
+ (instancetype)randomMap:(NSInteger)pointNum;
- (void)addPoint:(LWPoint *)point;
- (NSMutableArray <LWPoint *> *)smallestDistinceFrom:(NSInteger)from to:(NSInteger)to;

@end

@interface LWPoint : NSObject <NSCopying>

@property (nonatomic, strong, readonly) NSString *name;
@property (nonatomic, strong, readonly) NSMutableSet<LWLine *> *lines;
- (instancetype)initWithName:(NSString *)name;
- (void)addLine:(LWLine *)line;



@end

@interface LWLine : NSObject

- (instancetype)initWithStartPoint:(LWPoint *)startPoint endPoint:(LWPoint *)endPoint width:(CGFloat)width;

@property (nonatomic, weak, readonly) LWPoint *starPoint;
@property (nonatomic, weak, readonly) LWPoint *endPoint;
@property (nonatomic, assign) CGFloat width;

@end
