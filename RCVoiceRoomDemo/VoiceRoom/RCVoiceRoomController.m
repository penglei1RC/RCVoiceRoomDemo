//
//  RCVoiceRoomController.m
//  RCVoiceRoomDemo
//
//  Created by 彭蕾 on 2022/5/20.
//

#import "RCVoiceRoomController.h"
#import "RCUserListView.h"
#import "RCSeatsView.h"
#import "UIImageView+AFNetworking.h"
#import "RCVoiceRoomController+PK.h"
#import "RCVoiceRoomPresenter+PK.h"
#import "RCPKView.h"

@interface RCVoiceRoomController ()<RCVoiceRoomDelegate>

@property (nonatomic, copy) NSString *roomId;
@property (nonatomic, copy) RCVoiceRoomInfo *roomInfo;
@property (nonatomic, assign, readwrite) BOOL isCreate;
@property (nonatomic, strong, readwrite) RCVoiceRoomPresenter *presenter;

/// 用户请求上麦麦位
@property (nonatomic, assign) NSInteger requestSeatIndex;

/// 麦位变化
@property (nonatomic, strong) RCSeatsView *seatsView;

/// 用户管理
@property (nonatomic, strong, readwrite) RCUserListView *userListView;

/// PK
@property (nonatomic, strong) RCPKView *pkView;

/// 房间管理
@property (nonatomic, strong) RCRoomActionView *bottomActionView;

@property (nonatomic, strong) UIImageView *bgImageView;
@property (nonatomic, copy) NSString *currentbgImageUrl;


@end

@implementation RCVoiceRoomController

- (instancetype)initWithJoinRoomId:(NSString *)roomId {
    if (self = [super initWithNibName:nil bundle:nil]) {
        self.roomId = roomId;
        self.role = RCVoiceRoomPKRoleAudience;
    }
    return self;
}

- (instancetype)initWithCreateAndJoinRoomId:(NSString *)roomId
                                   roomInfo:(RCVoiceRoomInfo *)roomInfo {
    if (self = [super initWithNibName:nil bundle:nil]) {
        self.roomId = roomId;
        self.isCreate = YES;
        self.roomInfo = roomInfo;
        self.presenter.roomInfo = self.roomInfo;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self UIConfig];
    
    [RCVoiceRoomEngine.sharedInstance setDelegate:self];
    
    if(self.isCreate) {
        [self.presenter createAndJoinRoom];
    } else {
        [self.presenter joinRoom];
    }
    
    self.requestSeatIndex = -1;
}

- (void)UIConfig {
    self.title = self.roomInfo.roomName;
    UIBarButtonItem *leftItem = [[UIBarButtonItem alloc] initWithTitle:@"退出"
                                                                 style:UIBarButtonItemStylePlain
                                                                target:self
                                                                action:@selector(exitRoom)];
    self.navigationItem.leftBarButtonItem = leftItem;
    
    if (_isCreate) {
        UIBarButtonItem *rightItem = [[UIBarButtonItem alloc] initWithTitle:@"改背景"
                                                                     style:UIBarButtonItemStylePlain
                                                                    target:self
                                                                    action:@selector(changeBGImg)];
        self.navigationItem.rightBarButtonItem = rightItem;
    } else {
        
    }
    
    [self.view addSubview:self.bgImageView];
    [self.bgImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.view);
    }];
    
    UILabel *userLabel = [[UILabel alloc] init];
    userLabel.font = [UIFont systemFontOfSize:14];
    userLabel.textColor = [UIColor whiteColor];
    userLabel.numberOfLines = 0;
    userLabel.text = [NSString stringWithFormat:@"当前用户id：%@\n当前用户名：%@",
                      UserManager.sharedManager.currentUser.userId,
                      UserManager.sharedManager.currentUser.userName];
    [self.view addSubview:userLabel];
    [userLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self.view);
        make.top.equalTo(self.view.mas_safeAreaLayoutGuideTop).offset(0);
    }];
    
    [self.view addSubview:self.seatsView];
    [_seatsView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.equalTo(self.view);
        make.top.equalTo(userLabel.mas_bottom).offset(20);
        make.height.equalTo(@(255));
    }];
    
    [self.view addSubview:self.pkView];
    [_pkView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.equalTo(self.view);
        make.top.equalTo(userLabel.mas_bottom).offset(20);
        make.height.equalTo(@(255));
    }];
    
    [self.view addSubview:self.bottomActionView];
    [_bottomActionView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.equalTo(self.view);
        make.trailing.equalTo(self.view);
        make.height.mas_equalTo(120);
        make.bottom.mas_equalTo(-60);
    }];
    
    [self.view addSubview:self.userListView];
}


