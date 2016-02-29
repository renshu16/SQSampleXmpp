//
//  ChatDetailVC.m
//  SimpleXmpp
//
//  Created by ToothBond on 15/9/17.
//  Copyright (c) 2015年 ToothBond. All rights reserved.
//

#import "ChatDetailVC.h"
#import "AppDelegate.h"
#import "Public.h"
#import "TBXmppManager.h"


@interface ChatDetailVC ()
{
    NSString *_bareJid;
    
    UITableView *mainTable;
    CGRect mainFrame;
    UIView *bottomBar;
    CGRect bottomFrame;
    UITextField *inputText;
    CGFloat keyboardHeight;
    NSFetchedResultsController *_fetchedResultController;
}

@end

@implementation ChatDetailVC

-(AppDelegate *)appDelegate
{
    return [[UIApplication sharedApplication] delegate];
}

-(id)initWithJid:(NSString *)jid
{
    self = [super init];
    if (self) {
        _bareJid = jid;
    }
    return self;
}


-(void)viewDidLoad
{
    [super viewDidLoad];
    self.title = _bareJid;
    
    [self initViews];
    [self initNotify];
    
    [self setupFetchedResultController];
}

-(void)dealloc
{
    [self unInitNotify];
}

-(void)initNotify
{
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillShown:)
                                                 name:UIKeyboardWillShowNotification
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillHide:)
                                                 name:UIKeyboardWillHideNotification
                                               object:nil];
    
}
-(void)unInitNotify
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillHideNotification object:nil];
}

-(void)initViews
{
    mainFrame = CGRectMake(0, 0, ScreenWidth, ScreenHeight - 44);
    mainTable = [[UITableView alloc]initWithFrame:mainFrame style:UITableViewStylePlain];
    mainTable.delegate = self;
    mainTable.dataSource = self;
    [self.view addSubview:mainTable];
    
    bottomFrame = CGRectMake(0, CGRectGetMaxY(mainTable.frame), ScreenWidth, 44);
    bottomBar = [[UIView alloc]initWithFrame:bottomFrame];
    bottomBar.backgroundColor = RGBCOLOR(237, 237, 237);
    [self.view addSubview:bottomBar];
    
    CGFloat btnWidth = 40;
    
    inputText = [[UITextField alloc]initWithFrame:CGRectMake(kPadding, 2, bottomBar.frame.size.width - btnWidth - 3*kPadding, 40)];
    [inputText setBorderStyle:UITextBorderStyleRoundedRect];
    [inputText setDelegate:self];
    
    UIButton *addFileBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    addFileBtn.frame = CGRectMake(CGRectGetMaxX(inputText.frame) + kPadding, 2, btnWidth, btnWidth);
    [addFileBtn setImage:[UIImage imageNamed:@"TypeSelectorBtn_Black"] forState:UIControlStateNormal];
    [addFileBtn setImage:[UIImage imageNamed:@"TypeSelectorBtnHL_Black"] forState:UIControlStateHighlighted];
    [addFileBtn addTarget:self action:@selector(addFileAction:) forControlEvents:UIControlEventTouchUpInside];
    [bottomBar addSubview:addFileBtn];
    
    [bottomBar addSubview:inputText];
}

-(void)setupFetchedResultController
{
    //数据存储上下文；定义查询请求； 定义排序； 定义查询条件(谓词，NSPredicate)； 实例化查询结果控制器
    NSManagedObjectContext *context = [[[TBXmppManager sharedInstance] xmppMessageArchivingCoreDataStorage] mainThreadManagedObjectContext];
    
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"XMPPMessageArchiving_Message_CoreDataObject"];
    
    NSSortDescriptor *sort = [NSSortDescriptor sortDescriptorWithKey:@"timestamp" ascending:YES];
    
    NSString *bareJidStr = _bareJid;
    NSString *myJidStr = [[LoginUser sharedLoginUser] myJIDName];
    request.predicate = [NSPredicate predicateWithFormat:@"bareJidStr CONTAINS[cd] %@ AND streamBareJidStr CONTAINS[cd] %@",bareJidStr, myJidStr];
    [request setSortDescriptors:@[sort]];
    
    _fetchedResultController = [[NSFetchedResultsController alloc]initWithFetchRequest:request managedObjectContext:context sectionNameKeyPath:nil cacheName:nil];
    
    _fetchedResultController.delegate = self;
    
    NSError *error = nil;
    if (![_fetchedResultController performFetch:&error]) {
        NSLog(@"查询数据出错 - %@", error.localizedDescription);
    }else{
        //查询成功
    }
    
}

-(void)scrollToBottom
{
    id <NSFetchedResultsSectionInfo> info = _fetchedResultController.sections[0];
    NSInteger count = [info numberOfObjects];
    if (count <= 0) return;
    
    NSIndexPath *indexpath = [NSIndexPath indexPathForRow:count-1 inSection:0];
    
    [mainTable scrollToRowAtIndexPath:indexpath atScrollPosition:UITableViewScrollPositionBottom animated:YES];
}

