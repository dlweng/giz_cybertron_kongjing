//
//  GizNetTools.m
//  GizIndustrySolution
//
//  Created by Jubal on 2017/1/4.
//  Copyright © 2017年 Gizwits. All rights reserved.
//

#import "GizNetTools.h"
#import "GizAppGlobal.h"

@implementation GizNetTools

static int outTime = 30;

+ (AFSecurityPolicy *)customSecurityPolicy
{
    //先导入证书，找到证书的路径
    NSString *cerPath = [[NSBundle mainBundle] pathForResource:@"server" ofType:@"cer"];
    NSData *certData = [NSData dataWithContentsOfFile:cerPath];
    
    //AFSSLPinningModeCertificate 使用证书验证模式
    AFSecurityPolicy *securityPolicy = [AFSecurityPolicy policyWithPinningMode:AFSSLPinningModeCertificate];
    
    securityPolicy.allowInvalidCertificates = YES;
    securityPolicy.validatesDomainName = NO;
    NSSet *cerSet = [[NSSet alloc] initWithObjects:certData, nil];
    [securityPolicy setPinnedCertificates:cerSet];
    
    return securityPolicy;
}

+ (void)getWithURLString:(NSString *)urlString
              parameters:(id)parameters
                 success:(SuccessBlock)successBlock
                 failure:(FailureBlock)failureBlock
{
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    manager.responseSerializer.acceptableContentTypes =  [NSSet setWithObjects:@"application/json", @"text/json", @"text/javascript", nil];
    manager.requestSerializer = [AFJSONRequestSerializer serializer];
    manager.requestSerializer.timeoutInterval = outTime;
    [manager.requestSerializer setValue:GizAppId forHTTPHeaderField:@"X-Gizwits-Application-Id"];
    [manager.requestSerializer setValue:GizUserToken forHTTPHeaderField:@"X-Gizwits-User-token"];
    //HTTPS SSL的验证，在此处调用上面的代码，给这个证书验证；
//    [manager setSecurityPolicy:[GizNetTools customSecurityPolicy]];
    [manager GET:urlString parameters:parameters progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        if (successBlock) {
            NSDictionary *dic = responseObject;
            successBlock(dic);
        }
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        if (failureBlock) {
            failureBlock(error);
            NSLog(@"网络异常 - T_T%@", error);
        }
    }];
}

+ (void)postWithURLString:(NSString *)urlString
               parameters:(id)parameters
                  success:(SuccessBlock)successBlock
                  failure:(FailureBlock)failureBlock
{
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    manager.responseSerializer = [AFHTTPResponseSerializer serializer];
    manager.responseSerializer.acceptableContentTypes =  [NSSet setWithObjects:@"application/json", @"text/json", @"text/javascript", nil];
    manager.requestSerializer = [AFJSONRequestSerializer serializer];
    manager.requestSerializer.timeoutInterval = outTime;
    [manager.requestSerializer setValue:GizAppId forHTTPHeaderField:@"X-Gizwits-Application-Id"];
    [manager.requestSerializer setValue:GizUserToken forHTTPHeaderField:@"X-Gizwits-User-token"];
    //HTTPS SSL的验证，在此处调用上面的代码，给这个证书验证；
//    [manager setSecurityPolicy:[GizNetTools customSecurityPolicy]];
    [manager POST:urlString parameters:parameters progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        if (successBlock) {
            NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingMutableLeaves error:nil];
            successBlock(dic);
        }
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        if (failureBlock) {
            failureBlock(error);
            NSLog(@"网络异常 - T_T %@", error);
        }
    }];
}

+ (void)deleteWithURLString:(NSString*)urlString
                 parameters:(id)parameters
                    success:(SuccessBlock)successBlock
                    failure:(FailureBlock)failureBlock{
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    manager.responseSerializer.acceptableContentTypes =  [NSSet setWithObjects:@"application/json", @"text/json", @"text/javascript", nil];
    manager.requestSerializer = [AFJSONRequestSerializer serializer];
    manager.requestSerializer.timeoutInterval = outTime;
    [manager.requestSerializer setValue:GizAppId forHTTPHeaderField:@"X-Gizwits-Application-Id"];
    [manager.requestSerializer setValue:GizUserToken forHTTPHeaderField:@"X-Gizwits-User-token"];
    //HTTPS SSL的验证，在此处调用上面的代码，给这个证书验证；
//    [manager setSecurityPolicy:[GizNetTools customSecurityPolicy]];
    [manager DELETE:urlString parameters:parameters success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        if (successBlock) {
            NSDictionary *dic;
            if (responseObject) {
                dic = [NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingMutableLeaves error:nil];
            }
            successBlock(dic);
        }
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        if (failureBlock) {
            failureBlock(error);
            NSLog(@"网络异常 - T_T%@", error);
        }
    }];
}

