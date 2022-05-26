//
//  RCVoiceRoomController+PK.h
//  RCVoiceRoomDemo
//
//  Created by 彭蕾 on 2022/5/24.
//

#import "RCVoiceRoomController.h"

NS_ASSUME_NONNULL_BEGIN

@interface RCVoiceRoomController (PK)

- (void)pk_loadPKModule;

/// 发起pk or 结束 pk
/// @param isInvite  发起pk/结束pk
- (void)pk_invite:(BOOL)isInvite;

/// 同步pk信息
- (void)pk_messageDidReceive:(nonnull RCMessage *)message;

@end

NS_ASSUME_NONNULL_END