#pragma mark - FetchedResultControllerDelegate
-(void)controllerDidChangeContent:(NSFetchedResultsController *)controller
{
    [mainTable reloadData];
}

#pragma mark - Notifycation Keyborad
-(void)keyboardWillShown:(NSNotification *)notification
{
    NSLog(@"软键盘显示 %@", notification.userInfo);
    NSDictionary * userInfo = [notification userInfo];
    CGRect bounds;
    [(NSValue *)[userInfo objectForKey:UIKeyboardFrameEndUserInfoKey] getValue:&bounds];
    CGFloat keyboardH = bounds.size.height;
    keyboardHeight = keyboardH;
    
    [self scrollToBottom];
    [UIView animateWithDuration:0.3 delay:0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
        mainTable.frame = CGRectMake(mainTable.frame.origin.x, mainTable.frame.origin.y, mainTable.frame.size.width, mainFrame.size.height - keyboardH);
        
        bottomBar.frame = CGRectMake(bottomBar.frame.origin.x, bottomFrame.origin.y - keyboardH, bottomBar.frame.size.width, bottomBar.frame.size.height);
    } completion:nil];
    
}
-(void)keyboardWillHide:(NSNotification *)notification
{
    NSLog(@"软键盘将要隐藏 %@", notification.userInfo);
    NSLog(@"软键盘已经隐藏 %@", notification.userInfo);
    [UIView animateWithDuration:0.3 delay:0.1 options:UIViewAnimationOptionCurveEaseInOut animations:^{
        mainTable.frame = mainFrame;
        bottomBar.frame = bottomFrame;
    } completion:nil];
}

#pragma mark - TableViewDelegate
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    id <NSFetchedResultsSectionInfo> info = _fetchedResultController.sections [section];
    return [info numberOfObjects];
}

-(UITableViewCell *)tableView:tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    XMPPMessageArchiving_Message_CoreDataObject *message = [_fetchedResultController objectAtIndexPath:indexPath];
    
    static NSString *identify = @"cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identify];
    if (cell == nil) {
        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:identify];
    }
    if (message.isOutgoing) {
        cell.textLabel.text = [[LoginUser sharedLoginUser]myJIDName];
        [cell.detailTextLabel setTextAlignment:NSTextAlignmentLeft];
        [cell.textLabel setTextAlignment:NSTextAlignmentLeft];
    }else{
        cell.textLabel.text = message.bareJidStr;
        [cell.textLabel setTextAlignment:NSTextAlignmentRight];
        [cell.detailTextLabel setTextAlignment:NSTextAlignmentRight];
    }
    
    cell.detailTextLabel.text = message.body;
    return cell;
}

#pragma mark - ScrollViewDelegate
-(void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    [inputText resignFirstResponder];
}

#pragma mark - UIImagePickerDelegate
-(void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    UIImage *image = info[UIImagePickerControllerEditedImage];
    [self dismissViewControllerAnimated:YES completion:^{
        
        //1.将图片Base64编码为NSString进行传输
        //发送文件Message
        XMPPMessage *fileMessage = [XMPPMessage messageWithType:@"myImageData" to:[XMPPJID jidWithString:_bareJid]];
        
        NSData *data = UIImagePNGRepresentation(image);
        NSString *msgStr = [data base64EncodedStringWithOptions:NSDataBase64Encoding64CharacterLineLength];
        
        NSXMLElement *fileElement = [NSXMLElement elementWithName:@"imageData" stringValue:msgStr];
        [fileMessage addChild:fileElement];
        [[TBXmppManager sharedInstance] sendXmppMessage:fileMessage];
        NSLog(@"fileMessage -- %@",fileMessage);
        
        //2.上传图片到文件服务器，通过图片的url进行传输
        
        
        
        /*
         自定义message
        <message type="myImageData" to="rensq@192.168.1.25">
        <imageData>iVBORw0KG</imageData>
        </message>
        
         官方xmpp Message
        <message
        xmlns="jabber:client" type="chat" id="purple46cbc480" to="zhangsan@192.168.1.25" from="rensq@192.168.1.25/wjmac">
        <active xmlns="http://jabber.org/protocol/chatstates"/>
        <body>222222222222</body>
        </message>
         */
        
    }];
}

#pragma mark - Action
-(void)addFileAction:(UIButton *)btn
{
    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypePhotoLibrary]) {
        UIImagePickerController *picker = [[UIImagePickerController alloc] init];
        //picker.allowsEditing = YES;
        picker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
        [picker setDelegate:self];
        [self presentViewController:picker animated:YES completion:nil];
    }
}

#pragma mark - UITextField
-(BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    NSString *text = [textField.text trimString];
    
    NSString *toJidStr = _bareJid;
    XMPPMessage *message = [XMPPMessage messageWithType:@"chat" to:[XMPPJID jidWithString:toJidStr]];
    [message addBody:text];
    
    [[[TBXmppManager sharedInstance] xmppStream] sendElement:message];
    
    textField.text = @"";
    return YES;
}



@end
