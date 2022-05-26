//
//  ViewController.m
//  RCVoiceRoomDemo
//
//  Created by 彭蕾 on 2022/5/19.
//

#import "ViewController.h"
#import "WebService.h"
#import <RongIMLib/RongIMLib.h>
#import "RCRoomListController.h"
#import "RCPKStatusMessage.h"

@interface ViewController ()

@end

__attribute__((unused)) static NSString * _deviceID() {
    
    static NSString *did = nil;
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        did = [[UIDevice currentDevice] identifierForVendor].UUIDString;
    });

    return did;
}


@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (IBAction)loginIMInit:(id)sender {
    NSString *phone = LoginPhoneNumber;
    NSString *userName = [NSString stringWithFormat:@"用户%@", phone];
    [WebService loginWithPhoneNumber:phone
                          verifyCode:@"123456"
                            deviceId:_deviceID()
                            userName:userName
                            portrait:nil
                       responseClass:[LoginResponseData class]
                             success:^(id  _Nullable responseObject) {
        Log(@"login success");
        [SVProgressHUD showSuccessWithStatus:[NSString stringWithFormat:@"登录成功，当前用户%@", phone]];


        LoginResponseData *res = ((RCResponseModel *)responseObject).data;
        WebService.shareInstance.auth = res.authorization;
        
        UserModel *currentUser = [UserModel new];
        currentUser.userId = res.userId;
        currentUser.userName = res.userName;
        currentUser.portrait = res.portrait;
        
        [UserManager sharedManager].currentUser = currentUser;
        
        [self initIMWithToken:res.imToken];
    }
                             failure:^(NSError * _Nonnull error) {
        Log(@"login failed");
        [SVProgressHUD showInfoWithStatus:@"登录失败"];
    }];
}

- (void)initIMWithToken:(NSString *)token {
    [[RCIMClient sharedRCIMClient] initWithAppKey:AppKey];
    [self registerMessageType];
    [[RCIMClient sharedRCIMClient] connectWithToken:token
                                          timeLimit:5
                                           dbOpened:^(RCDBErrorCode code) {
        //消息数据库打开，可以进入到主页面
    } success:^(NSString *userId) {
        // 初始化成功
        Log(@"voice sdk initializ success");
        [SVProgressHUD showSuccessWithStatus:[NSString stringWithFormat:@"IM初始化成功，当前id%@", userId]];

    } error:^(RCConnectErrorCode status) {
        // 初始化失败
        Log(@"voice sdk initializ fail %ld",(long)status);
        if (status == RC_CONN_TOKEN_INCORRECT) {
            //token 非法，从 APP 服务获取新 token，并重连
        } else if(status == RC_CONNECT_TIMEOUT) {
            //连接超时，弹出提示，可以引导用户等待网络正常的时候再次点击进行连接
        } else {
            //无法连接 IM 服务器，请根据相应的错误码作出对应处理
        }
        
        [SVProgressHUD showInfoWithStatus:@"IM初始化失败"];
    }];
}

/// 注册messageType
- (void)registerMessageType {
    [[RCIMClient sharedRCIMClient] registerMessageType:[RCPKStatusMessage class]];
}


- (IBAction)enterRoomList:(id)sender {
    RCRoomListController *vc = [RCRoomListController new];
    [self.navigationController pushViewController:vc animated:YES];
}

- (IBAction)enterRoom:(id)sender {
    
}

@end

@implementation LoginResponse
@end

@implementation LoginResponseData
@end
