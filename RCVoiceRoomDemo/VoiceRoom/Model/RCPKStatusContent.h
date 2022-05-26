//
//  RCPKStatusContent.h
//  RCVoiceRoomDemo
//
//  Created by 彭蕾 on 2022/5/25.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN
@class RCPKRoomScore;

@interface RCPKStatusContent : NSObject

@property (nonatomic, copy) NSString *stopPkRoomId;
@property (nonatomic, assign) NSInteger statusMsg; //pk 状态,0:PK中,1:惩罚中，2:PK结束
@property (nonatomic, assign) NSInteger timeDiff;
@property (nonatomic, strong) NSArray<RCPKRoomScore *> *roomScores;

@end

@interface RCPKRoomScore : NSObject

@property (nonatomic, copy) NSString *roomId;
@property (nonatomic, assign) NSInteger score;
@property (nonatomic, copy) NSString *userId;

@end

NS_ASSUME_NONNULL_END
