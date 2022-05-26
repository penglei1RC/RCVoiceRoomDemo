//
//  RCVoiceRoomPresenter+PK.h
//  RCVoiceRoomDemo
//
//  Created by 彭蕾 on 2022/5/24.
//

#import "RCVoiceRoomPresenter.h"
#import "RCOnlineCreatorModel.h"
#import "RCPKStatusModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface RCVoiceRoomPresenter (PK)

/// 获取在线主播
- (void)pk_fetchOnlineCreatorListWithBlock:(void(^)(NSArray<RCOnlineCreatorModel *> *creatorList))completionBlock;

/// 发起pk邀请
- (void)pk_sendPKInvitation:(NSString *)inviteeRoomId invitee:(NSString *)inviteeUserId;

/// 取消pk邀请
- (void)pk_cancelPKInvitation:(NSString *)inviteeRoomId invitee:(NSString *)inviteeUserId;

/// 响应pk邀请
- (void)pk_responsePKInvitation:(NSString *)inviterRoomId inviter:(NSString *)inviterUserId responseType:(RCPKResponseType)type;

/// 同步pk状态
- (void)pk_syncPKState:(NSInteger)status
              toRoomId:(NSString *)toRoomId
       completionBlock:(void(^)(BOOL success))completionBlock;

/// 退出pk连接
- (void)pk_quitPKCompletionBlock:(void(^)(BOOL success))completionBlock;

/// 获取pk的详细信息
- (void)pk_fetchPKDetailWithCompletionBlock:(void(^)(RCPKStatusModel * _Nullable statusModel))completionBlock;

/// 恢复pk
- (void)pk_resumePK:(RCVoicePKInfo *)info;

/// 静音PK对象的语音
- (void)pk_mutePKUser:(BOOL)isMute;

@end

NS_ASSUME_NONNULL_END
