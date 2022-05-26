//
//  Define.h
//  ios-livevideosdk-quickdemo
//
//  Created by xuefeng on 2021/10/26.
//
#import <Foundation/Foundation.h>

static NSString *const LoginSuccessNotification = @"LoginSuccessNotificationIdentifier";

//融云官网申请的 app key
#define AppKey  (@"pvxdm17jpw7ar")

//请前往 https://rcrtc-api.rongcloud.net/code 获取 BusinessToken
#define BusinessToken  (<#BusinessToken#>)
//融云官网申请的账号
#define LoginPhoneNumber  (<#LoginPhoneNumber#>)

//主色调
#define mainColor [UIColor systemPinkColor]

//log
#ifdef DEBUG
#define Log(format, ...) do {                                             \
fprintf(stderr, "<%s : %d> %s\n",                                           \
[[[NSString stringWithUTF8String:__FILE__] lastPathComponent] UTF8String],  \
__LINE__, __func__);                                                        \
(NSLog)((format), ##__VA_ARGS__);                                           \
fprintf(stderr, "-------\n");                                               \
} while (0)
#else
#define Log(...){}
#endif

//LocalizedString
#define LocalizedString(x) \
[[NSBundle mainBundle] localizedStringForKey:x value:@"" table:nil]


#define kScreenWidth [UIScreen mainScreen].bounds.size.width

#define kScreenHeight [UIScreen mainScreen].bounds.size.height

//weak strong

#define WeakSelf(type) __weak __typeof__(type) weakSelf = type;

#define StrongSelf(type) __strong __typeof__(type) strongSelf = type;
