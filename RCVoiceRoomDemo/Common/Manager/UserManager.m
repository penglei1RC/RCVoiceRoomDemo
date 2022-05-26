//
//  UserManager.m
//  RCVoiceRoomDemo
//
//  Created by 彭蕾 on 2022/5/23.
//

#import "UserManager.h"

@implementation UserManager

+ (UserManager *)sharedManager {
    static UserManager *_sharedManager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedManager = [self new];
    });

    return _sharedManager;
}

@end
