//
//  Map.m
//  Dijstl
//
//  Created by LeoLai on 2018/1/31.
//  Copyright © 2018年 LeoLai. All rights reserved.
//

#import "LWMap.h"

@interface LWPoint ()

@property (nonatomic, strong) NSString *name;
@property (nonatomic, strong) NSMutableSet<LWLine *> *lines;
@property (nonatomic, weak) LWPoint *prePoint;

@end

@interface LWMap ()

@property (nonatomic, strong) NSMutableArray<LWPoint *> *points;

@end

@implementation LWMap

+ (instancetype)randomMap:(NSInteger)pointNum {
    LWMap *randomMap = [[self alloc] init];
    for (NSInteger i = 0; i < pointNum; i++) {
        LWPoint *point = [[LWPoint alloc] initWithName:[NSString stringWithFormat:@"p_%ld", i]];
        [randomMap addPoint:point];
    }
    
    for (int i = 0; i < pointNum; i++) {
        for (int j = 0; j < 2; j++) {
            NSInteger randomEnd = (arc4random() % 3 + 1) + i;
            NSInteger randomStart = i;
            
            if (randomEnd >= randomMap.points.count) {
                randomEnd = randomMap.points.count - 1;
            }
            if (randomEnd == randomStart) {
                continue;
            }
            LWPoint *startP = randomMap->_points[randomStart];
            LWPoint *endP = randomMap->_points[randomEnd];
            NSInteger width = arc4random() % 99 + 1;
            LWLine *line = [[LWLine alloc] initWithStartPoint:startP endPoint:endP width:width];
            LWLine *line2 = [[LWLine alloc] initWithStartPoint:endP endPoint:startP width:width];
            [startP addLine:line];
            [endP addLine:line2];
        }
    }
    
    return randomMap;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        self.points = [[NSMutableArray alloc] init];
    }
    return self;
}

- (void)addPoint:(LWPoint *)point {
    NSParameterAssert(point != nil);
    [self.points addObject:point];
}

- (NSMutableArray <LWPoint *> *)smallestDistinceFrom:(NSInteger)from to:(NSInteger)to {
    NSParameterAssert(from < self.points.count);
    NSParameterAssert(to < self.points.count);
    return [self djstlFromPoint:self.points[from] to:self.points[to]];
}


/**
 a.初始时，S只包含源点，即S＝{v}，v的距离为0。U包含除v外的其他顶点，即:U={其余顶点}，若v与U中顶点u有边，则<u,v>正常有权值，若u不是v的出边邻接点，则<u,v>权值为∞。
 
 b.从U中选取一个距离v最小的顶点k，把k，加入S中（该选定的距离就是v到k的最短路径长度）。
 
 c.以k为新考虑的中间点，修改U中各顶点的距离；若从源点v到顶点u的距离（经过顶点k）比原来距离（不经过顶点k）短，则修改顶点u的距离值，修改后的距离值的顶点k的距离加上边上的权。
 
 d.重复步骤b和c直到所有顶点都包含在S中。
 */
