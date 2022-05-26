//
//  RCPKStatusMessage.h
//  RCVoiceRoomDemo
//
//  Created by 彭蕾 on 2022/5/25.
//

#import <RongIMLibCore/RongIMLibCore.h>
#import "RCPKStatusContent.h"

NS_ASSUME_NONNULL_BEGIN

@interface RCPKStatusMessage : RCMessageContent

@property (nonatomic, strong) RCPKStatusContent *content;

@end

NS_ASSUME_NONNULL_END