+ (void)putWithURLString:(NSString*)urlString
              parameters:(id)parameters
                 success:(SuccessBlock)successBlock
                 failure:(FailureBlock)failureBlock{
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    manager.responseSerializer.acceptableContentTypes =  [NSSet setWithObjects:@"application/json", @"text/json", @"text/javascript", nil];
    manager.requestSerializer = [AFJSONRequestSerializer serializer];
    manager.requestSerializer.timeoutInterval = outTime;
    [manager.requestSerializer setValue:GizAppId forHTTPHeaderField:@"X-Gizwits-Application-Id"];
    [manager.requestSerializer setValue:GizUserToken forHTTPHeaderField:@"X-Gizwits-User-token"];
    //HTTPS SSL的验证，在此处调用上面的代码，给这个证书验证；
//    [manager setSecurityPolicy:[GizNetTools customSecurityPolicy]];
    [manager PUT:urlString parameters:parameters success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        if (successBlock) {
            NSDictionary *dic = responseObject;
            successBlock(dic);
        }
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        if (failureBlock) {
            failureBlock(error);
            NSLog(@"网络异常 - T_T%@", error);
        }
    }];
}

+ (void)uploadWithImage:(UIImage *)image
              urlString:(NSString *)urlString
               filename:(NSString *)filename
                   name:(NSString *)name
               mimeType:(NSString *)mimeType
             parameters:(NSDictionary *)parameters
               progress:(UploadProgress)progress
                success:(SuccessBlock)successBlock
                   fail:(FailureBlock)failureBlock
{
    
    
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    manager.responseSerializer = [AFHTTPResponseSerializer serializer];
    manager.requestSerializer.timeoutInterval = outTime;
    //HTTPS SSL的验证，在此处调用上面的代码，给这个证书验证；
//    [manager setSecurityPolicy:[GizNetTools customSecurityPolicy]];
    [manager POST:urlString parameters:parameters constructingBodyWithBlock:^(id<AFMultipartFormData>  _Nonnull formData) {
        if (image != nil) {
            NSData *imageData = UIImagePNGRepresentation(image);
            [formData appendPartWithFileData:imageData name:name fileName:filename mimeType:mimeType];
        }
    } progress:^(NSProgress * _Nonnull uploadProgress) {
        if (progress) {
            progress(uploadProgress.completedUnitCount, uploadProgress.totalUnitCount);
        }
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        if (successBlock) {
            NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingMutableLeaves error:nil];
            successBlock(dic);
        }
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        if (failureBlock) {
            failureBlock(error);
            NSLog(@"网络异常 - T_T%@", error);
        }
    }];
}

+ (NSURLSessionTask*)downloadWithUrl:(NSString *)url
                          saveToPath:(NSString *)saveToPath
                            progress:(DownloadProgress)progressBlock
                             success:(SuccessBlock)successBlock
                             failure:(FailureBlock)failureBlock
{
    
    NSURLRequest *downloadRequest = [NSURLRequest requestWithURL:[NSURL URLWithString:url]];
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    manager.responseSerializer = [AFHTTPResponseSerializer serializer];
    manager.requestSerializer.timeoutInterval = outTime;
    //HTTPS SSL的验证，在此处调用上面的代码，给这个证书验证；
//    [manager setSecurityPolicy:[GizNetTools customSecurityPolicy]];
    NSURLSessionTask *session = nil;
    session = [manager downloadTaskWithRequest:downloadRequest progress:^(NSProgress * _Nonnull downloadProgress) {
        if (progressBlock) {
            progressBlock(downloadProgress.completedUnitCount, downloadProgress.totalUnitCount);
        }
    } destination:^NSURL * _Nonnull(NSURL * _Nonnull targetPath, NSURLResponse * _Nonnull response) {
        return [NSURL fileURLWithPath:saveToPath];
    } completionHandler:^(NSURLResponse * _Nonnull response, NSURL * _Nullable filePath, NSError * _Nullable error) {
        if (error == nil) {
            if (successBlock) {
                NSDictionary *data;
                successBlock(data);
            }
        }else{
            if (failureBlock) {
                failureBlock(error);
            }
        }
    }];
    [session resume];
    
    return session;
}

@end
