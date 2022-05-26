//
//  RCSeatsView.h
//  RCVoiceRoomDemo
//
//  Created by 彭蕾 on 2022/5/23.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

typedef void(^RCSeatsViewHandler) (RCVoiceSeatInfo *seatInfo, NSUInteger idx);
/// 座位信息视图
@interface RCSeatsView : UIView

@property (nonatomic, copy) RCSeatsViewHandler handler;

- (instancetype)initWithCreate:(BOOL)isHost;
- (void)reloadData:(NSArray<RCVoiceSeatInfo *> *)seats;

@end

NS_ASSUME_NONNULL_END
