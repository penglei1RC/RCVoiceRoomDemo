//
//  RCVoiceRoomController.h
//  RCVoiceRoomDemo
//
//  Created by 彭蕾 on 2022/5/20.
//

#import <UIKit/UIKit.h>
#import "RCVoiceRoomPresenter.h"
#import "CreateRoomModel.h"
#import "RCUserListView.h"
#import "RCRoomActionView.h"
#import "RCPKView.h"

NS_ASSUME_NONNULL_BEGIN

@interface RCVoiceRoomController : UIViewController

@property (nonatomic, assign, readonly) BOOL isCreate;
@property (nonatomic, strong, readonly) RCVoiceRoomPresenter *presenter;
@property (nonatomic, strong, readonly) RCUserListView *userListView;

@property (nonatomic, assign) RCVoiceRoomPKRole role;
@property (nonatomic, strong) RCVoicePKInfo *currentPKInfo;

- (instancetype)initWithJoinRoomId:(NSString *)roomId;

- (instancetype)initWithCreateAndJoinRoomId:(NSString *)roomId
                                   roomInfo:(RCVoiceRoomInfo *)roomInfo;

- (void)updatePKStatus:(BOOL)isPK;

@end

NS_ASSUME_NONNULL_END
