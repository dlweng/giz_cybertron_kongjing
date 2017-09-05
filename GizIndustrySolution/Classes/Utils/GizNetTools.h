//
//  GizNetTools.h
//  GizIndustrySolution
//
//  Created by Jubal on 2017/1/4.
//  Copyright © 2017年 Gizwits. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AFNetworking.h>

typedef void (^SuccessBlock)(NSDictionary *data);
typedef void (^FailureBlock)(NSError *error);

typedef void (^UploadProgress)(int64_t bytesWritten,
int64_t totalBytesWritten);
typedef void (^DownloadProgress)(int64_t bytesRead,
int64_t totalBytesRead);

@interface GizNetTools : NSObject

@property (nonatomic, copy) SuccessBlock successBlock;
@property (nonatomic, copy) FailureBlock failureBlock;


/**
 *  发送get请求
 *
 *  @param urlString  请求的网址字符串
 *  @param parameters 请求的参数
 *  @param successBlock    请求成功的回调
 *  @param failureBlock    请求失败的回调
 */
+ (void)getWithURLString:(NSString *)urlString
              parameters:(id)parameters
                 success:(SuccessBlock)successBlock
                 failure:(FailureBlock)failureBlock;

/**
 *  发送post请求
 *
 *  @param urlString  请求的网址字符串
 *  @param parameters 请求的参数
 *  @param successBlock    请求成功的回调
 *  @param failureBlock    请求失败的回调
 */
+ (void)postWithURLString:(NSString *)urlString
               parameters:(id)parameters
                  success:(SuccessBlock)successBlock
                  failure:(FailureBlock)failureBlock;


+ (void)deleteWithURLString:(NSString*)urlString
                 parameters:(id)parameters
                    success:(SuccessBlock)successBlock
                    failure:(FailureBlock)failureBlock;

+ (void)putWithURLString:(NSString*)urlString
              parameters:(id)parameters
                 success:(SuccessBlock)successBlock
                 failure:(FailureBlock)failureBlock;


/**
 上传图片
 
 @param image 图片
 @param urlString 请求的网址字符串
 @param filename 图片文件名
 @param name 图片名
 @param mimeType 图片类型
 @param parameters 请求的参数
 @param progress 上传进度
 @param successBlock 请求成功的回调
 @param failureBlock 请求失败的回调
 */
+ (void)uploadWithImage:(UIImage *)image
              urlString:(NSString *)urlString
               filename:(NSString *)filename
                   name:(NSString *)name
               mimeType:(NSString *)mimeType
             parameters:(NSDictionary *)parameters
               progress:(UploadProgress)progress
                success:(SuccessBlock)successBlock
                   fail:(FailureBlock)failureBlock;


+ (NSURLSessionTask*)downloadWithUrl:(NSString *)url
                          saveToPath:(NSString *)saveToPath
                            progress:(DownloadProgress)progressBlock
                             success:(SuccessBlock)successBlock
                             failure:(FailureBlock)failureBlock;

@end
