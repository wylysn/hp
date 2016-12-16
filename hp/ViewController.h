//
//  ViewController.h
//  hp
//
//  Created by wangyilu on 16/5/31.
//  Copyright © 2016年 ___PURANG___. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ListenSocketServer.h"

@interface ViewController : UIViewController<ListenSocketDelegate>

@property (strong, nonatomic) ListenSocketServer *listenSocketServer;

@end

