//
//  RCPKView.m
//  RCVoiceRoomDemo
//
//  Created by 彭蕾 on 2022/5/26.
//

#import "RCPKView.h"

@interface RCPKView ()<UICollectionViewDelegate, UICollectionViewDataSource>

@property (nonatomic, strong) UICollectionView *collectionView;
@property (nonatomic, strong) NSArray<UserModel *> *users;
@property (nonatomic, assign) BOOL isHost;

@end

@class RCPKUserInfoCell;
static NSString *pkUserCellIdentifier = @"RCPKUserInfoCell";
@implementation RCPKView
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
- (void)reloadData:(NSArray<UserModel *> *)users {
    if (!users || users.count == 0) {
        return ;
    }
    self.users = users;
    [self.collectionView reloadData];
}

#pragma mark - collectionView
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.users.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    RCPKUserInfoCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:pkUserCellIdentifier forIndexPath:indexPath];
    [cell updateCell:self.users[indexPath.row]];
    return cell;
}

#pragma mark - lazy load
- (UICollectionView *)collectionView {
    if (!_collectionView) {
        UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
        layout.itemSize = CGSizeMake(160, 90);
        layout.minimumInteritemSpacing = 15;
        layout.minimumLineSpacing = 15;
        layout.scrollDirection = UICollectionViewScrollDirectionVertical;
        _collectionView = [[UICollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:layout];
        [_collectionView registerClass:[RCPKUserInfoCell class] forCellWithReuseIdentifier:pkUserCellIdentifier];
        _collectionView.delegate = self;
        _collectionView.dataSource = self;
        _collectionView.backgroundColor = [UIColor clearColor];
        _collectionView.contentInset = UIEdgeInsetsMake(0, 20, 0, 20);
    }
    return _collectionView;
}

@end

@interface RCPKUserInfoCell ()

@property (nonatomic, strong) UIImageView *avatarImageView;
@property (nonatomic, strong) UILabel *nameLabel;
@property (nonatomic, strong) UILabel *idLabel;

@end

@implementation RCPKUserInfoCell
- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self.contentView addSubview:self.avatarImageView];
        [self.contentView addSubview:self.nameLabel];
        [self.contentView addSubview:self.idLabel];
        
        [self.avatarImageView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.contentView);
            make.centerX.equalTo(self.contentView);
            make.size.equalTo(@(CGSizeMake(56, 56)));
        }];
        
        [self.nameLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.avatarImageView.mas_bottom).offset(2);
            make.left.right.equalTo(self.contentView);
        }];
        
        [self.idLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.right.bottom.equalTo(self.contentView);
        }];

    }
    return self;
}

- (void)updateCell:(UserModel *)userInfo {
    self.nameLabel.text = userInfo.userName;
    self.idLabel.text = userInfo.userId;
}

- (UIImageView *)avatarImageView {
    if (!_avatarImageView) {
        _avatarImageView = [[UIImageView alloc] init];
        _avatarImageView.layer.cornerRadius = 28;
        _avatarImageView.clipsToBounds = YES;
        _avatarImageView.image = [UIImage imageNamed:@"avatar1"];
    }
    return _avatarImageView;
}

- (UILabel *)nameLabel {
    if (!_nameLabel) {
        _nameLabel = [[UILabel alloc] init];
        _nameLabel.textColor = [UIColor whiteColor];
        _nameLabel.font = [UIFont systemFontOfSize:12 weight: UIFontWeightRegular];
        _nameLabel.textAlignment = NSTextAlignmentCenter;
    }
    return _nameLabel;
}

- (UILabel *)idLabel {
    if (!_idLabel) {
        _idLabel = [[UILabel alloc] init];
        _idLabel.textColor = [UIColor whiteColor];
        _idLabel.font = [UIFont systemFontOfSize:12 weight: UIFontWeightRegular];
        _idLabel.textAlignment = NSTextAlignmentCenter;
    }
    return _idLabel;
}

@end
