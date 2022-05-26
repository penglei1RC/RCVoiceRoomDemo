//
//  RCPKStatusContent.m
//  RCVoiceRoomDemo
//
//  Created by 彭蕾 on 2022/5/25.
//

#import "RCPKStatusContent.h"

@implementation RCPKStatusContent

+ (NSDictionary *)modelContainerPropertyGenericClass {
    return @{@"roomScores" : [RCPKRoomScore class]};
}

@end

@implementation RCPKRoomScore

@end

