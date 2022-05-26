//
//  RCPKStatusMessage.m
//  RCVoiceRoomDemo
//
//  Created by 彭蕾 on 2022/5/25.
//

#import "RCPKStatusMessage.h"

@implementation RCPKStatusMessage

- (NSData *)encode {
    if (!_content) return nil;
    
    return [NSJSONSerialization dataWithJSONObject:[_content yy_modelToJSONObject] options:kNilOptions error:nil];
}

- (void)decodeWithData:(NSData *)data {
    if (data == nil) return;
    id json = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:nil];
    if (json == nil) return;
    _content = [RCPKStatusContent yy_modelWithJSON:json];
}

+ (NSString *)getObjectName {
    return @"RCMic:chrmPkStatusMsg";
}

- (NSArray<NSString *> *)getSearchableWords {
    return @[];
}

+ (RCMessagePersistent)persistentFlag {
    return MessagePersistent_NONE;
}

@end
