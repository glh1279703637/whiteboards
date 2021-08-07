//
//  JWhiteBoardImageView+JOperationImageView.m
//  MZCloudClass
//
//  Created by 123 on 2016/12/29.
//  Copyright © 2016年 Jeffrey. All rights reserved.
//

#import "JWhiteBoardImageView+JOperationImageView.h"
#import "JWhiteBoardImageView+JSyschBoardImage.h"
#import "JMeetingRolesManager.h"
#import "JMeetingHandleManager.h"
@implementation JWhiteBoardImageView (JOperationImageView)
-(void)funj_addDefaultImageView{
    UIImageView* handleImageView=[UIImageView funj_getImageView:CGRectMake((kWhiteBoardDrawWidth(self.m_fromVC)-kWhiteBoardDrawWidth(self.m_fromVC)/2)/2, (kWhiteBoardDrawHeight(self.m_fromVC)-kWhiteBoardDrawHeight(self.m_fromVC)/2)/2, kWhiteBoardDrawWidth(self.m_fromVC)/3, kWhiteBoardDrawHeight(self.m_fromVC)/2) image:nil];
    self.m_handleImageView =handleImageView;
    self.m_handleImageView.userInteractionEnabled = YES;
    self.m_handleImageView.hidden=YES;
    [self addSubview:self.m_handleImageView];
    
    JOperationImageView *oprationImageView =[[JOperationImageView alloc]initWithFrame:CGRectMake(100, 100,55*3, 40)];
    oprationImageView.m_fromVC = self.m_fromVC;
    [self addSubview:oprationImageView];
    oprationImageView.m_delegate = self;
    self.m_handleBgImageView =oprationImageView;
    
    __weak typeof(self) weakSelf = self;
 
    UIPinchGestureRecognizer *pinchGesture =[[UIPinchGestureRecognizer alloc]initWithTarget:self action:@selector(handlePinch:)];
    [self.m_handleImageView addGestureRecognizer:pinchGesture];
    
    UIRotationGestureRecognizer* rotaionGesture = [[UIRotationGestureRecognizer alloc] initWithTarget:self action:@selector(handleRotation:)];
    [self.m_handleImageView addGestureRecognizer:rotaionGesture];
    
    UIPanGestureRecognizer* panGesture = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handlePane:)];
    [self.m_handleImageView addGestureRecognizer:panGesture];
    
    [self whenTapped:^(UIView *sender) {
        weakSelf.m_handleImageView.hidden = YES;
        weakSelf.m_handleBgImageView.hidden = YES;
    }];
    [self funj_addFourImageViews:self.m_handleImageView];

}
//set imageview is current operation view
-(void)funj_changeDefaultSubViewsFrames:(UIImageView*)imageView{
      if(imageView){
        self.m_handleImageView.frame = imageView.bounds;
        [imageView addSubview:self.m_handleImageView];
    }else{
        UIImageView *superImageView =(UIImageView*)[self.m_handleImageView superview];
        superImageView.height = self.m_handleImageView.height;
        superImageView.width = self.m_handleImageView.width;
    }
 
    self.m_deleteImage.left = self.m_handleImageView.width-30;
    
    self.m_defaultImage.top = self.m_handleImageView.height-30;
    [self funj_addFourImageViews:self.m_handleImageView];
    [self.m_handleBgImageView funj_changeItSuperViewsFrames:imageView];
 }