#pragma mark - room action
- (void)fetchRequestList {
    [self.presenter fetchRequestListWithBlock:^(NSArray<UserModel *> * _Nonnull userList) {
        if (!userList) {
            return;
        }
        self.userListView.listType = RCUserListTypeRequest;
        [self.userListView reloadData:userList];
        [self.userListView show];
    }];
}

- (void)fetchUserList {
    [self.presenter fetchRoomUserListWithBlock:^(NSArray<UserModel *> * _Nonnull userList) {
        if (!userList) {
            return;
        }
        self.userListView.listType = RCUserListTypeRoomUser;
        [self.userListView reloadData:userList];
        [self.userListView show];
    }];
}

#pragma mark - seat action
- (void)showActionSheetWithSeatInfo:(RCVoiceSeatInfo *)seatInfo seatIndex:(NSInteger)index {
    UIAlertController *actionSheet = [UIAlertController alertControllerWithTitle:@"" message:@"请选择操作" preferredStyle:UIAlertControllerStyleActionSheet];
    [actionSheet addAction:[UIAlertAction actionWithTitle:@"上麦" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [self enterSeatWithSeatInfo:seatInfo seatIndex:index];
    }]];
    [actionSheet addAction:[UIAlertAction actionWithTitle:@"下麦" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [self leaveSeatWithSeatInfo:seatInfo seatIndex:index];
    }]];
    [actionSheet addAction:[UIAlertAction actionWithTitle:@"闭麦" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [self muteSeatWithSeatInfo:seatInfo seatIndex:index];
    }]];
    
    if (self.isCreate) {
        [actionSheet addAction:[UIAlertAction actionWithTitle:@"锁麦" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            [self lockSeatWithSeatInfo:seatInfo seatIndex:index];
        }]];
        [actionSheet addAction:[UIAlertAction actionWithTitle:@"踢出麦位" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            [self kickSeatWithSeatInfo:seatInfo seatIndex:index];
        }]];
    }
    
    [actionSheet addAction:[UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:nil]];
    
    [self presentViewController:actionSheet animated:YES completion:nil];
}

/// 上麦
- (void)enterSeatWithSeatInfo:(RCVoiceSeatInfo *)seatInfo seatIndex:(NSInteger)index {
    switch (seatInfo.status) {
        case RCSeatStatusLocking:
            [SVProgressHUD showErrorWithStatus:@"当前座位被锁定"];
            return;
        case RCSeatStatusUsing:
            [SVProgressHUD showErrorWithStatus:@"当前座位被占用"];
            return;
        default:
            break;
    }
    if (self.isCreate || self.roomInfo.isFreeEnterSeat) {
        goto host; // 上麦/换麦
    } else {
        goto audience; // 申请上麦
    }
host:
    if (self.presenter.isOnTheSeat) {
        [self.presenter switchSeatTo:index];
    } else {
        [self.presenter enterSeat:index];
    }
    
audience:
    self.requestSeatIndex = index;
    [self.presenter requestSeat:index];
    
}

/// 下麦
- (void)leaveSeatWithSeatInfo:(RCVoiceSeatInfo *)seatInfo seatIndex:(NSInteger)index {
    switch (seatInfo.status) {
        case RCSeatStatusLocking:
            [SVProgressHUD showErrorWithStatus:@"当前座位被锁定"];
            return;
        case RCSeatStatusEmpty:
            [SVProgressHUD showErrorWithStatus:@"当前座位为空"];
            return;
        default:
            break;
    }
    
    BOOL isMe = [[UserManager sharedManager].currentUser.userId isEqualToString:seatInfo.userId];
    if (isMe) {
        [self.presenter leaveSeat];
        return ;
    }
    if (self.isCreate) { // 踢别人下麦
        [self.presenter kickUserFromSeat:seatInfo.userId];
    }

}

