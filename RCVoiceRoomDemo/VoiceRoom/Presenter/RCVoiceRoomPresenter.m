//
//  RCVoiceRoomPresenter.m
//  RCVoiceRoomDemo
//
//  Created by 彭蕾 on 2022/5/20.
//

#import "RCVoiceRoomPresenter.h"

@interface RCVoiceRoomPresenter ()

@end

@implementation RCVoiceRoomPresenter

- (void)fetchRequestListWithBlock:(void(^)(NSArray<UserModel *> *userList))completionBlock {
    // 先获取当前排麦的用户列表
    [[RCVoiceRoomEngine sharedInstance] getRequestSeatUserIds:^(NSArray<NSString *> * _Nonnull users) {
        Log(@"获取用户申请成功");
        if (!users || users.count == 0) {
            !completionBlock ?: completionBlock(nil);
            [SVProgressHUD showErrorWithStatus:@"用户信息为空"];
            return ;
        }
        
        [self fetchUserInfoListWithUids:users completionBlock:completionBlock];
        
    } error:^(RCVoiceRoomErrorCode code, NSString * _Nonnull msg) {
        !completionBlock ?: completionBlock(nil);
        [SVProgressHUD showErrorWithStatus:[NSString stringWithFormat:@"获取用户申请失败 code: %ld",code]];
    }];
}

- (void)fetchUserInfoListWithUids:(NSArray<NSString *> *)users completionBlock:(void(^)(NSArray<UserModel *> *userList))completionBlock {
    [WebService fetchUserInfoListWithUids:users responseClass:[UserModel class] success:^(id  _Nullable responseObject) {
        Log(@"获取用户信息成功");
        RCResponseModel *res = (RCResponseModel *)responseObject;
        if (res.code.integerValue == StatusCodeSuccess) {
            NSArray<UserModel *> *userInfoArr = (NSArray<UserModel *> *)res.data;
            !completionBlock ?: completionBlock(userInfoArr);
        }
    } failure:^(NSError * _Nonnull error) {
        [SVProgressHUD showErrorWithStatus:[NSString stringWithFormat:@"获取用户申请失败 code: %ld",error.code]];
    }];
}

- (void)fetchRoomUserListWithBlock:(void(^)(NSArray<UserModel *> *userList))completionBlock {
    [WebService roomUserListWithRoomId:self.roomId responseClass:[UserModel class]
                               success:^(id  _Nullable responseObject) {
        Log(@"获取用户信息成功");
        RCResponseModel *res = (RCResponseModel *)responseObject;
        if (res.code.integerValue == StatusCodeSuccess) {
            NSArray<UserModel *> *userInfoArr = (NSArray<UserModel *> *)res.data;
            !completionBlock ?: completionBlock(userInfoArr);
        } else {
            [SVProgressHUD showErrorWithStatus:[NSString stringWithFormat:@"获取用户列表失败 code: %@",res.code]];
        }
    } failure:^(NSError * _Nonnull error) {
        [SVProgressHUD showErrorWithStatus:[NSString stringWithFormat:@"获取用户列表失败 code: %ld",error.code]];
    }];
}

#pragma mark - room manager
// 创建&加入房间
- (void)createAndJoinRoom {
    [[RCVoiceRoomEngine sharedInstance] createAndJoinRoom:self.roomId room:self.roomInfo success:^{
        dispatch_async(dispatch_get_main_queue(), ^{
            [SVProgressHUD showSuccessWithStatus:@"创建成功"];
        });
    } error:^(RCVoiceRoomErrorCode code, NSString * _Nonnull msg) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [SVProgressHUD showSuccessWithStatus:@"创建失败"];
        });
    }];
}

- (void)joinRoom {
    [[RCVoiceRoomEngine sharedInstance] joinRoom:self.roomId success:^{
        dispatch_async(dispatch_get_main_queue(), ^{
            [SVProgressHUD showSuccessWithStatus:@"加入房间成功"];
        });
    } error:^(RCVoiceRoomErrorCode code, NSString * _Nonnull msg) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [SVProgressHUD showSuccessWithStatus:@"加入房间失败"];
        });
    }];
}