//change ppt page to change imageview show
-(void)funj_changePageToReloadCurrentImage:(NSString*)page{
 
    if(!page || [page isEqualToString: self.m_currentPage] || !self.m_currentPage)return;

    //保存当前的数据
    NSMutableArray *currentImageArr = nil;
    if([self.m_saveAllImageItemInfoDic objectForKey:self.m_currentPage]){
        currentImageArr =[self.m_saveAllImageItemInfoDic objectForKey:self.m_currentPage];
        [currentImageArr removeAllObjects];
    }else{
         currentImageArr =[[NSMutableArray alloc]init];
    }
    [currentImageArr addObjectsFromArray:self.m_saveImageItemArr];
    [self.m_saveAllImageItemInfoDic setObject:currentImageArr forKey:self.m_currentPage];
    
      //获取新页数的数据
    for(JImageModel *imageMode in self.m_saveImageItemArr){
        [imageMode.imageView removeFromSuperview];
    }
    [self.m_saveImageItemArr removeAllObjects];
    
    if([self.m_saveAllImageItemInfoDic objectForKey:page]){
        [self.m_saveImageItemArr addObjectsFromArray:[self.m_saveAllImageItemInfoDic objectForKey:page]];
    }else{
        NSMutableArray *imageArr =[[NSMutableArray alloc]init];
        [self.m_saveAllImageItemInfoDic setObject:imageArr forKey:page];
    }
    [self.m_handleBgImageView removeFromSuperview];
    for(JImageModel *imageModel in self.m_saveImageItemArr){
        [self addSubview:imageModel.imageView];
        if([imageModel.imageView  isEqual:self.m_handleImageView.superview]){
            [self addSubview:self.m_handleBgImageView];
        }
    }
 
     [JAppUtility funj_transitionWithType:kCATransitionPush WithSubtype: ([self.m_currentPage intValue] > [page intValue] ?kCATransitionFromLeft:kCATransitionFromRight) ForView:self t:0.3];
    
    self.m_currentPage = page;
}

//change ppt page to change imageview show
-(void)funj_changeQuestionPageToReloadCurrentImage:(NSString*)page{
    for(UIImageView *imageView in self.subviews){
        if([imageView isKindOfClass:[UIImageView class]] && imageView.accessibilityLabel){
            [imageView removeFromSuperview];
        }
    }
    [self.m_handleBgImageView removeFromSuperview];
    for(int i=0;i<self.m_saveImageItemArr.count;i++){
        JImageModel *imageModel = self.m_saveImageItemArr[i];
         if(imageModel){
            [self addSubview:imageModel.imageView];
            if([imageModel.imageView  isEqual:self.m_handleImageView.superview]){
                [self addSubview:self.m_handleBgImageView];
            }
            __weak typeof(self) weakSelf = self;
            [imageModel.imageView whenTapped:^(UIView *sender) {
                __strong typeof(weakSelf) strongSelf = weakSelf;
                [strongSelf funj_startToTouchImageView:(UIImageView*)sender];
            }];
        }
    }
   if([self.m_currentPage intValue] != [page intValue]) [JAppUtility funj_transitionWithType:kCATransitionPush WithSubtype: ([self.m_currentPage intValue] > [page intValue] ?kCATransitionFromLeft:kCATransitionFromRight) ForView:self t:0.3];
    
    self.m_currentPage = page;
}
-(void)funj_reloadToChangeAllPageIndex:(NSDictionary*)changeDic{
    NSMutableArray *imageArr =[self.m_saveAllImageItemInfoDic objectForKey:self.m_currentPage];
    if(!imageArr){
        imageArr =[[NSMutableArray alloc]init];
        [self.m_saveAllImageItemInfoDic setObject:imageArr forKey:self.m_currentPage];
    }else{
        [imageArr removeAllObjects];
        [imageArr addObjectsFromArray:self.m_saveImageItemArr];
    }
    for(NSString *newPage in changeDic.allKeys){
        NSString *oldPage = changeDic[newPage];
         NSMutableArray *imageArr =[self.m_saveAllImageItemInfoDic objectForKey:oldPage];
        if(!imageArr){
            imageArr =[[NSMutableArray alloc]init];
        }
        [self.m_saveAllImageItemInfoDic setObject:imageArr forKey:newPage];
    }
    //获取新页数的数据
    for(JImageModel *imageMode in self.m_saveImageItemArr){
        [imageMode.imageView removeFromSuperview];
    }
    [self.m_saveImageItemArr removeAllObjects];
    [self.m_saveImageItemArr addObjectsFromArray:[self.m_saveAllImageItemInfoDic objectForKey:self.m_currentPage]];
    
    [self funj_changeQuestionPageToReloadCurrentImage:self.m_currentPage];
  }


