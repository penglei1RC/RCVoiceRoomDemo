//
//  UserManager.h
//  RCVoiceRoomDemo
//
//  Created by 彭蕾 on 2022/5/23.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface UserManager : NSObject

@property (nonatomic, strong) UserModel *currentUser;

+ (UserManager *)sharedManager;

@end

NS_ASSUME_NONNULL_END