// 离开房间
// 内部会先将主播下麦。如果主播此时正在麦位上，会自动下麦。
// iOS 目前的回调在子线程，因此如需处理 UI 相关的操作，需要回到主线程。
- (void)leaveRoom {
    [[RCVoiceRoomEngine sharedInstance] leaveRoom:^{
        dispatch_async(dispatch_get_main_queue(), ^{
            [SVProgressHUD showSuccessWithStatus:@"离开房间成功"];
        });
    } error:^(RCVoiceRoomErrorCode code, NSString * _Nonnull msg) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [SVProgressHUD showErrorWithStatus:[NSString stringWithFormat:@"离开房间失败 code: %ld",(long)code]];
        });
    }];
}

- (void)destroyRoomWithCompletionBlock:(void(^)(BOOL success))completionBlock {
    [WebService deleteRoomWithRoomId:self.roomId success:^(id  _Nullable responseObject) {
        [self leaveRoom];
        !completionBlock ?: completionBlock(YES);
    } failure:^(NSError * _Nonnull error) {
        [SVProgressHUD showErrorWithStatus:[NSString stringWithFormat:@"离开房间失败 code: %ld",error.code]];
    }];
}

- (void)updateRoomOnlineStatus {
    [WebService updateOnlineRoomStatusWithRoomId:self.roomId responseClass:nil success:^(id  _Nullable responseObject) {
        Log(@"同步房间在线状态成功");
    } failure:^(NSError * _Nonnull error) {
        Log(@"同步房间在线状态失败");
    }];
}

#pragma mark - user manager
- (void)kickUserFromRoom:(NSString *)uid {
    [[RCVoiceRoomEngine sharedInstance] kickUserFromRoom:uid success:^{
        [SVProgressHUD showSuccessWithStatus:@"踢出用户成功"];
    } error:^(RCVoiceRoomErrorCode code, NSString * _Nonnull msg) {
        [SVProgressHUD showErrorWithStatus:[NSString stringWithFormat:@"踢出用户失败 code: %ld",(long)code]];
    }];
}

- (void)agreeUserFromRoom:(NSString *)uid {
    [[RCVoiceRoomEngine sharedInstance] acceptRequestSeat:uid success:^{
        [SVProgressHUD showSuccessWithStatus:@"同意用户上麦成功"];
    } error:^(RCVoiceRoomErrorCode code, NSString * _Nonnull msg) {
        [SVProgressHUD showErrorWithStatus:[NSString stringWithFormat:@"同意用户上麦失败 code: %ld",(long)code]];
    }];
}

- (void)rejectUserFromRoom:(NSString *)uid {
    [[RCVoiceRoomEngine sharedInstance] rejectRequestSeat:uid success:^{
        [SVProgressHUD showSuccessWithStatus:@"拒绝用户上麦成功"];
    } error:^(RCVoiceRoomErrorCode code, NSString * _Nonnull msg) {
        [SVProgressHUD showErrorWithStatus:[NSString stringWithFormat:@"拒绝用户上麦失败 code: %ld",(long)code]];
    }];
}

- (void)pickUserToSeat:(NSString *)uid {
    [[RCVoiceRoomEngine sharedInstance] pickUserToSeat:uid success:^{
        [SVProgressHUD showSuccessWithStatus:@"抱麦邀请成功"];
    } error:^(RCVoiceRoomErrorCode code, NSString * _Nonnull msg) {
        [SVProgressHUD showErrorWithStatus:[NSString stringWithFormat:@"抱麦邀请失败 code: %ld",(long)code]];
    }];
}

- (void)acceptPickUser {
    NSInteger emptyIndex = [self emptySeatIndex];
    if (emptyIndex < 0) {
        [SVProgressHUD showErrorWithStatus:@"当前没有空置的麦位"];
        return ;
    }
    [self enterSeat:emptyIndex];
}

- (void)kickUserFromSeat:(NSString *)uid {
    [[RCVoiceRoomEngine sharedInstance] kickUserFromSeat:uid success:^{
        [SVProgressHUD showSuccessWithStatus:@"踢麦请求发送成功"];
    } error:^(RCVoiceRoomErrorCode code, NSString * _Nonnull msg) {
        [SVProgressHUD showErrorWithStatus:[NSString stringWithFormat:@"踢麦请求发送失败 code: %ld",(long)code]];
    }];
}