// import image to new imageview
-(UIImageView*)funj_reloadToAddImageViews:(UIImage*)image :(CGSize)sizes :(BOOL)isNeedSysch :(NSDictionary*)dataUrl{
    if(!image)return nil;
    CGSize size = CGSizeMake(kWhiteBoardDrawWidth(self.m_fromVC) /2, kWhiteBoardDrawWidth(self.m_fromVC)/2 * image.size.height /image.size.width);
    if(size.height >kWhiteBoardDrawHeight(self.m_fromVC) ){
        size.width = kWhiteBoardDrawHeight(self.m_fromVC) * size.width / size.height ;
        size.height = kWhiteBoardDrawHeight(self.m_fromVC);
    }
 
    CGPoint defaultpoint = CGPointMake((kWhiteBoardDrawWidth(self.m_fromVC)-size.width)/2 , (kWhiteBoardDrawHeight(self.m_fromVC)-size.height)/2);
    if(CGSizeEqualToSize(sizes, CGSizeZero)){
        for(JImageModel *model in self.m_saveImageItemArr){
            CGPoint point = model.imageView.origin;
            if(point.x >=defaultpoint.x && point.y>=defaultpoint.y){
                if(((int)(point.x-defaultpoint.x)%10 ==0) && ((int)(point.y-defaultpoint.y) % 10 ==0)){
                    defaultpoint = CGPointMake(point.x+10, point.y+10);
                }
            }
        }
    }

    UIImageView *imageView = [UIImageView funj_getImageViewFillet:CGRectMake(0,0, size.width, size.height) image:nil :JFilletMake(1, 2, COLOR_TEXT_GRAY_DARK)];
     imageView.image = image;
    [self addSubview:imageView];
    imageView.transform = CGAffineTransformTranslate(imageView.transform, defaultpoint.x , defaultpoint.y);
 
    imageView.accessibilityLabel = [NSString stringWithFormat:@"%ld", arc4random()%1000 + (long)[[NSDate date]timeIntervalSince1970]*100000];

    __weak typeof(self) weakSelf = self;
    [imageView whenTapped:^(UIView *sender) {
        __strong typeof(weakSelf) strongSelf = weakSelf;
        [strongSelf funj_startToTouchImageView:(UIImageView*)sender];
     }];
    
    JImageModel *imageModel =[[JImageModel alloc]init];
    imageModel.m_width = size.width / kWhiteBoardDrawWidth(self.m_fromVC);
    imageModel.m_height = size.height / (kWhiteBoardDrawHeight(self.m_fromVC));
    imageModel.keyId = imageView.accessibilityLabel;
    imageModel.imageView = imageView;
    imageModel.ower =[JWhiteboardConfig share].m_myUserId;
    imageModel.page = self.m_currentPage;
    [self.m_saveImageItemArr addObject:imageModel];
 
    
    if(isNeedSysch){
        [self funj_uploadImageToServer :imageModel :dataUrl block:^(NSDictionary *data) {
            if(data[@"fileId"]){
                 imageModel.fileId =data[@"fileId"];
//                imageModel.fullUrl = [APPQiNiuROOTURL(@"imagess") stringByAppendingString:data[@"file_path"]];
             }
        }];
    }
    return imageView;
}
-(void)funj_addFourImageViews:(UIImageView*)bgImageView{
    NSArray *pointsArr = @[[NSValue valueWithCGPoint:CGPointMake(0, 0)],[NSValue valueWithCGPoint:CGPointMake(bgImageView.width, 0)],[NSValue valueWithCGPoint:CGPointMake(0, bgImageView.height)],[NSValue valueWithCGPoint:CGPointMake(bgImageView.width, bgImageView.height)]];
    for(int i=0;i<4;i++){
        UIImageView *pointImageView =[bgImageView viewWithTag:4000+i];
        CGPoint point =[pointsArr[i] CGPointValue];
        if(!pointImageView){
            pointImageView = [UIImageView funj_getImageView:CGRectMake(point.x, point.y, 1, 1) image:nil];
            pointImageView.tag = 4000+i;
            [bgImageView addSubview:pointImageView];
        }
        pointImageView.left = point.x;
        pointImageView.top = point.y;

    }
}
-(void)funj_startToTouchImageViewWithChangeBt{
    JImageModel*imageModel =[self.m_saveImageItemArr lastObject];
    if(imageModel){
        [self addSubview:imageModel.imageView];
        [self addSubview:self.m_handleBgImageView];
        [self funj_changeDefaultSubViewsFrames:imageModel.imageView];
        self.m_handleBgImageView.hidden = self.m_handleImageView.hidden = NO;
    }else{
        self.m_handleBgImageView.hidden = self.m_handleImageView.hidden = YES;
    }
}
-(void)funj_startToTouchImageView:(UIImageView*)imageView{
    self.m_handleImageView.hidden = self.m_handleBgImageView.hidden=NO;
    [self addSubview:imageView];
    [self addSubview:self.m_handleBgImageView];
    [self funj_changeDefaultSubViewsFrames:imageView];
    for(JImageModel*imageModel in self.m_saveImageItemArr){
        if([imageModel.keyId isEqualToString:imageView.accessibilityLabel]){
            [[JMeetingHandleManager share]funj_modifyActionToServer:imageModel];
            break;
        }
    }
}
-(BOOL)funj_modifyToChangeImagePostion:(NSString*)keyId :(NSString*)page :(CGAffineTransform)t{
    NSMutableArray *saveImageArr = nil;
    if(!page || [page isEqualToString:self.m_currentPage]){
        saveImageArr = self.m_saveImageItemArr;
    }else{
        saveImageArr = [self.m_saveAllImageItemInfoDic objectForKey:page];
    }
    for(JImageModel *imageModel in saveImageArr){
        if([imageModel.keyId isEqualToString:keyId]){
            imageModel.imageView.transform = CGAffineTransformMake(t.a, t.b, t.c, t.d, t.tx*kWhiteBoardDrawWidth(self.m_fromVC), t.ty*(kWhiteBoardDrawHeight(self.m_fromVC)));
             if(!page || [page isEqualToString:self.m_currentPage]){
                [saveImageArr addObject:imageModel];
                [self addSubview:imageModel.imageView];
                 if(!self.m_handleBgImageView.hidden && [self.m_handleImageView.superview  isEqual:imageModel.imageView]){
                     [self.m_handleBgImageView funj_changeItSuperViewsFrames:imageModel.imageView];
                     [self addSubview:self.m_handleBgImageView];
                 }
            }
            return YES;
        }
    }
    return NO;
}
// reload imageview for imageurl
-(UIImageView*)funj_reloadToRequestImage:(NSString*)url :(NSString*)fileId :(NSString*)keyId :(CGSize)size :(CGAffineTransform)t :(NSString*)page :(NSString*)userId{

    UIImageView *imageView = [UIImageView funj_getImageViewFillet:CGRectMake(0,0,size.width*kWhiteBoardDrawWidth(self.m_fromVC),size.height*(kWhiteBoardDrawHeight(self.m_fromVC))) image:nil :JFilletMake(1, 2, COLOR_TEXT_GRAY_DARK)];
    imageView.accessibilityLabel =keyId;
    [imageView funj_setInternetImage:url :url];
 
    __weak typeof(self) weakSelf = self;
    [imageView whenTapped:^(UIView *sender) {
        __strong typeof(weakSelf) strongSelf = weakSelf;
        [strongSelf funj_startToTouchImageView:(UIImageView*)sender];
     }];
    imageView.transform = CGAffineTransformMake(t.a, t.b, t.c, t.d, t.tx*kWhiteBoardDrawWidth(self.m_fromVC), t.ty*(kWhiteBoardDrawHeight(self.m_fromVC)));
    
    JImageModel *imageModel =[[JImageModel alloc]init];
    imageModel.fileId = fileId;
    imageModel.m_width = size.width;
    imageModel.m_height = size.height;
//    imageModel.fullUrl = url;
     imageModel.imageView = imageView;
    imageModel.ower = userId;
    imageModel.page = page;
    imageModel.keyId = imageView.accessibilityLabel;
 
    if(page &&![page isEqualToString:self.m_currentPage]){
        //保存当前的数据
        NSMutableArray *currentImageArr = nil;
        if([self.m_saveAllImageItemInfoDic objectForKey:page]){
            currentImageArr =[self.m_saveAllImageItemInfoDic objectForKey:page];
         }else{
            currentImageArr =[[NSMutableArray alloc]init];
        }
        [currentImageArr addObject:imageModel];
         [self.m_saveAllImageItemInfoDic setObject:currentImageArr forKey:page];
        
        if([page isEqualToString:self.m_currentPage]){
            [self.m_saveImageItemArr addObject:imageModel];
             [self addSubview:imageView];
        }
        
    }else{
        [self.m_saveImageItemArr addObject:imageModel];
        [self addSubview:imageView];
    }
    return imageView;
  
}
-(void)handlePinch:(UIPinchGestureRecognizer*)recognizer{
    if([recognizer.view.superview isEqual:self])return;
    CGFloat scale = recognizer.scale;
    CGFloat minwidth  = kWhiteBoardDrawWidth(self.m_fromVC) /3;
    CGFloat maxwidth = kWhiteBoardDrawWidth(self.m_fromVC)*3/2;

    CGFloat oldScale = recognizer.view.superview.accessibilityIdentifier ? [recognizer.view.superview.accessibilityIdentifier floatValue] : 1;
    if(recognizer.view.superview.width < minwidth   && scale < oldScale ) return;
    if(recognizer.view.superview.width > maxwidth && scale > oldScale) return;
 
    recognizer.view.superview.accessibilityIdentifier = [NSString stringWithFormat:@"%f",scale];
    recognizer.view.superview.transform = CGAffineTransformScale(recognizer.view.superview.transform, scale, scale); //在已缩放大小基础下进行累加变化；区别于：使用 CGAffineTransformMakeScale 方法就是在原大小基础下进行变化
//    self.contentSize=CGSizeMake(recognizer.view.superview.width,recognizer.view.superview.height);
     recognizer.scale = 1.0;

     [self.m_handleBgImageView funj_changeItSuperViewsFrames:(UIImageView*)recognizer.view.superview];
     if(recognizer.state == UIGestureRecognizerStateEnded || recognizer.state == UIGestureRecognizerStateCancelled || recognizer.state == UIGestureRecognizerStateFailed){
        for(JImageModel*imageModel in self.m_saveImageItemArr){
            if([imageModel.keyId isEqualToString:recognizer.view.superview.accessibilityLabel]){
                [[JMeetingHandleManager share]funj_modifyActionToServer:imageModel];
                break;
            }
        }
    }
 
}
- (void)handleRotation:(UIRotationGestureRecognizer *)recognizer {
    if([recognizer.view.superview isEqual:self])return;

    recognizer.view.superview.transform = CGAffineTransformRotate(recognizer.view.superview.transform, recognizer.rotation);
    recognizer.rotation = 0.0;
 
     [self.m_handleBgImageView funj_changeItSuperViewsFrames:(UIImageView*)recognizer.view.superview];
    if(recognizer.state == UIGestureRecognizerStateEnded || recognizer.state == UIGestureRecognizerStateCancelled || recognizer.state == UIGestureRecognizerStateFailed){
        for(JImageModel*imageModel in self.m_saveImageItemArr){
            if([imageModel.keyId isEqualToString:recognizer.view.superview.accessibilityLabel]){
                [[JMeetingHandleManager share]funj_modifyActionToServer:imageModel];
                break;
            }
        }
    }
 }
