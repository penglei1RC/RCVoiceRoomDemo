//
//  RCVoiceRoomController+PK.m
//  RCVoiceRoomDemo
//
//  Created by 彭蕾 on 2022/5/24.
//

#import "RCVoiceRoomController+PK.h"
#import "RCVoiceRoomPresenter+PK.h"
#import "RCOnlineCreatorModel.h"
#import "RCPKStatusContent.h"
#import "RCPKStatusMessage.h"

@implementation RCVoiceRoomController (PK)

- (void)pk_loadPKModule {
    WeakSelf(self);
    [self.presenter pk_fetchPKDetailWithCompletionBlock:^(RCPKStatusModel * _Nullable statusModel) {
        StrongSelf(weakSelf);
        if (statusModel.roomScores.count != 2) {
            [strongSelf updatePKStatus:NO];
            return ;
        }
        
        // 如果是pk房间，则需要恢复pk
        RCPKStatusRoomScore *roomscore0 = statusModel.roomScores[0];
        RCPKStatusRoomScore *roomscore1 = statusModel.roomScores[1];
        
        if (roomscore0.leader) {
            strongSelf.currentPKInfo = [[RCVoicePKInfo alloc] initWithInviterId:roomscore0.userId
                                                                  inviterRoomId:roomscore0.roomId
                                                                      inviteeId:roomscore1.userId
                                                                  inviteeRoomId:roomscore1.roomId];
            strongSelf.role = [strongSelf getCurrentPKRole:roomscore0.userId invitee:roomscore1.userId];
            
        } else {
            strongSelf.currentPKInfo = [[RCVoicePKInfo alloc] initWithInviterId:roomscore1.userId
                                                                  inviterRoomId:roomscore1.roomId
                                                                      inviteeId:roomscore0.userId
                                                                  inviteeRoomId:roomscore0.roomId];
            strongSelf.role = [strongSelf getCurrentPKRole:roomscore1.userId invitee:roomscore0.userId];
        }
        
        
        switch (statusModel.statusMsg) {
            case 0:
            case 1:
            {
                if (strongSelf.role != RCVoiceRoomPKRoleAudience) {
                    [strongSelf.presenter pk_resumePK:strongSelf.currentPKInfo];
                }
            }
                break;
            default:
                break;
        }
    }];
}

- (void)pk_invite:(BOOL)isInvite {
    if (!isInvite) {
        // 是否是我发起的PK邀请
        BOOL isMeInvite = [self.currentPKInfo.inviterUserId isEqualToString:[UserManager sharedManager].currentUser.userId];
        // 我是邀请者，则传入被邀请者的房间，否则传入邀请者房间
        NSString *toRoomId = isMeInvite ? self.currentPKInfo.inviteeRoomId : self.currentPKInfo.inviterRoomId;
        [self pk_quickToRoomId:toRoomId];
        return ;
    }
    
    [self.presenter pk_fetchOnlineCreatorListWithBlock:^(NSArray<RCOnlineCreatorModel *> * _Nonnull createList) {
        if (!createList) {
            return;
        }
        self.userListView.listType = RCUserListTypeRoomCreator;
        [self.userListView reloadData:createList];
        [self.userListView show];
    }];
}

- (void)pk_quickToRoomId:(NSString *)toRoomId {
    WeakSelf(self);
    [self.presenter pk_quitPKCompletionBlock:^(BOOL success) {
        StrongSelf(weakSelf);
        if (!success) {
            return ;
        }
        
        [strongSelf.presenter pk_syncPKState:2 toRoomId:toRoomId completionBlock:^(BOOL success) {}];
        strongSelf.role = RCVoiceRoomPKRoleAudience;
        [strongSelf updatePKStatus:NO];
    }];
}