/// 闭麦（闭麦麦位）
- (void)muteSeatWithSeatInfo:(RCVoiceSeatInfo *)seatInfo seatIndex:(NSInteger)index {
    if (seatInfo.status == RCSeatStatusLocking) {
        [SVProgressHUD showErrorWithStatus:@"当前座位被锁定"];
        return;
    }
    BOOL isMute = seatInfo.isMuted;
    [self.presenter muteSeat:index mute:!isMute];
}

/// 锁麦
- (void)lockSeatWithSeatInfo:(RCVoiceSeatInfo *)seatInfo seatIndex:(NSInteger)index {
    BOOL isLocking = (seatInfo.status == RCSeatStatusLocking);
    [self.presenter lockSeat:index lock:!isLocking];
}

/// 踢出麦位
- (void)kickSeatWithSeatInfo:(RCVoiceSeatInfo *)seatInfo seatIndex:(NSInteger)index {
    switch (seatInfo.status) {
        case RCSeatStatusLocking:
            [SVProgressHUD showErrorWithStatus:@"当前座位被锁定"];
            return;
        case RCSeatStatusEmpty:
            [SVProgressHUD showErrorWithStatus:@"当前座位为空"];
            return;
        default:
            break;
    }
    [self.presenter kickUserFromSeat:seatInfo.userId];
}


#pragma mark - btnItem Action
- (void)exitRoom {
    if (!self.isCreate) {
        [self.presenter leaveRoom];
        [self popSelfToLeave];
        return ;
    }
    
    // 主播端调用业务接口销毁房间
    [self.presenter destroyRoomWithCompletionBlock:^(BOOL success) {
        if (!success) {
            return;
        }
        [self popSelfToLeave];
    }];
    
}

- (void)popSelfToLeave {
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)changeBGImg {
    NSString *imageUrl = @"https://gimg2.baidu.com/image_search/src=http%3A%2F%2Fb-ssl.duitang.com%2Fuploads%2Fitem%2F201602%2F15%2F20160215165543_XrWNk.thumb.1000_0.jpeg&refer=http%3A%2F%2Fb-ssl.duitang.com&app=2002&size=f9999,10000&q=a80&n=0&g=0n&fmt=auto?sec=1655967082&t=c9f98a5065c670652037b5fce2468dac";
    if (![self.currentbgImageUrl isEqualToString:imageUrl]) {
        self.currentbgImageUrl = imageUrl;
    } else {
        self.currentbgImageUrl = @"https://gimg2.baidu.com/image_search/src=http%3A%2F%2Fc-ssl.duitang.com%2Fuploads%2Fblog%2F202102%2F28%2F20210228173139_263ce.thumb.1000_0.jpeg&refer=http%3A%2F%2Fc-ssl.duitang.com&app=2002&size=f9999,10000&q=a80&n=0&g=0n&fmt=auto?sec=1655966933&t=892a89f79e1e7ae01d21e7e4f2ec9be4";
    }
    [self.presenter notifyVoiceRoom:@"refreshBackgroundImage" content:self.currentbgImageUrl];
    [self.bgImageView setImageWithURL:[NSURL URLWithString:self.currentbgImageUrl]];
}

- (void)updatePKStatus:(BOOL)isPK {
    [self.bottomActionView updateViewWithStatus:isPK role:self.role];
    if (!isPK) {
        self.pkView.hidden = YES;
        self.seatsView.hidden = NO;
    } else {
        NSArray<NSString *> *uids = @[self.currentPKInfo.inviterUserId, self.currentPKInfo.inviteeUserId];
        [self.presenter fetchUserInfoListWithUids:uids completionBlock:^(NSArray<UserModel *> * _Nonnull userList) {
            [self.pkView reloadData:userList];
            self.pkView.hidden = NO;
            self.seatsView.hidden = YES;
        }];
    }
}

#pragma mark - RCVoiceRoomDelegate ！！！
// 房间信息初始化完毕，可在此方法进行一些初始化操作，例如进入房间房主自动上麦等
- (void)roomKVDidReady {
    Log(@"RCVoiceRoomDelegate房间信息初始化完毕");

    if (self.isCreate) {
        [self.presenter enterSeat:0];
    }
    /// 获取pk信息
    [self pk_loadPKModule];
    [self.presenter updateRoomOnlineStatus];
}

