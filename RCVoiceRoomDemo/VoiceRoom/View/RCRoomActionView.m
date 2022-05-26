//
//  RCRoomActionView.m
//  RCVoiceRoomDemo
//
//  Created by 彭蕾 on 2022/5/23.
//

#import "RCRoomActionView.h"

@interface RCRoomActionView ()

@property (nonatomic, assign) BOOL isHost;
@property (nonatomic, strong) UIButton *pkButton;

@end

#define ROOM_BTN_ACTION_TAG (10000)
@implementation RCRoomActionView

- (instancetype)initWithCreate:(BOOL)isCreate {
    if (self = [super init]) {
        self.isHost = isCreate;
        [self UIConfig];
    }
    return self;
}

- (void)updateViewWithStatus:(BOOL)isPK role:(RCVoiceRoomPKRole )role {
    if (isPK && role != RCVoiceRoomPKRoleAudience) {
        self.pkButton.hidden = NO;
        self.pkButton.selected = YES;
    } else if (self.isHost) {
        self.pkButton.hidden = NO;
        self.pkButton.selected = NO;
    } else {
        self.pkButton.hidden = YES;
    }
    [self setNeedsLayout];
    [self layoutIfNeeded];
}

- (void)UIConfig {
    
    UIButton *requestListButton = [self actionButtonFactory:@"申请列表"
                                             withActionType:RCRoomActionTypeFetchRequestList];
    UIButton *userListButton = [self actionButtonFactory:@"用户列表"
                                          withActionType:RCRoomActionTypeFetchUserList];
    UIButton *cancelRequestButton = [self actionButtonFactory:@"取消上麦申请"
                                               withActionType:RCRoomActionTypeCancelRequest];
    UIButton *speakerEnableButton = [self actionButtonFactory:@"扬声器模式"
                                               withActionType:RCRoomActionTypeSpeakerEnable];
    [speakerEnableButton setTitle:@"听筒模式" forState:UIControlStateSelected];
    speakerEnableButton.selected = YES;
    UIButton *micDisableButton = [self actionButtonFactory:@"禁用麦克风"
                                            withActionType:RCRoomActionTypeMicDisable];
    [micDisableButton setTitle:@"打开麦克风" forState:UIControlStateSelected];
    
    NSArray *container1;
    if (self.isHost) {
        container1 = @[requestListButton,userListButton,speakerEnableButton,micDisableButton];
    } else {
        container1 = @[requestListButton,userListButton,cancelRequestButton];
    }
    UIStackView *stackView1 = [self stackViewWithViews:container1];
    [self addSubview:stackView1];
    [stackView1 mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.equalTo(self).offset(20);
        make.trailing.equalTo(self).offset(-20);
        make.bottom.mas_equalTo(self).offset(-60);
        make.height.mas_equalTo(60);
    }];
    
    UIButton *muteAllButton = [self actionButtonFactory:@"全员闭麦" withActionType:RCRoomActionTypeMuteAll];
    [muteAllButton setTitle:@"解除全员闭麦" forState:UIControlStateSelected];
    
    UIButton *lockAllButton = [self actionButtonFactory:@"全员锁麦" withActionType:RCRoomActionTypeLockAll];
    [lockAllButton setTitle:@"解除全员锁麦" forState:UIControlStateSelected];

    UIButton *silenceButton = [self actionButtonFactory:@"静音" withActionType:RCRoomActionTypeMuteRemote];
    [silenceButton setTitle:@"取消静音" forState:UIControlStateSelected];
    
    self.pkButton = [self actionButtonFactory:@"发起PK" withActionType:RCRoomActionTypePK];
    [self.pkButton setTitle:@"取消PK" forState:UIControlStateSelected];
    
    NSArray *container2;
    if (self.isHost) {
        container2 = @[muteAllButton,lockAllButton,silenceButton,self.pkButton];
    } else {
        container2 = @[speakerEnableButton,silenceButton,micDisableButton,self.pkButton];
    }
    UIStackView *stackView2 = [self stackViewWithViews:container2];
    [self addSubview:stackView2];

    [stackView2 mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.equalTo(self).offset(20);
        make.trailing.equalTo(self).offset(-20);
        make.top.mas_equalTo(stackView1.mas_bottom);
        make.height.mas_equalTo(60);
    }];
    
}

- (UIButton *)actionButtonFactory:(NSString *)title withActionType:(RCRoomActionType )type {
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    button.backgroundColor = [UIColor systemPinkColor];
    button.layer.cornerRadius = 6;
    button.titleLabel.font = [UIFont systemFontOfSize:14];
    [button setTitle:title forState: UIControlStateNormal];
    [button setTitleColor:[UIColor whiteColor] forState: UIControlStateNormal];
    button.tag = ROOM_BTN_ACTION_TAG + type;
    [button addTarget:self action:@selector(btnClicked:) forControlEvents:UIControlEventTouchUpInside];
    [[button.widthAnchor constraintGreaterThanOrEqualToConstant:70] setActive:YES];
    return button;
}

- (void)btnClicked:(UIButton *)btn {
    
    RCRoomActionType type = btn.tag - ROOM_BTN_ACTION_TAG;
    if (type != RCRoomActionTypePK) {
        btn.selected = !btn.isSelected;
    }
    !_hander ?: _hander(type, btn.isSelected);
}

- (UIStackView *)stackViewWithViews:(NSArray *)views {
    UIStackView *stackView = [[UIStackView alloc] initWithArrangedSubviews:views];
    stackView.axis = UILayoutConstraintAxisHorizontal;
    stackView.spacing = 10;
    stackView.alignment = UIStackViewAlignmentCenter;
    stackView.distribution = UIStackViewDistributionEqualSpacing;
    return stackView;
}

@end