#pragma mark - delegate
/// PK 运行的回调，如果 PK 连接成功，或者进入正在进行PK的房间均会触发此回调
/// @param inviterRoomId 邀请 PK 的用户所在房间id
/// @param inviterUserId 邀请 PK 的用户id
/// @param inviteeRoomId 被邀请 PK 的用户所在房间id
/// @param inviteeUserId 被邀请 PK 的用户id
- (void)pkOngoingWithInviterRoom:(NSString *)inviterRoomId
               withInviterUserId:(NSString *)inviterUserId
                 withInviteeRoom:(NSString *)inviteeRoomId
               withInviteeUserId:(NSString *)inviteeUserId {
    Log(@"向服务器发送 pk 开始的请求");
    
    self.currentPKInfo = [[RCVoicePKInfo alloc] initWithInviterId:inviterUserId
                                                    inviterRoomId:inviterRoomId
                                                        inviteeId:inviteeUserId
                                                    inviteeRoomId:inviteeRoomId];
    self.role = [self getCurrentPKRole:inviterUserId invitee:inviteeUserId];
    switch (self.role) {
        case RCVoiceRoomPKRoleInviter:
        {
            if (self.isCreate) {
                [self.presenter lockOthers:YES];
            }
            [SVProgressHUD showSuccessWithStatus:@"PK 即将开始，PK过程中，麦上观众将被抱下麦"];
            WeakSelf(self);
            [weakSelf.presenter pk_syncPKState:0 toRoomId:inviteeRoomId completionBlock:^(BOOL success) {
                StrongSelf(weakSelf);
                if (success) {
                    Log(@"PK开始...");
                    [strongSelf updatePKStatus:YES];
                    return ;
                }
                [strongSelf pk_quickToRoomId:inviteeRoomId];
            }];
        }
            break;
        case RCVoiceRoomPKRoleInvitee:
        {
            if (self.isCreate) {
                [self.presenter lockOthers:YES];
                [self updatePKStatus:YES];
            }
            [SVProgressHUD showSuccessWithStatus:@"PK 即将开始，PK过程中，麦上观众将被抱下麦"];
        }
            break;
        case RCVoiceRoomPKRoleAudience:
            [SVProgressHUD showSuccessWithStatus:@"PK 即将开始，PK过程中，麦上观众将被抱下麦"];
            break;
        default:
            break;
    }
}

- (RCVoiceRoomPKRole)getCurrentPKRole:(NSString *)inviterUserId invitee:(NSString *)inviteeUserId {
    BOOL isInviter = [[UserManager sharedManager].currentUser.userId isEqualToString:inviterUserId];
    BOOL isInvitee = [[UserManager sharedManager].currentUser.userId isEqualToString:inviteeUserId];
    RCVoiceRoomPKRole role = isInvitee ? RCVoiceRoomPKRoleInvitee : RCVoiceRoomPKRoleAudience;
    return isInviter ? RCVoiceRoomPKRoleInviter : role;
}

/// 对方结束PK时会触发此回调
/// 收到该回调后会自动退出 PK 连接
- (void)pkDidFinish {
    if (self.isCreate) {
        [self.presenter lockOthers:NO];
    }
    self.role = RCVoiceRoomPKRoleAudience;
    [self updatePKStatus:NO];
}

/// 收到邀请 PK 的回调
/// @param inviterRoomId 邀请者的房间id
/// @param inviterUserId 邀请者的用户id
- (void)pkInvitationDidReceiveFromRoom:(NSString *)inviterRoomId byUser:(NSString *)inviterUserId {
    UIAlertController *actionSheet = [UIAlertController alertControllerWithTitle:@"是否接受PK邀请" message:@"" preferredStyle:UIAlertControllerStyleActionSheet];
    [actionSheet addAction:[UIAlertAction actionWithTitle:@"接受" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [self.presenter pk_responsePKInvitation:inviterRoomId inviter:inviterUserId responseType:RCPKResponseAgree];
    }]];
    
    [actionSheet addAction:[UIAlertAction actionWithTitle:@"拒绝" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [self.presenter pk_responsePKInvitation:inviterRoomId inviter:inviterUserId responseType:RCPKResponseReject];
    }]];
    
    [actionSheet addAction:[UIAlertAction actionWithTitle:@"忽略" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [self.presenter pk_responsePKInvitation:inviterRoomId inviter:inviterUserId responseType:RCPKResponseIgnore];
    }]];
    
    [self presentViewController:actionSheet animated:YES completion:nil];
}