// 任何麦位的变化都会触发此回调。
- (void)seatInfoDidUpdate:(NSArray<RCVoiceSeatInfo *> *)seatInfolist {
    Log(@"RCVoiceRoomDelegate麦位变化:%@",seatInfolist);
    self.presenter.seatlist = seatInfolist;
    [self.seatsView reloadData:seatInfolist];
}

/// 发送的排麦请求得到房主或管理员同意
- (void)requestSeatDidAccept {
    [self.presenter enterSeat:self.requestSeatIndex];
}

- (void)requestSeatDidReject {
    [SVProgressHUD showSuccessWithStatus:@"您的上麦请求被拒绝"];
}

/// 任何房间信息的修改都会触发此回调
- (void)roomInfoDidUpdate:(RCVoiceRoomInfo *)roomInfo {
    self.roomInfo = roomInfo;
    self.presenter.roomInfo = self.roomInfo;
}

/// 收到自己被抱上麦的请求
- (void)pickSeatDidReceiveBy:(NSString *)userId {
    [self showAlertWithTitle:@"接收到主播抱麦邀请" acceptBlock:^(BOOL accept) {
        if (!accept) {
            return ;
        }
        [self.presenter acceptPickUser];
    }];
}

/// 接受邀请 -- 暂未使用
/// @param invitationId 邀请的Id
/// @param userId 发送邀请的用户
/// @param content 邀请内容，用户可以自定义
- (void)invitationDidReceive:(NSString *)invitationId
                        from:(NSString *)userId
                    content:(NSString *)content {
    
    NSData *jsonData = [content dataUsingEncoding:NSUTF8StringEncoding];
    NSDictionary *dict;
    if (jsonData != nil) {
        NSError *err;
        dict = [NSJSONSerialization JSONObjectWithData:jsonData options:NSJSONReadingAllowFragments error:&err];
    }
    if (dict == nil)
        return;
    
    NSString *invitedUserId = dict[@"uid"];
    NSInteger index = [(NSNumber *)dict[@"index"] integerValue];
    
    /// 如果不是被邀请者，则不处理
    if (![invitedUserId isEqualToString:[UserManager sharedManager].currentUser.userId]) {
        return;
    }
    
    [self showAlertWithTitle:[NSString stringWithFormat:@"接收到上麦邀请:%@",content] acceptBlock:^(BOOL accept) {
        if (accept) {
            [self.presenter acceptInvitation:invitedUserId seatIndex:index];
        } else {
            [self.presenter rejectInvitation:invitedUserId];
        }
    }];
}

/// 房间已关闭。默认情况下，聊天室房间（ChatRoom) 一个小时内无人加入且无新消息，就会触发自动销毁。
- (void)roomDidClosed {
    Log(@"RCVoiceRoomDelegate房间已关闭");
}

/// 收到自己被下麦的通知
- (void)kickSeatDidReceive:(NSUInteger)seatIndex {
    [self.presenter leaveSeat];
}

/// 用户被踢出房间的回调
/// @param targetId 被踢出房间的用户id
/// @param userId 执行踢某人出房间的用户id
- (void)userDidKickFromRoom:(nonnull NSString *)targetId byUserId:(nonnull NSString *)userId {
    
    if (![targetId isEqualToString:[UserManager sharedManager].currentUser.userId]) {
        return;
    }
    
    /// 如果是当前用户被提出，则退出房间
    [self exitRoom];
    Log(@"您已被踢出");
}

- (void)roomNotificationDidReceive:(NSString *)name content:(NSString *)content {
    if (![name isEqualToString:@"refreshBackgroundImage"]) {
        return;
    }
    [self.bgImageView setImageWithURL:[NSURL URLWithString:content]];
}


// 聊天室消息回调
- (void)messageDidReceive:(nonnull RCMessage *)message {
    Log(@"PKMSG: objectName %@",message.objectName);
    if ([message.objectName isEqualToString:@"RCMic:chrmPkStatusMsg"]) {
        [self pk_messageDidReceive:message];
    }
}

#pragma mark - helper method
/// 相关弹窗
- (void)showAlertWithTitle:(NSString *)title acceptBlock:(void(^)(BOOL accept))block {
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:title message:nil preferredStyle:UIAlertControllerStyleAlert];
    [alert addAction:[UIAlertAction actionWithTitle:@"同意" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        !block ?: block(YES);
    }]];
    [alert addAction:[UIAlertAction actionWithTitle:@"拒绝" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
        !block ?: block(NO);
    }]];
    [self presentViewController:alert animated:YES completion:nil];
}