- (void)inviteUserFromRoom:(NSString *)uid {
    NSInteger emptyIndex = [self emptySeatIndex];
    if (emptyIndex < 0) {
        [SVProgressHUD showErrorWithStatus:@"当前没有空置的麦位"];
        return ;
    }
    NSDictionary *content = @{@"uid":uid,@"index":@(emptyIndex)};
    NSString *contentString = [content yy_modelToJSONString];
    [[RCVoiceRoomEngine sharedInstance] sendInvitation:contentString success:^(NSString * _Nonnull uid) {
        [SVProgressHUD showSuccessWithStatus:@"邀请用户上麦成功"];
    } error:^(RCVoiceRoomErrorCode code, NSString * _Nonnull msg) {
        [SVProgressHUD showErrorWithStatus:[NSString stringWithFormat:@"邀请用户上麦失败 code: %ld",(long)code]];
    }];
}

- (NSInteger)emptySeatIndex {
    for (int i = 0; i < self.seatlist.count; i++) {
        RCVoiceSeatInfo *info = self.seatlist[i];
        if (info.status == RCSeatStatusEmpty) {
            return i;
        }
    }
    return -1;
}

/// 用户接受主播上麦邀请
- (void)acceptInvitation:(NSString *)uid seatIndex:(NSUInteger)seatIndex {
    [[RCVoiceRoomEngine sharedInstance] acceptInvitation:uid success:^{
        [SVProgressHUD showSuccessWithStatus:@"同意邀请成功"];
        [self enterSeat:seatIndex];
    } error:^(RCVoiceRoomErrorCode code, NSString * _Nonnull msg) {
        [SVProgressHUD showErrorWithStatus:[NSString stringWithFormat:@"同意邀请失败 code: %ld",(long)code]];
    }];
}

/// 用户拒绝主播上麦邀请
- (void)rejectInvitation:(NSString *)uid {
    [[RCVoiceRoomEngine sharedInstance] rejectInvitation:uid success:^{
        [SVProgressHUD showSuccessWithStatus:@"拒绝邀请成功"];
    } error:^(RCVoiceRoomErrorCode code, NSString * _Nonnull msg) {
        [SVProgressHUD showErrorWithStatus:[NSString stringWithFormat:@"拒绝邀请失败 code: %ld",(long)code]];
    }];
}

#pragma mark - seat manager
- (void)leaveSeat {
    [[RCVoiceRoomEngine sharedInstance] leaveSeatWithSuccess:^{
        [SVProgressHUD showSuccessWithStatus:@"下麦成功"];
    } error:^(RCVoiceRoomErrorCode code, NSString * _Nonnull msg) {
        [SVProgressHUD showErrorWithStatus:[NSString stringWithFormat:@"下麦失败 code: %ld",(long)code]];
    }];
}

- (void)enterSeat:(NSUInteger)seatIndex {
    [[RCVoiceRoomEngine sharedInstance] enterSeat:seatIndex success:^{
        [SVProgressHUD showSuccessWithStatus:@"上麦成功"];
        self.onTheSeat = YES;
    } error:^(RCVoiceRoomErrorCode code, NSString * _Nonnull msg) {
        [SVProgressHUD showSuccessWithStatus:[NSString stringWithFormat:@"上麦失败：%@", msg]];
    }];
}

- (void)switchSeatTo:(NSUInteger)seatIndex {
    [[RCVoiceRoomEngine sharedInstance] switchSeatTo:seatIndex
                                             success:^{
        [SVProgressHUD showSuccessWithStatus:@"换麦成功"];
    } error:^(RCVoiceRoomErrorCode code, NSString * _Nonnull msg) {
        [SVProgressHUD showErrorWithStatus:[NSString stringWithFormat:@"换麦失败 code: %ld",(long)code]];
    }];
}

- (void)requestSeat:(NSUInteger)seatIndex {
    [[RCVoiceRoomEngine sharedInstance] requestSeat:^{
        [SVProgressHUD showSuccessWithStatus:@"上麦请求发送成功"];
    } error:^(RCVoiceRoomErrorCode code, NSString * _Nonnull msg) {
        [SVProgressHUD showErrorWithStatus:[NSString stringWithFormat:@"上麦请求发送失败 code: %ld",(long)code]];
    }];
}

- (void)cancelRequest {
    [[RCVoiceRoomEngine sharedInstance] cancelRequestSeat:^{
        [SVProgressHUD showSuccessWithStatus:@"取消上麦申请成功"];
    } error:^(RCVoiceRoomErrorCode code, NSString * _Nonnull msg) {
        [SVProgressHUD showErrorWithStatus:[NSString stringWithFormat:@"取消上麦申请失败 code: %ld",(long)code]];
    }];
}

