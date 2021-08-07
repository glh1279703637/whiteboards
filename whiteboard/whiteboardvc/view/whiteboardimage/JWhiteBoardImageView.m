//
//  JWhiteBoardImageView.m
//  MZCloudClass
//
//  Created by 123 on 2016/12/19.
//  Copyright © 2016年 Jeffrey. All rights reserved.
//

#import "JWhiteBoardImageView.h"
#import "JWhiteBoardImageView+JOperationImageView.h"
#import "JMeetingRolesManager.h"
#import "JBaseInterfaceManager.h"

@interface JWhiteBoardImageView() 

@end
@implementation JWhiteBoardImageView

-(id)initWithFrame:(CGRect)frame f:(NSInteger)from{
    if(self =[super initWithFrame:frame]){
          self.backgroundColor=COLOR_CREAR;
        self.m_currentPage = @"1";
 
        _m_saveImageItemArr=[[NSMutableArray alloc]init];
        _m_saveAllImageItemInfoDic=[[NSMutableDictionary alloc]init];
        _m_fromVC = from;
        [self funj_addDefaultImageView];
    }
    return self;
}
-(void)funj_deleteOneImageView:(NSString*)page :(NSString*)userId :(NSString*)key{
    //获取新页数的数据
    NSMutableArray *saveImageArr = nil;
     if(!page || [page isEqualToString:self.m_currentPage]){
        saveImageArr = self.m_saveImageItemArr;
    }else{
        saveImageArr = [self.m_saveAllImageItemInfoDic objectForKey:page];
    }
    NSInteger index = NSNotFound;
    for(int i=0;i<saveImageArr.count;i++){
        JImageModel *imageModel = saveImageArr[i];
        if([imageModel.keyId isEqualToString:key]){
//            if(!userId || (userId && ([userId isEqualToString:[JWhiteboardConfig share].m_teacherId] || [userId isEqualToString:imageModel.ower]))){
                index = i;
//            }
            break;
        }
    }
    if(index == NSNotFound)return;
    JImageModel *imageModel = saveImageArr[index];
    if([imageModel.imageView isEqual:self.m_handleImageView.superview]){
        [self.m_handleImageView removeFromSuperview];
        self.m_handleBgImageView.hidden = YES;
    }
    [imageModel.imageView removeFromSuperview];
    [saveImageArr removeObjectAtIndex:index];
}
-(NSArray*)funj_deleteSomePageAllImageView:(NSString*)page :(NSString*)userId{
    //获取新页数的数据
    NSMutableArray *saveImageArr = nil;
    if(!page || [page isEqualToString:self.m_currentPage]){
        saveImageArr = self.m_saveImageItemArr;
    }else{
        saveImageArr = [self.m_saveAllImageItemInfoDic objectForKey:page];
    }
    NSMutableIndexSet *indexSet =[[NSMutableIndexSet alloc]init];
    NSInteger index = 0;
    NSMutableArray *deleteImageArr =[[NSMutableArray alloc]init];
    for(JImageModel *imageModel in saveImageArr){
        UIImageView *imageView = imageModel.imageView;
        if(!userId || (userId && ([userId isEqualToString:[JWhiteboardConfig share].m_speakerUserId] || [userId isEqualToString:imageModel.ower]))){
            [imageView removeFromSuperview];
            [indexSet addIndex:index];
            if(imageModel.keyId && imageModel.keyId.length>0)[deleteImageArr addObject:imageModel.keyId];
            if([imageModel.imageView isEqual:self.m_handleImageView.superview]){
                [self.m_handleImageView removeFromSuperview];
                self.m_handleBgImageView.hidden = YES;
            }
        }
        index ++;
    }
    [saveImageArr removeObjectsAtIndexes:indexSet];
    return deleteImageArr;
}
-(void)funj_deleteAllImageFrom:(NSString*)page{
    if(!page || [page isEqualToString:self.m_currentPage]){
        [self funj_deleteSomePageAllImageView:page :nil];
    }
    NSMutableArray *pageArr =[[NSMutableArray alloc]init];
    for(NSString *index in self.m_saveAllImageItemInfoDic.allKeys){
        if(index.intValue >= page.intValue){
            [pageArr addObject:index];
        }
    }
    
    [self.m_saveAllImageItemInfoDic removeObjectsForKeys:pageArr];
}
-(void)funj_deleteSomePageImagesView:(NSString*)page :(NSString*)idkeys{
    //获取新页数的数据
    NSMutableArray *saveImageArr = nil;
    if(!page || [page isEqualToString:self.m_currentPage]){
        saveImageArr = self.m_saveImageItemArr;
    }else{
        saveImageArr = [self.m_saveAllImageItemInfoDic objectForKey:page];
    }
    NSMutableIndexSet *indexSet =[[NSMutableIndexSet alloc]init];
    NSInteger index = 0;
    NSMutableArray *deleteImageArr =[[NSMutableArray alloc]init];
    for(JImageModel *imageModel in saveImageArr){
        UIImageView *imageView = imageModel.imageView;
        if([idkeys rangeOfString:imageModel.keyId].length >0){
            [imageView removeFromSuperview];
            [indexSet addIndex:index];
            if(imageModel.keyId && imageModel.keyId.length>0)[deleteImageArr addObject:imageModel.keyId];
            if([imageModel.imageView isEqual:self.m_handleImageView.superview]){
                [self.m_handleImageView removeFromSuperview];
                self.m_handleBgImageView.hidden = YES;
            }
        }
        index ++;
    }
    [saveImageArr removeObjectsAtIndexes:indexSet];
}

@end
