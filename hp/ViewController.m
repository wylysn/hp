//
//  ViewController.m
//  hupai
//
//  Created by wangyilu on 16/5/30.
//  Copyright © 2016年 ___PURANG___. All rights reserved.
//

#define CodeFieldTag 5

#import "ViewController.h"
#import "ConnectInfo.h"
#import "GCDAsyncSocket.h"
#import "UIView+Additions.h"

@interface ViewController ()<UITextFieldDelegate>
@property (weak, nonatomic) IBOutlet UILabel *selfIplabel;
//@property (weak, nonatomic) IBOutlet UILabel *connectnumLabel;
@property (weak, nonatomic) IBOutlet UIButton *connectnumBtn;

@property (weak, nonatomic) IBOutlet UIImageView *codeImage;

@property (weak, nonatomic) IBOutlet UITextField *codeField;
@property (weak, nonatomic) IBOutlet UILabel *connectAddress;

@end

@implementation ViewController {
    NSMutableArray *socketDicsArr;
    GCDAsyncSocket *socketinfo;
    UILabel *keyLeftLabel;
    BOOL numberlimit;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    socketDicsArr = [[NSMutableArray alloc] init];
    
    NSString *ipaddr = [ListenSocketServer getIPAddress:YES];
    self.selfIplabel.text = [NSString stringWithFormat:@"%@:%d",ipaddr,[ListenSocketServer getPort]];
    
    numberlimit = YES;
    
    self.listenSocketServer = [[ListenSocketServer alloc] init];
    self.listenSocketServer.delegate = self;
    [self.listenSocketServer start];
    
}

-(void)viewDidAppear:(BOOL)animated {
    
    self.codeField.keyboardType = UIKeyboardTypeNumberPad;
    self.codeField.autocorrectionType = UITextAutocorrectionTypeNo;
//    self.codeField.returnKeyType = UIReturnKeySend;
    self.codeField.inputAccessoryView = [self addToolbar];
    self.codeField.delegate = self;
    [self.codeField becomeFirstResponder];
    
}

- (void)socketcomeInOut:(int)flag {
    dispatch_async(dispatch_get_main_queue(), ^{
//        self.connectnumLabel.text = [NSString stringWithFormat:@"%ld", self.listenSocketServer.connectedSockets.count];
        [self.connectnumBtn setTitle:[NSString stringWithFormat:@"%ld", (unsigned long)self.listenSocketServer.connectedSockets.count] forState:UIControlStateNormal];
    });
    
}

- (void)displayPic:(NSString *)key {
    NSDictionary *dic = self.listenSocketServer.socketsDics[self.listenSocketServer.picOkArr[0]];
    
    if (self.codeImage.image == nil) {
        ConnectInfo *connectinfo = dic[@"connectinfo"];
        socketinfo = dic[@"socketinfo"];
//        NSData *_decodedImageData   = [[NSData alloc] initWithBase64EncodedString:connectinfo.pic1 options:0];
        self.connectAddress.text = [NSString stringWithFormat:@"%@:%hu", socketinfo.connectedHost, socketinfo.connectedPort];
        self.codeImage.image = connectinfo.pic1;//[UIImage imageWithData:_decodedImageData];
    } else {
        if ([self.connectAddress.text isEqualToString:[NSString stringWithFormat:@"%@:%hu", socketinfo.connectedHost, socketinfo.connectedPort]]) {
            ConnectInfo *connectinfo = dic[@"connectinfo"];
            socketinfo = dic[@"socketinfo"];
//            NSData *_decodedImageData   = [[NSData alloc] initWithBase64EncodedString:connectinfo.pic1 options:0];
            self.codeImage.image = connectinfo.pic1;//[UIImage imageWithData:_decodedImageData];
        }
    }
    keyLeftLabel.text = [NSString stringWithFormat:@"%ld", (unsigned long)self.listenSocketServer.picOkArr.count];
}

- (void) textFieldDone {
    NSString *code = self.codeField.text;
    if (self.codeImage.image == nil || !(numberlimit?(code.length==4||[@"" isEqualToString:code]):YES)) {
        return;
    }
    dispatch_async(dispatch_get_main_queue(), ^{
        if (socketinfo && socketinfo.isConnected) {
            NSString *echoMsg = [NSString stringWithFormat:@"YZM%@\r\n", [@"" isEqualToString:code]?@"NULL":self.codeField.text];//;
            NSData *echoData = [echoMsg dataUsingEncoding:NSUTF8StringEncoding];
            [socketinfo writeData:echoData withTimeout:-1 tag:1];
        }
        NSLog(@"您输入的是%@", self.codeField.text);
        self.codeField.text = @"";
        self.connectAddress.text = @"";
        self.codeImage.image = nil;
        
        if (self.listenSocketServer.picOkArr.count>0) {
            [self.listenSocketServer.picOkArr removeObjectAtIndex:0];
            if (self.listenSocketServer.picOkArr.count>0) {
                NSString *arrkey = self.listenSocketServer.picOkArr[0];
                NSDictionary *dic = self.listenSocketServer.socketsDics[arrkey];
                socketinfo = dic[@"socketinfo"];
                ConnectInfo *connectinfo = dic[@"connectinfo"];
//                NSData *_decodedImageData   = [[NSData alloc] initWithBase64EncodedString:connectinfo.pic1 options:0];
                self.connectAddress.text = [NSString stringWithFormat:@"%@:%@", connectinfo.IP, connectinfo.port];
                self.codeImage.image = connectinfo.pic1;//[UIImage imageWithData:_decodedImageData];
                if (!(socketinfo && socketinfo.isConnected)) {
                    [self.listenSocketServer.socketsDics removeObjectForKey:arrkey];
                }
            }
        }
        
        keyLeftLabel.text = [NSString stringWithFormat:@"%ld", (unsigned long)self.listenSocketServer.picOkArr.count];
    });
}

