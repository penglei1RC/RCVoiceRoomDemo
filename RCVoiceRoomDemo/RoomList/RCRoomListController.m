//
//  RCRoomListController.m
//  RCVoiceRoomDemo
//
//  Created by 彭蕾 on 2022/5/20.
//

#import "RCRoomListController.h"
#import "RCRoomListPresenter.h"
#import "RCRoomListCell.h"
#import "RCVoiceRoomController.h"

@interface RCRoomListController ()<UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) RCRoomListPresenter *presenter;

@end

static NSString * const roomCellIdentifier = @"RCRoomListCell";

@implementation RCRoomListController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self UIConfig];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [self.presenter fetchRoomListWithCompletionBlock:^(RCResponseType type) {
        switch (type) {
            case RCResponseTypeNormal:
                [self.tableView reloadData];
                break;
                
            default:
                break;
        }
    }];
}

- (void)UIConfig {
    self.view.backgroundColor = [UIColor whiteColor];
    self.title = [UserManager sharedManager].currentUser.userName;
    
    UIBarButtonItem *rightItem = [[UIBarButtonItem alloc] initWithTitle:@"新建房间"
                                                                  style:UIBarButtonItemStylePlain
                                                                 target:self
                                                                 action:@selector(createRoom)];
    self.navigationItem.rightBarButtonItem = rightItem;
    
    [self.view addSubview:self.tableView];
    [self.tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.mas_equalTo(0);
    }];
    
}

#pragma mark - room operation
- (void)createRoom {
    [self.presenter createRoomWithCompletionBlock:^(RCRoomCreateInfo * _Nullable createInfo) {
        if (!createInfo) {
            return ;
        }
        RCVoiceRoomController *roomVC = [[RCVoiceRoomController alloc] initWithCreateAndJoinRoomId:createInfo.roomId
                                                                                          roomInfo:createInfo.roomInfo];
        [self.navigationController pushViewController:roomVC animated:YES];
    }];
}

#pragma mark - UITabelView
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.presenter.dataModels.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    RCRoomListCell *cell = [tableView dequeueReusableCellWithIdentifier:roomCellIdentifier];
    RoomListRoomModel *room = self.presenter.dataModels[indexPath.row];
    [cell updateCellWithName:room.roomName roomId:room.roomId];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    RoomListRoomModel *room = self.presenter.dataModels[indexPath.row];
    RCVoiceRoomController *roomVC = [[RCVoiceRoomController alloc] initWithJoinRoomId:room.roomId];
    [self.navigationController pushViewController:roomVC animated:YES];
}

#pragma mark - lazy load
- (UITableView *)tableView {
    if (!_tableView) {
        _tableView = [UITableView new];
        _tableView.delegate = (id)self;
        _tableView.dataSource = (id)self;
        _tableView.rowHeight = UITableViewAutomaticDimension;
        _tableView.estimatedRowHeight = 220;
        [_tableView registerClass:[RCRoomListCell class] forCellReuseIdentifier:roomCellIdentifier];
    }
    return _tableView;
}

- (RCRoomListPresenter *)presenter {
    if (!_presenter) {
        _presenter = [RCRoomListPresenter new];
    }
    return _presenter;
}

@end
