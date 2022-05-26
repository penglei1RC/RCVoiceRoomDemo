//
//  CreateRoomModel.h
//  RCVoiceRoomDemo
//
//  Created by 彭蕾 on 2022/5/20.
//

#import "RoomModel.h"
#import <RCVoiceRoomLib/RCVoiceRoomInfo.h>

NS_ASSUME_NONNULL_BEGIN

@interface CreateRoomModel : RoomModel

@property (nonatomic, assign) NSInteger identifier;
@property (nonatomic, assign) BOOL isStop;

@end

@interface RCRoomCreateInfo : NSObject
@property (nonatomic, copy) RCVoiceRoomInfo *roomInfo;
@property (nonatomic, copy) NSString *roomId;

@end

NS_ASSUME_NONNULL_END
