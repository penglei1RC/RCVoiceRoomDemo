//
//  RCSeatCollectionViewCell.h
//  RCVoiceRoomDemo
//
//  Created by 彭蕾 on 2022/5/23.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

/// 单个座位
@interface RCSeatInfoCell : UICollectionViewCell

- (void)updateCell:(RCVoiceSeatInfo *)seatInfo withSeatIndex:(NSUInteger)index;

@end

NS_ASSUME_NONNULL_END
