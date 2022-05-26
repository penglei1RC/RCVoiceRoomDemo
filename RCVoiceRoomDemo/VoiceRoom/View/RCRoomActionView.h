//
//  RCRoomActionView.h
//  RCVoiceRoomDemo
//
//  Created by 彭蕾 on 2022/5/23.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSUInteger, RCRoomActionType) {
    RCRoomActionTypeFetchRequestList,
    RCRoomActionTypeFetchUserList,
    RCRoomActionTypeCancelRequest,
    RCRoomActionTypeSpeakerEnable,
    RCRoomActionTypeMicDisable,
    RCRoomActionTypeMuteAll,
    RCRoomActionTypeLockAll,
    RCRoomActionTypeMuteRemote,
    RCRoomActionTypePK
};

typedef NS_ENUM(NSInteger, RCVoiceRoomPKRole){
    RCVoiceRoomPKRoleInviter,
    RCVoiceRoomPKRoleInvitee,
    RCVoiceRoomPKRoleAudience,
};

typedef void(^RCRoomActionHandler)(RCRoomActionType type, BOOL isSelected);

/// 房间操作管理列表
@interface RCRoomActionView : UIView

@property (nonatomic, copy) RCRoomActionHandler hander;

- (instancetype)initWithCreate:(BOOL)isCreate;
- (void)updateViewWithStatus:(BOOL)isPK role:(RCVoiceRoomPKRole )role;

@end

NS_ASSUME_NONNULL_END
