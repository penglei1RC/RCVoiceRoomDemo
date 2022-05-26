//
//  RCVoiceRoomPresenter+PK.m
//  RCVoiceRoomDemo
//
//  Created by 彭蕾 on 2022/5/24.
//

#import "RCVoiceRoomPresenter+PK.h"

@implementation RCVoiceRoomPresenter (PK)

- (void)pk_fetchOnlineCreatorListWithBlock:(void(^)(NSArray<RCOnlineCreatorModel *> *creatorList))completionBlock {
    [WebService pk_roomOnlineCreatedListWithResponseClass:[RoomModel class] success:^(id  _Nullable responseObject) {
        Log(@"获取在线房主成功");
        RCResponseModel *res = (RCResponseModel *)responseObject;
        NSArray<RoomModel *> *roomList = (NSArray<RoomModel *> *)res.data;
        NSMutableArray<RCOnlineCreatorModel *> *creatorList = [NSMutableArray array];
        for (RoomModel *room in roomList) {
            RCOnlineCreatorModel *creator = [[RCOnlineCreatorModel alloc] initWithRoomModel:room];
            [creatorList addObject:creator];
        }
        !completionBlock ?: completionBlock(creatorList.copy);
    } failure:^(NSError * _Nonnull error) {
        !completionBlock ?: completionBlock(nil);
        [SVProgressHUD showErrorWithStatus:[NSString stringWithFormat:@"获取在线房失败 code: %ld",error.code]];
    }];
}

- (void)pk_sendPKInvitation:(NSString *)inviteeRoomId invitee:(NSString *)inviteeUserId {
    [WebService pk_checkRoomType:inviteeRoomId responseClass:nil success:^(id  _Nullable responseObject) {
        RCResponseModel *model = (RCResponseModel *)responseObject;
        if (!model.data) {
            [SVProgressHUD showErrorWithStatus:@"对方房间正在PK中"];
            return ;
        }
        [[RCVoiceRoomEngine sharedInstance] sendPKInvitation:inviteeRoomId invitee:inviteeUserId success:^{
            [SVProgressHUD showSuccessWithStatus:@"发送PK邀请成功"];
        } error:^(RCVoiceRoomErrorCode code, NSString * _Nonnull msg) {
            [SVProgressHUD showErrorWithStatus:[NSString stringWithFormat:@"发送PK邀请失败 code: %ld",(long)code]];
        }];
    } failure:^(NSError * _Nonnull error) {
        Log(@"查询房间是否在PK中失败");
    }];

}

- (void)pk_cancelPKInvitation:(NSString *)inviteeRoomId invitee:(NSString *)inviteeUserId {
    [[RCVoiceRoomEngine sharedInstance] cancelPKInvitation:inviteeRoomId invitee:inviteeUserId success:^{
        [SVProgressHUD showSuccessWithStatus:@"取消PK邀请成功"];
    } error:^(RCVoiceRoomErrorCode code, NSString * _Nonnull msg) {
        [SVProgressHUD showErrorWithStatus:[NSString stringWithFormat:@"取消PK邀请失败 code: %ld",(long)code]];
    }];
}

- (void)pk_responsePKInvitation:(NSString *)inviterRoomId
                        inviter:(NSString *)inviterUserId
                   responseType:(RCPKResponseType)type {
    NSString *keyTips = (type == RCPKResponseAgree) ? @"同意" : ((type == RCPKResponseReject) ? @"拒绝":@"忽略");
    [[RCVoiceRoomEngine sharedInstance] responsePKInvitation:inviterRoomId inviter:inviterUserId responseType:type success:^{
        [SVProgressHUD showSuccessWithStatus:[NSString stringWithFormat:@"%@PK邀请成功", keyTips]];
    } error:^(RCVoiceRoomErrorCode code, NSString * _Nonnull msg) {
        [SVProgressHUD showErrorWithStatus:[NSString stringWithFormat:@"%@PK邀请失败 code: %ld", keyTips, (long)code]];
    }];
}

- (void)pk_syncPKState:(NSInteger)status
              toRoomId:(NSString *)toRoomId
       completionBlock:(void(^)(BOOL success))completionBlock {
    [WebService pk_syncPKStateWithRoomId:self.roomId status:status toRoomId:toRoomId responseClass:nil success:^(id  _Nullable responseObject) {
        Log(@"pk同步成功");
        !completionBlock ?: completionBlock(YES);
    } failure:^(NSError * _Nonnull error) {
        Log(@"pk同步失败");
        !completionBlock ?: completionBlock(NO);
    }];
}

- (void)pk_quitPKCompletionBlock:(void(^)(BOOL success))completionBlock {
    [[RCVoiceRoomEngine sharedInstance] quitPK:^{
        [SVProgressHUD showSuccessWithStatus:@"退出PK成功"];
        !completionBlock ?: completionBlock(YES);
    } error:^(RCVoiceRoomErrorCode code, NSString * _Nonnull msg) {
        [SVProgressHUD showErrorWithStatus:[NSString stringWithFormat:@"退出PK失败 code: %ld",(long)code]];
        !completionBlock ?: completionBlock(YES);
    }];
}


- (void)pk_fetchPKDetailWithCompletionBlock:(void(^)(RCPKStatusModel * _Nullable statusModel))completionBlock {
    [WebService pk_fetchPKDetail:self.roomId responseClass:[RCPKStatusModel class] success:^(id  _Nullable responseObject) {
        Log(@"获取PK详情成功");
        RCPKStatusModel *model = (RCPKStatusModel *)((RCResponseModel *)responseObject).data;
        !completionBlock ?: completionBlock(model);
    } failure:^(NSError * _Nonnull error) {
        Log(@"获取PK详情失败");
        !completionBlock ?: completionBlock(nil);
    }];
}

- (void)pk_resumePK:(RCVoicePKInfo *)info {
    [[RCVoiceRoomEngine sharedInstance] resumePKWithPKInfo:info success:^{
        [SVProgressHUD showSuccessWithStatus:@"PK恢复成功"];
    } error:^(RCVoiceRoomErrorCode code, NSString * _Nonnull msg) {
        [SVProgressHUD showErrorWithStatus:[NSString stringWithFormat:@"PK恢复失败 code: %ld",(long)code]];
    }];
}

- (void)pk_mutePKUser:(BOOL)isMute {
    NSString *keyTips = isMute ? @"" : @"解除" ;
    [[RCVoiceRoomEngine sharedInstance] mutePKUser:isMute success:^{
        [SVProgressHUD showSuccessWithStatus:[NSString stringWithFormat:@"%@静音 PK 对象成功",keyTips]];
    } error:^(RCVoiceRoomErrorCode code, NSString * _Nonnull msg) {
        [SVProgressHUD showErrorWithStatus:[NSString stringWithFormat:@"%@静音 PK 对象失败 code: %ld",keyTips,(long)code]];
    }];
}


@end
