//
//  RCPKView.h
//  RCVoiceRoomDemo
//
//  Created by 彭蕾 on 2022/5/26.
//

#import <UIKit/UIKit.h>
#import "RCPKStatusModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface RCPKView : UIView

- (instancetype)initWithCreate:(BOOL)isHost;
- (void)reloadData:(NSArray<UserModel *> *)users;

@end


@interface RCPKUserInfoCell : UICollectionViewCell

- (void)updateCell:(UserModel *)userInfo;

@end

NS_ASSUME_NONNULL_END
