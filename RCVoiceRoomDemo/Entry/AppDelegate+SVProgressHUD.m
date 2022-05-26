//
//  AppDelegate+SVProgressHUD.m
//  RCVoiceRoomDemo
//
//  Created by 彭蕾 on 2022/5/20.
//

#import "AppDelegate+SVProgressHUD.h"
#import "SceneDelegate.h"

@implementation AppDelegate (SVProgressHUD)
- (UIWindow *)window {
    UIWindowScene *scene = (UIWindowScene *)UIApplication.sharedApplication.connectedScenes.allObjects.firstObject;

    SceneDelegate *sceneDelegate = (SceneDelegate *)scene.delegate;
    return sceneDelegate.window ?: nil;
}

@end
