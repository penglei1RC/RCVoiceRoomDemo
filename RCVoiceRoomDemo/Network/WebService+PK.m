//
//  WebService+PK.m
//  RCVoiceRoomDemo
//
//  Created by 彭蕾 on 2022/5/24.
//

#import "WebService+PK.h"

@implementation WebService (PK)

+ (void)pk_roomOnlineCreatedListWithResponseClass:(nullable Class)responseClass
                                          success:(nullable SuccessCompletion)success
                                          failure:(nullable FailureCompletion)failure {
    [self GET:np_fetch_online_creator parameters:@{@"roomType":@(1)} auth:YES responseClass:responseClass success:success failure:failure];
}


+ (void)pk_syncPKStateWithRoomId:(NSString *)roomId
                          status:(NSInteger)status
                        toRoomId:(NSString *)toRoomId
                   responseClass:(nullable Class)responseClassm
                         success:(nullable SuccessCompletion)success
                         failure:(nullable FailureCompletion)failure {
    NSDictionary *params = @{@"roomId":roomId, @"status":@(status), @"toRoomId":toRoomId};
    [self POST:np_sync_pk_state parameters:params auth:YES responseClass:responseClassm success:success failure:failure];
}

+ (void)pk_checkRoomType:(NSString *)roomId
           responseClass:(nullable Class)responseClassm
                 success:(nullable SuccessCompletion)success
                 failure:(nullable FailureCompletion)failure {
    NSString *path = [NSString stringWithFormat:np_check_room_type_isPk, roomId];
    [self GET:path parameters:nil auth:YES responseClass:responseClassm success:success failure:failure];
}

+ (void)pk_fetchPKDetail:(NSString *)roomId
           responseClass:(nullable Class)responseClassm
                 success:(nullable SuccessCompletion)success
                 failure:(nullable FailureCompletion)failure {
    NSString *path = [NSString stringWithFormat:np_fetch_pk_detail, roomId];
    [self GET:path parameters:nil auth:YES responseClass:responseClassm success:success failure:failure];
}


@end
