//
//  ZCCoreTextView.m
//  ZC
//
//  Created by 张程 on 15/5/4.
//
//  功用：图文混排，文字支持点击，分段变色、改字体大小，设置行间距

#import "ZCCoreTextView.h"
//#import "ASIHTTPRequest.h"
//#import "ZCBBSPersonalInformationController.h"
//#import "ZCBBSTopicViewController.h"

@interface ZCCoreTextView ()<UIGestureRecognizerDelegate>

@property (nonatomic, assign) CGContextRef context;

@property (nonatomic, strong) NSMutableArray *isLoadImageArray;
@property (nonatomic, strong) NSMutableArray *imageArray;

@property (nonatomic, strong) ZCBBSCoreTextLinkData *linkData;

@end

@implementation ZCCoreTextView

- (void)dealloc
{
    self.backgroundColor = [UIColor clearColor];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (id)initWithFrame:(CGRect)frame WithData:(ZCBBSCoreTextData *)data {
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor whiteColor];
        [self setupEvents];
        self.data = data;
        [self requestImage];
    }
    return self;
}


- (void)drawRect:(CGRect)rect
{
    [super drawRect:rect];
    if (self.data == nil) {
        return;
    }
    
    self.context = UIGraphicsGetCurrentContext();
    CGContextSetTextMatrix(self.context, CGAffineTransformIdentity);
    CGContextTranslateCTM(self.context, 0, self.bounds.size.height);
    CGContextScaleCTM(self.context, 1.0, -1.0);
    
    CTFrameDraw(self.data.ctFrame, self.context);
    
    
    for (NSInteger i=0; i<self.data.imageArray.count; i++) {
        ZCBBSCoreTextImageData * imageData = (ZCBBSCoreTextImageData *)[self.data.imageArray objectAtIndex:i];
        UIImage *image = [UIImage imageNamed:imageData.name];
        
        if (self.isLoadImageArray.count == self.data.imageArray.count && self.imageArray.count == self.data.imageArray.count) {
            if ([[self.isLoadImageArray objectAtIndex:i] isEqualToString:@"1"] && [[self.imageArray objectAtIndex:i] isKindOfClass:[UIImage class]]) {
                image = [self.imageArray objectAtIndex:i];
            }
        }
        
        if (image) {
            CGContextDrawImage(self.context, imageData.imagePosition, image.CGImage);
        }
    }
}

- (void)requestImage
{
    self.isLoadImageArray = [NSMutableArray array];
    self.imageArray = [NSMutableArray array];
    for (ZCBBSCoreTextImageData * imageData in self.data.imageArray) {
        [self.isLoadImageArray addObject:@"0"];
        [self.imageArray addObject:@"0"];
        
        NSUInteger imageIndex = [self.data.imageArray indexOfObject:imageData];
        [self setRequestImageWithUrl:imageData.imgUrl WithIndex:imageIndex];
    }
    
}