- (void)handlePane:(UIPanGestureRecognizer *)recognizer {
    if([recognizer.view.superview isEqual:self])return;
    CGPoint point = [recognizer translationInView:recognizer.view];
    recognizer.view.superview.transform = CGAffineTransformTranslate(recognizer.view.superview.transform, point.x, point.y);
    //将之前增量清零
    [recognizer setTranslation:CGPointZero inView:recognizer.view];
 
    [self.m_handleBgImageView funj_changeItSuperViewsFrames:(UIImageView*)recognizer.view.superview];
    if(recognizer.state == UIGestureRecognizerStateEnded || recognizer.state == UIGestureRecognizerStateCancelled || recognizer.state == UIGestureRecognizerStateFailed){
         for(JImageModel*imageModel in self.m_saveImageItemArr){
            if([imageModel.keyId isEqualToString:recognizer.view.superview.accessibilityLabel]){
                [[JMeetingHandleManager share]funj_modifyActionToServer:imageModel];
                break;
            }
        }
    }
  }

#pragma mark jwhiteboard delegate
-(void)funj_selectCopyImageViewActions{
     UIImageView *superImageView =(UIImageView*)self.m_handleImageView.superview;

    UIImageView *imageView = [self funj_reloadToAddImageViews:superImageView.image :superImageView.size :NO :nil ];
    CGAffineTransform t2 = superImageView.transform;
    superImageView.transform = CGAffineTransformIdentity;
    imageView.width = superImageView.width;
    imageView.height = superImageView.height;
    imageView.transform = CGAffineTransformMake(t2.a, t2.b, t2.c, t2.d, t2.tx+10, t2.ty+10);
    superImageView.transform = t2;
    
    JImageModel *supImageModel = nil;JImageModel *imageModel =nil;
    for(JImageModel*imageMo in self.m_saveImageItemArr){
        if([imageMo.keyId isEqualToString:superImageView.accessibilityLabel]){
            supImageModel = imageMo;
        }
        if([imageMo.keyId isEqualToString:imageView.accessibilityLabel]){
            imageModel =imageMo;
        }
    }
 
    imageModel.fileId =supImageModel.fileId;
    //        imageModel.fullUrl = supImageModel.fullUrl;
    imageModel.ower = [JWhiteboardConfig share].m_myUserId;
    imageModel.page = supImageModel.page;
    [self addSubview:self.m_handleBgImageView];
    [self funj_changeDefaultSubViewsFrames:imageView];
    
     if(self.m_isNotNeedSycToOther)return;
     [[JMeetingHandleManager share]funj_sendAddImageToServer:imageModel];
}
-(void)funj_selectChangeImageViewActions{
    UIImageView *superImageView =(UIImageView*)self.m_handleImageView.superview;
    JImageModel *imageModel =nil;
    for(JImageModel*imageMo in self.m_saveImageItemArr){
         if([imageMo.keyId isEqualToString:superImageView.accessibilityLabel]){
             imageModel =imageMo;break;
        }
    }
 
    CGAffineTransform transform = CGAffineTransformIdentity;
    transform.tx = (1-imageModel.m_width)/2*kWhiteBoardDrawWidth(self.m_fromVC);
    transform.ty = (1-imageModel.m_height)/2*(kWhiteBoardDrawHeight(self.m_fromVC));
    superImageView.transform = transform;
    
    [self funj_changeDefaultSubViewsFrames:superImageView];
    if(self.m_isNotNeedSycToOther)return;
    [[JMeetingHandleManager share]funj_modifyActionToServer:imageModel];
 }
-(void)funj_selectDeleteImageViewActions{
    UIImageView *superImageView =(UIImageView*)self.m_handleImageView.superview;
    [superImageView removeFromSuperview];
    if(!superImageView.accessibilityLabel)return;
    JImageModel *imageModel =nil;
     for(JImageModel*imageMo in self.m_saveImageItemArr){
        if([imageMo.keyId isEqualToString:superImageView.accessibilityLabel]){
            imageModel =imageMo;break;
        }
    }
    if(imageModel)[self.m_saveImageItemArr removeObject:imageModel];
    self.m_handleImageView.hidden=YES;
    self.m_handleBgImageView.hidden=YES;
     if(self.m_isNotNeedSycToOther)return;
    [[JMeetingHandleManager share] funj_deleteActionToServer:superImageView.accessibilityLabel];
 }
@end