/// 锁麦
- (void)lockSeat:(NSUInteger)seatIndex lock:(BOOL)isLocking {
    NSString *keyTips = isLocking ? @"锁定" : @"解锁";
    [[RCVoiceRoomEngine sharedInstance] lockSeat:seatIndex lock:isLocking success:^{
        [SVProgressHUD showSuccessWithStatus:[NSString stringWithFormat:@"座位:%ld%@成功",seatIndex,keyTips]];
    } error:^(RCVoiceRoomErrorCode code, NSString * _Nonnull msg) {
        [SVProgressHUD showSuccessWithStatus:[NSString stringWithFormat:@"座位%@失败 code: %ld", keyTips,code]];
    }];
}

/// 闭麦
- (void)muteSeat:(NSUInteger)seatIndex mute:(BOOL)isMute {
    NSString *keyTips = isMute ? @"" : @"解除" ;
    [[RCVoiceRoomEngine sharedInstance] muteSeat:seatIndex mute:isMute success:^{
        [SVProgressHUD showSuccessWithStatus:[NSString stringWithFormat:@"座位:%ld%@闭麦成功",seatIndex,keyTips]];
    } error:^(RCVoiceRoomErrorCode code, NSString * _Nonnull msg) {
        [SVProgressHUD showSuccessWithStatus:[NSString stringWithFormat:@"座位%@闭麦败 code: %ld", keyTips,code]];
    }];
}

#pragma mark - room settings 房间控制
/// TODO: 全员锁麦，setRoomInfo.isLockAll，锁定成功，为什么麦位的状态没有变更？？？使用场景是什么？
/// 全部锁麦后，所有麦位不能上麦；反之，可以全部解锁。YES 为全部锁定，NO 为全部解除锁定。
- (void)lockAll:(BOOL)lock {
    RCVoiceRoomInfo *roomInfo = self.roomInfo;
    roomInfo.isLockAll = lock;
    NSString *keyTips = lock ? @"" : @"解除";
    [[RCVoiceRoomEngine sharedInstance] setRoomInfo:roomInfo success:^{
        [SVProgressHUD showSuccessWithStatus:[NSString stringWithFormat:@"全员%@锁定成功",keyTips]];
    } error:^(RCVoiceRoomErrorCode code, NSString * _Nonnull msg) {
        [SVProgressHUD showErrorWithStatus:[NSString stringWithFormat:@"全员%@锁定失败 code: %ld",keyTips,(long)code]];
    }];
}

/// TODO: 全员闭麦，setRoomInfo.isMuteAll，锁定成功，为什么麦位的状态没有变更？？？使用场景是什么？?
- (void)muteAll:(BOOL)mute {
    RCVoiceRoomInfo *roomInfo = self.roomInfo;
    roomInfo.isMuteAll = mute;
    NSString *keyTips = mute ? @"" : @"解除";
    [[RCVoiceRoomEngine sharedInstance] setRoomInfo:roomInfo success:^{
        [SVProgressHUD showSuccessWithStatus:[NSString stringWithFormat:@"全员%@闭麦成功",keyTips]];
    } error:^(RCVoiceRoomErrorCode code, NSString * _Nonnull msg) {
        [SVProgressHUD showErrorWithStatus:[NSString stringWithFormat:@"全员%@闭麦失败 code: %ld",keyTips,(long)code]];
    }];
}

- (void)lockOthers:(BOOL)lock {
    [[RCVoiceRoomEngine sharedInstance] lockOtherSeats:lock];
}

- (void)muteOthers:(BOOL)mute {
    [[RCVoiceRoomEngine sharedInstance] muteOtherSeats:mute];
}

- (void)micDisable:(BOOL)disable {
    [[RCVoiceRoomEngine sharedInstance] disableAudioRecording:disable];
}

- (void)speakerEnable:(BOOL)enable {
    [[RCVoiceRoomEngine sharedInstance] enableSpeaker:enable];
}

- (void)muteAllRemoteStreams:(BOOL)mute {
    [[RCVoiceRoomEngine sharedInstance] muteAllRemoteStreams:mute];
}

- (void)setAudioQuality:(RCVoiceRoomAudioQuality)quality
               scenario:(RCVoiceRoomAudioScenario)scenario {
    [[RCVoiceRoomEngine sharedInstance] setAudioQuality:quality
                                               scenario:scenario];
}

- (void)notifyVoiceRoom:(NSString *)name
                content:(NSString *)content {
    [[RCVoiceRoomEngine sharedInstance] notifyVoiceRoom:name
                                                content:content];
}

@end
