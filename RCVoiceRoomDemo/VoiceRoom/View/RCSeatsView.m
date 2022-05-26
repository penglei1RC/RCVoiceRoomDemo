//
//  RCSeatsView.m
//  RCVoiceRoomDemo
//
//  Created by 彭蕾 on 2022/5/23.
//

#import "RCSeatsView.h"
#import "RCSeatInfoCell.h"

@interface RCSeatsView ()<UICollectionViewDelegate, UICollectionViewDataSource>

@property (nonatomic, strong) UICollectionView *collectionView;
@property (nonatomic, strong) NSArray<RCVoiceSeatInfo *> *seats;
@property (nonatomic, assign) BOOL isHost;

@end
static NSString *seatCellIdentifier = @"RCSeatInfoCell";
@implementation RCSeatsView
- (instancetype)initWithCreate:(BOOL)isHost {
    if (self = [super init]) {
        self.isHost = isHost;
        [self UIConfig];
    }
    return self;
}

- (void)UIConfig {
    [self addSubview:self.collectionView];
    [self.collectionView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.mas_equalTo(0);
    }];
}

#pragma mark public methods
- (void)reloadData:(NSArray<RCVoiceSeatInfo *> *)seats {
    self.seats = seats;
    [self.collectionView reloadData];
}

#pragma mark - collectionView
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.seats.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    RCSeatInfoCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:seatCellIdentifier forIndexPath:indexPath];
    [cell updateCell:self.seats[indexPath.row] withSeatIndex:indexPath.row];
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    RCVoiceSeatInfo *info = self.seats[indexPath.row];
    !self.handler ?: self.handler(info ,indexPath.row);
}

#pragma mark - lazy load
- (UICollectionView *)collectionView {
    if (!_collectionView) {
        UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
        layout.itemSize = CGSizeMake(75, 75);
        layout.minimumInteritemSpacing = 15;
        layout.minimumLineSpacing = 15;
        layout.scrollDirection = UICollectionViewScrollDirectionVertical;
        _collectionView = [[UICollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:layout];
        [_collectionView registerClass:[RCSeatInfoCell class] forCellWithReuseIdentifier:seatCellIdentifier];
        _collectionView.delegate = self;
        _collectionView.dataSource = self;
        _collectionView.backgroundColor = [UIColor clearColor];
        _collectionView.contentInset = UIEdgeInsetsMake(0, 20, 0, 20);
    }
    return _collectionView;
}


@end