#pragma mark - lazy load
- (RCVoiceRoomPresenter *)presenter {
    if (!_presenter) {
        _presenter = [RCVoiceRoomPresenter new];
        _presenter.roomId = self.roomId;
    }
    return _presenter;
}

- (UIImageView *)bgImageView {
    if (!_bgImageView) {
        _bgImageView = [UIImageView new];
        _bgImageView.image = [UIImage imageNamed:@"roombackground"];
    }
    return _bgImageView;
}

- (RCSeatsView *)seatsView {
    if (!_seatsView) {
        _seatsView = [[RCSeatsView alloc] initWithCreate:self.isCreate];
        WeakSelf(self);
        _seatsView.handler = ^(RCVoiceSeatInfo * _Nonnull seatInfo, NSUInteger idx) {
            StrongSelf(weakSelf);
            [strongSelf showActionSheetWithSeatInfo:seatInfo seatIndex:idx];
        };
    }
    return _seatsView;
}

- (RCPKView *)pkView {
    if (!_pkView) {
        _pkView = [[RCPKView alloc] initWithCreate:self.isCreate];
        _pkView.hidden = YES;
    }
    return _pkView;
}

- (RCRoomActionView *)bottomActionView {
    if (!_bottomActionView) {
        _bottomActionView = [[RCRoomActionView alloc] initWithCreate:self.isCreate];
        WeakSelf(self);
        _bottomActionView.hander = ^(RCRoomActionType type, BOOL isSelected) {
            StrongSelf(weakSelf);
            switch (type) {
                case RCRoomActionTypeFetchRequestList:
                    [strongSelf fetchRequestList];
                    break;
                case RCRoomActionTypeFetchUserList:
                    [strongSelf fetchUserList];
                    break;
                case RCRoomActionTypeCancelRequest:
                    [strongSelf.presenter cancelRequest];
                    break;
                case RCRoomActionTypeSpeakerEnable:
                    [strongSelf.presenter speakerEnable:isSelected];
                    break;
                case RCRoomActionTypeMicDisable:
                    [strongSelf.presenter micDisable:isSelected];
                    break;
                case RCRoomActionTypeMuteAll:
                    [strongSelf.presenter muteOthers:isSelected];
                    break;
                case RCRoomActionTypeLockAll:
                    [strongSelf.presenter lockOthers:isSelected];
                    break;
                case RCRoomActionTypeMuteRemote:
                    [strongSelf.presenter muteAllRemoteStreams:isSelected];
                    break;
                case RCRoomActionTypePK:
                    [strongSelf pk_invite:!isSelected];
                    break;
                    
                default:
                    break;
            }
        };
    }
    return _bottomActionView;
}

- (RCUserListView *)userListView {
    if (!_userListView) {
        _userListView = [[RCUserListView alloc] initWithCreate:self.isCreate];
        _userListView.frame = CGRectMake(10, kScreenHeight, kScreenWidth - 20, kScreenHeight - 300);
        WeakSelf(self);
        _userListView.handler = ^(NSString * _Nonnull uid, NSString * _Nullable roomId, RCUserListCellActionType type) {
            StrongSelf(weakSelf);
            switch (type) {
                case RCUserListCellActionTypeKick:
                    [strongSelf.presenter kickUserFromRoom:uid];
                    break;
                case RCUserListCellActionTypeAgree:
                    [strongSelf.presenter agreeUserFromRoom:uid];
                    break;
                case RCUserListCellActionTypeReject:
                    [strongSelf.presenter rejectUserFromRoom:uid];
                    break;
                case RCUserListCellActionTypeInvite:
                    [strongSelf.presenter pickUserToSeat:uid];
                    break;
//                case RCUserListCellActionTypeCancelInvite:
//                    break;
                case RCUserListCellActionTypePKInvite:
                    [strongSelf.presenter pk_sendPKInvitation:roomId invitee:uid];
                    break;
                case RCUserListCellActionTypePKCancel:
                    [strongSelf.presenter pk_cancelPKInvitation:roomId invitee:uid];
                    break;
                default:
                    break;
            }
        };
    }
    return _userListView;
}

@end