/// 邀请者取消 PK 邀请回调。被邀请者忽略邀请也会调用此函数
/// @param inviterRoomId 邀请者的房间id
/// @param inviterUserId 邀请者的用户id
- (void)cancelPKInvitationDidReceiveFromRoom:(NSString *)inviterRoomId byUser:(NSString *)inviterUserId {
    [SVProgressHUD showErrorWithStatus:[NSString stringWithFormat:@"用户%@取消了%@房间的PK邀请",inviterUserId, inviterRoomId]];
}

/// 被邀请者拒绝 PK 邀请回调给邀请者
/// @param inviteeRoomId 被邀请者的房间id
/// @param initeeUserId 被邀请者的用户id
- (void)rejectPKInvitationDidReceiveFromRoom:(NSString *)inviteeRoomId byUser:(NSString *)initeeUserId {
    [SVProgressHUD showErrorWithStatus:[NSString stringWithFormat:@"用户%@拒绝了您的PK邀请",initeeUserId]];
}

/// 邀请者忽略 PK 邀请回调给邀请者
/// @param inviteeRoomId 被邀请者的房间id
/// @param inviteeUserId 被邀请者的用户id
- (void)ignorePKInvitationDidReceiveFromRoom:(NSString *)inviteeRoomId byUser:(NSString *)inviteeUserId {
    [SVProgressHUD showErrorWithStatus:[NSString stringWithFormat:@"用户%@忽略了您的PK邀请",inviteeUserId]];
}


/// TODO: - 接受pk消息 message.content 输出为空
- (void)pk_messageDidReceive:(nonnull RCMessage *)message {
    Log(@"%@",message.content);
    if (![message.content isKindOfClass:[RCPKStatusMessage class]]) {
        return ;
    }
    RCPKStatusContent *content = (RCPKStatusContent *)((RCPKStatusMessage *)message.content).content;
    Log(@"%@",message.content.extra);
    switch (content.statusMsg) {//pk 状态,0:PK中,1:惩罚中，2:PK结束
        case 0:
        {
            Log(@"PK中");
            // 1. 检查之前是否关闭对面PK主播的声音，然后恢复
            [self.presenter pk_mutePKUser:NO];
            // 2. 更新pk中UI
            // 3. 锁麦
             [self.presenter lockOthers:YES];
        }
            break;
        case 1:
            Log(@"惩罚中");
            // 1. 更新惩罚中UI
            break;
        case 2:
        {
            Log(@"PK结束");
            // 1. 提示结束原因
            NSString *keyTips;
            if (!content.stopPkRoomId || content.stopPkRoomId.length == 0) { // 自然结束
                keyTips = @"本轮PK结束";
            } else if ([content.stopPkRoomId isEqualToString: self.presenter.roomId]) {
                keyTips = @"我方挂断，本轮PK结束";
            } else {
                keyTips = @"对方挂断，本轮PK结束";
            }
            [SVProgressHUD showSuccessWithStatus:keyTips];

            
            // 2. 当前PK角色
            switch (self.role) {
                case RCVoiceRoomPKRoleInviter:
                {
                    // 发送本轮PK结束文本消息
                    // 自然结束手动调用RC服务器退出PK
                    if (!content.stopPkRoomId || content.stopPkRoomId.length == 0) {
                        [self.presenter pk_quitPKCompletionBlock:^(BOOL success) {}];
                    }
                }
                    break;
                case RCVoiceRoomPKRoleInvitee:
                {
                    // 发送本轮PK结束文本消息
                }
                    break;
                case RCVoiceRoomPKRoleAudience:
                    break;
                default:
                    break;
            }
            
            // 3. 当前房间角色：如果是创建者则解锁其它麦位置
            if (self.isCreate) {
                [self.presenter lockOthers:YES];
            }
            break;
        }
            
        default:
            break;
    }
    
}

@end
