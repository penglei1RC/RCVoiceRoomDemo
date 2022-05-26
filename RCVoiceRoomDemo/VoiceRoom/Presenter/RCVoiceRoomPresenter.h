//
//  RCVoiceRoomPresenter.h
//  RCVoiceRoomDemo
//
//  Created by 彭蕾 on 2022/5/20.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface RCVoiceRoomPresenter : NSObject

@property (nonatomic, copy) NSString *roomId;
@property (nonatomic, copy) RCVoiceRoomInfo *roomInfo;
/// 当前用户是否已经上麦
@property (nonatomic, assign, getter=isOnTheSeat) BOOL onTheSeat;
/// 根据seatInfoDidUpdate 获取的最新麦位信息
@property (nonatomic, copy) NSArray<RCVoiceSeatInfo *> *seatlist;

/// 获取用户申请
- (void)fetchRequestListWithBlock:(void(^)(NSArray<UserModel *> *userList))completionBlock;

/// 根据传入的uids获取用户信息
- (void)fetchUserInfoListWithUids:(NSArray<NSString *> *)users
                  completionBlock:(void(^)(NSArray<UserModel *> *userList))completionBlock;
/// 获取用户列表
- (void)fetchRoomUserListWithBlock:(void(^)(NSArray<UserModel *> *userList))completionBlock;

#pragma mark - room manager 房间管理
/// 创建并加入房间
- (void)createAndJoinRoom;
/// 加入房间
- (void)joinRoom;
// 离开房间
- (void)leaveRoom;
/// 销毁房间
- (void)destroyRoomWithCompletionBlock:(void(^)(BOOL success))completionBlock;

- (void)updateRoomOnlineStatus;

#pragma mark - user manager 观众连麦
/// 主播踢用户出房间
- (void)kickUserFromRoom:(NSString *)uid;
/// 主播同意用户上麦
- (void)agreeUserFromRoom:(NSString *)uid;
/// 主播拒绝用户上麦
- (void)rejectUserFromRoom:(NSString *)uid;

/// 主播抱用户上麦
- (void)pickUserToSeat:(NSString *)uid;
/// 用户接受被抱麦
- (void)acceptPickUser;
/// 主播抱用户下麦
- (void)kickUserFromSeat:(NSString *)uid;

/**
 使用pickUserToSeat，以文档为主。
 sendInvitation方式需要被邀请者明确发同意或者拒绝响应。
 pickUserToSeat发给被邀请者后，被邀请者直接本地决定是否上麦，不用回复给邀请者。
 */
/// 主播邀请用户上麦 -- unused
- (void)inviteUserFromRoom:(NSString *)uid;
/// 用户接受主播上麦邀请 -- unused
- (void)acceptInvitation:(NSString *)uid seatIndex:(NSUInteger)seatIndex;
/// 用户拒绝主播上麦邀请 -- unused
- (void)rejectInvitation:(NSString *)uid;

#pragma mark - seat manager 麦位管理
/// 主动上麦
- (void)enterSeat:(NSUInteger)seatIndex;
/// 主动下麦
- (void)leaveSeat;
/// 主播换麦
- (void)switchSeatTo:(NSUInteger)seatIndex;
/// 用户发出上麦申请
- (void)requestSeat:(NSUInteger)seatIndex;
/// 用户取消上麦申请
- (void)cancelRequest;
/// 锁麦
- (void)lockSeat:(NSUInteger)seatIndex lock:(BOOL)isLocking;
/// 闭麦
- (void)muteSeat:(NSUInteger)seatIndex mute:(BOOL)isMute;

#pragma mark - room settings 房间控制
#pragma mark 聊天室属性（KV）相关控制操作
/// 全员锁麦 -- unused
- (void)lockAll:(BOOL)lock;
/// 全员闭麦 -- unused
- (void)muteAll:(BOOL)mute;
/// 锁空闲麦位
- (void)lockOthers:(BOOL)lock;
/// 闭麦除自己以外的其它麦位
- (void)muteOthers:(BOOL)mute;

#pragma mark 音视频房间（RTCRoom）相关控制操作
/// 禁止本地麦克风收音
- (void)micDisable:(BOOL)disable;
/// 是否使用扬声器
- (void)speakerEnable:(BOOL)enable;

/// 静音所有远程音频流
- (void)muteAllRemoteStreams:(BOOL)mute;
/// 设置房间音频质量和场景 --unused
- (void)setAudioQuality:(RCVoiceRoomAudioQuality)quality
               scenario:(RCVoiceRoomAudioScenario)scenario;

#pragma mark 房间内通知
- (void)notifyVoiceRoom:(NSString *)name
                content:(NSString *)content;
@end

NS_ASSUME_NONNULL_END