- (void)setRequestImageWithUrl:(NSString *)url WithIndex:(NSUInteger)imageIndex
{
    //建立图片请求
    NSString *URLString = [NSString stringWithFormat:@"%@",url];
    URLString = [URLString stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    NSURL *URL = [NSURL URLWithString:URLString];
    
    NSNumber *indexNum = [NSNumber numberWithUnsignedInteger:imageIndex];
    [self loadImageFromURL:URL WithIndex:indexNum];
}

- (void)loadImageFromURL:(NSURL*)url WithIndex:(NSNumber *)imageIndex{
    
    // 请求网络加载的图片
    
//    __weak ASIHTTPRequest *request = [ASIHTTPRequest requestWithURL:url];
//    request.userInfo = [NSDictionary dictionaryWithObject:imageIndex forKey:@"index"];
//    [request setCompletionBlock:^{
//        
//        // Use when fetching binary data
//        [self imageDidFinishLoading:request];
//        
//    }];
//    [request startAsynchronous];
    
}

//- (void)imageDidFinishLoading:(ASIHTTPRequest *)response
//{
//    
//    NSData* imagedata = [response responseData];
//    //验证图片有效性
//    if ([self isImage:imagedata]) {
//        //有效图片
//        //make an image view for the image
//        UIImage *remoteImage = [UIImage imageWithData:imagedata];;//[UIImage imageWithData:data];//获得图片
//        if (remoteImage == nil) {
//            //            NSError * error;
//            //            [self connection:theConnection didFailWithError:error];
//            
//        }
//        else{
//            
//            //save image
//            ///////主线程
//            dispatch_async(dispatch_get_main_queue(), ^{
//                NSNumber * num= [response.userInfo objectForKey:@"index"];
//                [self.isLoadImageArray replaceObjectAtIndex:num.integerValue withObject:@"1"];
//                [self.imageArray replaceObjectAtIndex:num.integerValue withObject:remoteImage];
//                [self setNeedsDisplay];
//            });
//            
//        }
//    }
//    else{
//        //无效图片
//        //        NSError * error;
//        //        [self connection:theConnection didFailWithError:error];
//    }
//}

//是否是jpeg、png、bmp
- (BOOL)isImage:(NSData *)imageData
{
    return YES;
}



- (void)setupEvents
{
    
    UIGestureRecognizer *longPressRecognizer = [[UILongPressGestureRecognizer alloc] initWithTarget:self
                                                                                             action:@selector(userLongPressedGuestureDetected:)];
    [self addGestureRecognizer:longPressRecognizer];
    
//    UIGestureRecognizer *panRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self
//                                                                                 action:@selector(userPanGuestureDetected:)];
//    [self addGestureRecognizer:panRecognizer];
    
    self.userInteractionEnabled = YES;
}


- (void)userLongPressedGuestureDetected:(UIGestureRecognizer *)recognizer
{
    UIMenuItem *deny = [[UIMenuItem alloc] initWithTitle:@"拷贝"action:@selector(copyTheContentStr)];
    UIMenuController *menu = [UIMenuController sharedMenuController];
    [menu setMenuItems:[NSArray arrayWithObject:deny]];
    [self becomeFirstResponder];
    
    CGRect menuFrame = self.frame;
    [menu setTargetRect:menuFrame inView:self.superview];
    [menu setMenuVisible:YES animated:YES];
    
    
    self.backgroundColor = [UtilityHelper colorWithHexString:STR_LINE_COLOR];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(menuControllerWillHide:)
                                                 name:UIMenuControllerWillHideMenuNotification
                                               object:nil];
    
}

#pragma mark - 复制粘贴
- (void)copywenzi
{
    self.backgroundColor = [UIColor clearColor];
    
}


-(BOOL)canPerformAction:(SEL)action withSender:(id)sender
{
    if (action == @selector(copyTheContentStr)) {
        return YES;
    }
    return [super canPerformAction:action withSender:sender];
}


- (void)copyTheContentStr
{
    self.backgroundColor = [UIColor clearColor];
    [UIPasteboard generalPasteboard].string = self.data.content.string;
}

- (void)menuControllerWillHide:(NSNotification *)sender
{
    self.backgroundColor = [UIColor clearColor];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIMenuControllerWillHideMenuNotification object:nil];
}

- (BOOL)canBecomeFirstResponder{
    return YES;
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    UITouch *touch = [touches anyObject];

    _linkData = [ZCBBSCoreTextUtils touchLinkInView:self atPoint:[touch locationInView:self] data:self.data];
    if (_linkData) {
    } else {
        [self resignFirstResponder];  // 取消第一响应者
        
        [UIMenuController sharedMenuController].menuVisible = NO;
        
        [super touchesBegan:touches withEvent:event];
    }
    
    
}
- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    if (!_linkData) {
        [super touchesEnded:touches withEvent:event];
    } else {
        
        if (_linkData.delegate) {
            if ([_linkData.delegate respondsToSelector:@selector(linkWithKeyWord:andLinkData:)]) {
                [_linkData.delegate performSelector:@selector(linkWithKeyWord:andLinkData:) withObject:_linkData.title withObject:_linkData];
            }
        }
        
        if ([_linkData.vcMark isEqualToString:@"HT"] && _linkData.valueA.length > 0) { // 判断TopicId是否为空
            // 之前项目中的业务代码
//            ZCBBSTopicViewController *vc = [[ZCBBSTopicViewController alloc] init];
//            vc.topicTitle = _linkData.title;
//            vc.topicID = _linkData.valueA;
//            [self.controller.navigationController pushViewController:vc animated:YES];
        } else if ([_linkData.vcMark isEqualToString:@"GRZL"]) {
            // 之前项目中的业务代码
//            ZCBBSPersonalInformationController *vc = [[ZCBBSPersonalInformationController alloc] init];
//            vc.userName = _linkData.valueA;
//            [self.controller.navigationController pushViewController:vc animated:YES];
        }
    }
}


@end
