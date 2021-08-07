//
//  JWhiteBoardImageView+JSyschBoardImage.h
//  MZCloudClass
//
//  Created by 123 on 2017/1/11.
//  Copyright © 2017年 Jeffrey. All rights reserved.
//

#import "JWhiteBoardImageView.h"

@interface JWhiteBoardImageView (JSyschBoardImage)
//上传图片到七牛
-(void)funj_uploadImageToServer:(JImageModel*)imageView :(NSDictionary*)dataUrl block:(void (^)(NSDictionary *data))callback;
//从视频中长按复制图片到当前白板中
-(void)funj_requestMessageFromStudentAnswerToShare:(NSArray*)urlArr;
@end
