//
//  RCRoomListPresenter.m
//  RCVoiceRoomDemo
//
//  Created by 彭蕾 on 2022/5/20.
//

#import "RCRoomListPresenter.h"
#import "CreateRoomModel.h"
#import <CommonCrypto/CommonDigest.h>

@interface RCRoomListPresenter()
@property (nonatomic, copy, readwrite) NSArray<RoomListRoomModel *> *dataModels;
@end

@implementation RCRoomListPresenter

- (instancetype)init {
    if (self = [super init]) {
        self.dataModels = @[];
    }
    return self;
}

- (void)fetchRoomListWithCompletionBlock:(void(^)(RCResponseType type))completionBlock {
    [WebService roomListWithSize:20
                            page:0
                            type:RoomTypeVoice
                   responseClass:[RoomListModel class]
                         success:^(id  _Nullable responseObject) {
        RCResponseModel *res = (RCResponseModel *)responseObject;
        if (res.code.integerValue != StatusCodeSuccess) {
            completionBlock(RCResponseTypeSeverError);
            [SVProgressHUD showErrorWithStatus:[NSString stringWithFormat:@"房间数据获取失败 code:%d",res.code.intValue]];
            return ;
        }
        
        RoomListModel *model = (RoomListModel *)res.data;
        self.dataModels = model.rooms;
        BOOL isNoData = (self.dataModels.count == 0);
        !completionBlock ?: completionBlock(isNoData ? RCResponseTypeNoData : RCResponseTypeNormal);
        
    } failure:^(NSError * _Nonnull error) {
        
        BOOL isOffline = NO; // 判断是否无网络
        !completionBlock ?: completionBlock(isOffline ? RCResponseTypeOffline : RCResponseTypeSeverError);
        [SVProgressHUD showErrorWithStatus:[NSString stringWithFormat:@"房间数据获取失败 code:%ld",(long)error.code]];
    }];
}

- (void)createRoomWithCompletionBlock:(void(^)(RCRoomCreateInfo * _Nullable createInfo))completionBlock {
    NSString *roomName = [self generateRoomName];
    NSString *password = @"d41d8cd98f00b204e9800998ecf8427e"; // 空字符串的MD5格式
    NSString *imageUrl = @"https://img2.baidu.com/it/u=2842763149,821152972&fm=26&fmt=auto";
    
    [WebService createRoomWithName:roomName
                         isPrivate:0
                     backgroundUrl:imageUrl
                   themePictureUrl:imageUrl
                          password:password
                              type:RoomTypeVoice
                                kv:@[]
                     responseClass:[CreateRoomModel class]
                           success:^(id  _Nullable responseObject) {
        if (!responseObject) {
            return ;
        }
        RCResponseModel *res = (RCResponseModel *)responseObject;
        if (res.data != nil) {
            [SVProgressHUD showSuccessWithStatus:(@"新建房间成功")];
            CreateRoomModel *model = (CreateRoomModel *)res.data;
            RCRoomCreateInfo *info = [self createRoomWithModel:model];
            !completionBlock ?: completionBlock(info);
        } else {
            [SVProgressHUD showErrorWithStatus:[NSString stringWithFormat:@"%@ code: %ld",@"新建房间失败",(long)res.code]];
            !completionBlock ?: completionBlock(nil);
        }
    } failure:^(NSError * _Nonnull error) {
        [SVProgressHUD showErrorWithStatus:[NSString stringWithFormat:@"%@ code: %ld",@"新建房间失败",(long)error.code]];
        !completionBlock ?: completionBlock(nil);
    }];
}

- (NSString *)md5:(NSString *)pwd {
    const char *cStr = [pwd UTF8String];
    unsigned char digest[CC_MD5_DIGEST_LENGTH];
    
    CC_MD5(cStr, (CC_LONG)strlen(cStr), digest);
    
    NSMutableString *result = [NSMutableString stringWithCapacity:CC_MD5_DIGEST_LENGTH * 2];
    for (int i = 0; i < CC_MD5_DIGEST_LENGTH; i++) {
        [result appendFormat:@"%02X", digest[i]];
    }
    
    return result;
}


#pragma mark - private method
- (RCRoomCreateInfo *)createRoomWithModel:(CreateRoomModel *)model {
    RCVoiceRoomInfo *roomInfo = [RCVoiceRoomInfo new];
    
    roomInfo.roomName = model.roomName;
        
    // 设置9个麦位
    roomInfo.seatCount = 9;
    
    //非自由麦，上麦需要申请
    roomInfo.isFreeEnterSeat = NO;
    
    RCRoomCreateInfo *createInfo = [RCRoomCreateInfo new];
    createInfo.roomId = model.roomId;
    createInfo.roomInfo = roomInfo;
    
    return createInfo;
}


- (NSString *)generateRoomName {
    NSDate *date = [NSDate date];
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"MM-dd HH:mm:ss"];
    NSString *userName = [UserManager sharedManager].currentUser.userName;
    NSString *dateString = [formatter stringFromDate:date];
    NSString *roomName = [NSString stringWithFormat:@"%@ %@", userName, dateString];
    return roomName;
}

@end