- (NSMutableArray <LWPoint *> *)djstlFromPoint:(LWPoint *)fromPoint to:(LWPoint *)toPoint {
    
    //存放距离，到达不了的用NSIntegerMax表示
    NSMutableArray<NSNumber *> *dist = [NSMutableArray arrayWithCapacity:self.points.count];
    //已经找到最优路径的点
    NSMutableSet<LWPoint *> *set = [NSMutableSet set];
    //未找到最优路径的点
    NSMutableSet<LWPoint *> *unSet = [NSMutableSet setWithArray:self.points];
    NSParameterAssert([unSet containsObject:fromPoint]);
    NSParameterAssert([unSet containsObject:toPoint]);
    //初始化dist 步骤a
    for (NSInteger i = 0; i < self.points.count; i++) {
        if (i == [self.points indexOfObject:fromPoint]) {
            [dist addObject:@(0)];
        } else {
            [dist addObject:@(NSIntegerMax)];
        }
    }
    
    NSInteger distinction = 0;
    LWPoint *currentPoint = nil;
    //步骤d
    while ([unSet containsObject:toPoint] && unSet.count > 0) {
        __block NSInteger min = NSIntegerMax;
        //当前最小距离的点
        __block LWPoint *minPoint = nil;
        //查找dist当中，当前最小的值 步骤b
        [dist enumerateObjectsUsingBlock:^(NSNumber * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            LWPoint *currentTempPoint = self.points[idx];
            if (obj.integerValue <= min && obj.integerValue >= distinction && [unSet containsObject:currentTempPoint]) {
                min = obj.integerValue;
                minPoint = currentTempPoint;
            }
        }];
        if (minPoint) {
            currentPoint = minPoint;
            distinction = min;
            //步骤c
            [self unSetRemovePoint:currentPoint unSet:unSet set:set dist:dist currentDist:distinction];
        }
    }
    
    // 获取路径
    NSMutableArray *ret = [[NSMutableArray alloc] init];
    LWPoint *tempToPoint = toPoint;
    [ret addObject:tempToPoint];
    while (tempToPoint.prePoint) {
        [ret addObject:tempToPoint.prePoint];
        tempToPoint = tempToPoint.prePoint;
    }
    NSLog(@"%@", ret);
    return [ret copy];
    
}

- (void)unSetRemovePoint:(LWPoint *)point unSet:(NSMutableSet<LWPoint *> *)unSet set:(NSMutableSet<LWPoint *> *)set dist:(NSMutableArray<NSNumber *> *)dist currentDist:(NSInteger)distinction {
    [unSet removeObject:point];
    [set addObject:point];
    // 更新路径
    for (LWLine *line in point.lines) {
        NSInteger index = [self.points indexOfObject:line.endPoint];
        NSNumber *currentDist = dist[index];
        NSInteger temp = distinction + line.width;
        // 防止溢出
        if (temp < 0) {
            temp = NSIntegerMax;
        }
        if (temp < currentDist.integerValue) {
            dist[index] = @(temp);
            line.endPoint.prePoint = line.starPoint;
        }
    }
}

- (NSString *)description {
    NSMutableString *mStr = [[NSMutableString alloc] init];
    for (LWPoint *point in self.points) {
        [mStr appendFormat:@"%@\n", point];
    }
    return mStr;
}

@end

@implementation LWPoint

- (instancetype)initWithName:(NSString *)name {
    self = [super init];
    if (self) {
        self.name = name;
        self.lines = [NSMutableSet set];
    }
    return self;
}

- (id)copyWithZone:(nullable NSZone *)zone {
    LWPoint *point = [[self.class alloc] initWithName:self.name];
    point.lines = self.lines;
    return point;
}

- (void)addLine:(LWLine *)line {
    NSParameterAssert(line.starPoint == self);
    for (LWLine *tempLine in self.lines) {
        if (tempLine.endPoint == line.endPoint) {
            return;
        }
    }
    [self.lines addObject:line];
}

- (NSString *)description {
    NSMutableString *mStr = [[NSMutableString alloc] init];
    [mStr appendFormat:@"point %@\n", self.name];
    for (LWLine *line in self.lines) {
        [mStr appendFormat:@"----> %@ %.2f\n", line.endPoint.name, line.width];
    }
    return mStr;
}

@end

@interface LWLine ()

@property (nonatomic, weak) LWPoint *starPoint;
@property (nonatomic, weak) LWPoint *endPoint;

@end

@implementation LWLine

- (instancetype)initWithStartPoint:(LWPoint *)startPoint endPoint:(LWPoint *)endPoint width:(CGFloat)width {
    self = [super init];
    if (self) {
        self.starPoint = startPoint;
        self.endPoint = endPoint;
        self.width = width;
    }
    return self;
}

@end
