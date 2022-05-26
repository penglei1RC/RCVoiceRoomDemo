//
//  RCRoomListPresenter.h
//  RCVoiceRoomDemo
//
//  Created by 彭蕾 on 2022/5/20.
//

#import <Foundation/Foundation.h>
#import "RoomListModel.h"
#import "CreateRoomModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface RCRoomListPresenter : NSObject

@property (nonatomic, copy, readonly) NSArray<RoomListRoomModel *> *dataModels;

- (void)fetchRoomListWithCompletionBlock:(void(^)(RCResponseType type))completionBlock;

- (void)createRoomWithCompletionBlock:(void(^)(RCRoomCreateInfo * _Nullable createInfo))completionBlock;

@end

NS_ASSUME_NONNULL_END