- (UIToolbar *)addToolbar
{
    UIToolbar *toolbar = [[UIToolbar alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(self.view.frame), 44)];
    toolbar.tintColor = [UIColor clearColor];
    toolbar.backgroundColor = [UIColor grayColor];
    UIBarButtonItem *space1 = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
    UIBarButtonItem *space2 = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
//    UIBarButtonItem *bar = [[UIBarButtonItem alloc] initWithTitle:@"完成" style:UIBarButtonItemStyleDone target:self action:@selector(textFieldDone)];
//    UIBarButtonItem *bar = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"send"] style:UIBarButtonItemStylePlain target:self action:@selector(textFieldDone)];
    
    
    UIView *centerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 30, 34)];
    keyLeftLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 30, 34)];
    keyLeftLabel.textAlignment = NSTextAlignmentCenter;
    keyLeftLabel.textColor = [UIColor grayColor];
    [centerView addSubview:keyLeftLabel];
    keyLeftLabel.text = @"0";
    UIBarButtonItem *centerbar = [[UIBarButtonItem alloc] initWithCustomView:centerView];
    
    UISwitch *oneSwitch = [[UISwitch alloc] initWithFrame:CGRectMake(0, 1, 0, 0)]; // 默认尺寸为79 * 27。
//    oneSwitch.backgroundColor = [UIColor greenColor]; // 设置背景色
    oneSwitch.alpha = 1.0; // 设置透明度 范围在0.0-1.0之间 0.0是完全透明
//    oneSwitch.onTintColor = [UIColor redColor]; // 在oneSwitch开启的状态显示的颜色 默认是blueColor
    oneSwitch.tintColor = [UIColor whiteColor]; // 设置关闭状态的颜色
//    oneSwitch.thumbTintColor = [UIColor blueColor]; // 设置开关上左右滑动的小圆点的颜色
    // oneSwitch.on = YES; // // 设置初始状态 直接设置为on，你不回观察到它的变化
    [oneSwitch setOn:YES animated:YES]; // 设置初始状态，与上面的不同是当你看到这个控件的时候再开始设置为on，你会观察到他的变化
    [oneSwitch addTarget:self action:@selector(oneSwitchValueChanged:) forControlEvents:UIControlEventValueChanged];
    UIBarButtonItem *onoffbar = [[UIBarButtonItem alloc] initWithCustomView:oneSwitch];

    UIView *doneView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 90, 34)];
    UIButton *doneBtn = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 90, 34)];
    doneBtn.backgroundColor = [UIColor colorWithRed:199.0/255 green:57.0/255 blue:27.0/255 alpha:1];
    doneBtn.tintColor = [UIColor colorWithRed:255.0/255 green:255.0/255 blue:255.0/255 alpha:1];
    [doneBtn setTitle:@"发送" forState:UIControlStateNormal];
    doneBtn.layer.cornerRadius = 4;
    doneBtn.layer.masksToBounds = YES;
//    doneBtn.layer.borderWidth = 1.0;
//    doneBtn.layer.borderColor = [UIColor grayColor].CGColor;
//    doneBtn.layer.shadowColor = [UIColor colorWithRed:199.0/255 green:57.0/255 blue:27.0/255 alpha:1].CGColor;
//    doneBtn.layer.shadowOffset = CGSizeMake(5.0, 5.0);
//    doneBtn.layer.shadowOpacity = YES;
    [doneBtn addTarget:self action:@selector(textFieldDone) forControlEvents:UIControlEventTouchUpInside];
    [doneView addSubview:doneBtn];
    [doneView bringSubviewToFront:doneView];
    UIBarButtonItem *bar = [[UIBarButtonItem alloc] initWithCustomView:doneView];
    toolbar.items = @[onoffbar, space1, centerbar, space2, bar];
    return toolbar;
}

-(BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    if (range.location>3 && numberlimit && ![@"" isEqualToString:string]) {
        return NO;
    }
    return YES;
}

- (void)oneSwitchValueChanged:(UISwitch *) sender {
    numberlimit = sender.isOn ? YES : NO;
    if (numberlimit) {
        self.codeField.keyboardType = UIKeyboardTypeNumberPad;
    } else {
        self.codeField.keyboardType = UIKeyboardTypeNamePhonePad;
    }
    [self.codeField reloadInputViews];
}

- (IBAction)connectnumRefresh:(id)sender {
    @synchronized(self.listenSocketServer.connectedSockets) {
        NSInteger i;
        for (i=0;i<self.listenSocketServer.connectedSockets.count;i++) {
            if (!((GCDAsyncSocket *)self.listenSocketServer.connectedSockets[i]).isConnected) {
                [self.listenSocketServer.connectedSockets removeObjectAtIndex:i];
                i--;
            }
        }
    }
    [self.connectnumBtn setTitle:[NSString stringWithFormat:@"%ld", (unsigned long)self.listenSocketServer.connectedSockets.count] forState:UIControlStateNormal];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
