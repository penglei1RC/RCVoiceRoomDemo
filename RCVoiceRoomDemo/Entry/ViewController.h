//
//  ViewController.h
//  RCVoiceRoomDemo
//
//  Created by 彭蕾 on 2022/5/19.
//

#import <UIKit/UIKit.h>

@class LoginResponse;
@class LoginResponseData;

@interface ViewController : UIViewController

@end

@interface LoginResponse : NSObject
@property (nonatomic, assign) NSInteger code;
@property (nonatomic, strong) LoginResponseData *data;
@end


@interface LoginResponseData : NSObject
@property (nonatomic, copy)   NSString *userId;
@property (nonatomic, copy)   NSString *userName;
@property (nonatomic, copy)   NSString *portrait;
@property (nonatomic, assign) NSInteger type;
@property (nonatomic, copy)   NSString *authorization;
@property (nonatomic, copy)   NSString *imToken;
@end
