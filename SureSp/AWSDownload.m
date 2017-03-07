//
//  AWSDownload.m
//  Sure_sp
//
//  Created by Ranosys on 13/04/15.
//  Copyright (c) 2015 Ranosys. All rights reserved.
//

#import "AWSDownload.h"

@implementation AWSDownload



-(void)listObjects:(id)sender ImageName:(NSMutableArray*)imageName folderName:(NSString *)folderName
{
    NSError *error = nil;
    if (![[NSFileManager defaultManager] createDirectoryAtPath:[NSTemporaryDirectory() stringByAppendingPathComponent:@"download"]
                                   withIntermediateDirectories:YES
                                                    attributes:nil
                                                         error:&error]) {
    }
  // NSString *downloadingFilePath = [NSTemporaryDirectory() stringByAppendingPathComponent:@"download"];
    AWSS3 *s3 = [AWSS3 defaultS3];
    
    AWSS3ListObjectsRequest *listObjectsRequest = [AWSS3ListObjectsRequest new];
    listObjectsRequest.bucket = S3BucketName;
    NSMutableArray *imagesArray=[NSMutableArray new];
    [[s3 listObjects:listObjectsRequest] continueWithBlock:^id(BFTask *task) {
        if (task.error) {
            [myDelegate StopIndicator];
        } else {
            
            //            AWSS3ListObjectsOutput *listObjectsOutput = task.result;
            //            for (AWSS3Object *s3Object in listObjectsOutput.contents) {
            for (int i=0; i<imageName.count; i++) {
                NSString *downloadingFilePath = [[NSTemporaryDirectory() stringByAppendingPathComponent:@"download"] stringByAppendingPathComponent:[imageName objectAtIndex:i]];
                NSURL *downloadingFileURL = [NSURL fileURLWithPath:downloadingFilePath];
                
                //            if ([[NSFileManager defaultManager] fileExistsAtPath:downloadingFilePath]) {
                //                [self.collection addObject:downloadingFileURL];
                //            } else {
                AWSS3TransferManagerDownloadRequest *downloadRequest = [AWSS3TransferManagerDownloadRequest new];
                downloadRequest.bucket = [NSString stringWithFormat:@"%@/%@",S3BucketName,folderName];
                downloadRequest.key = [imageName objectAtIndex:i];
                downloadRequest.downloadingFileURL = downloadingFileURL;
                [imagesArray addObject:downloadRequest];
                
                [self download:downloadRequest index:i];
                //            }
            }
            
            dispatch_async(dispatch_get_main_queue(), ^{
                
                [_delegate ListObjectprocessCompleted:imagesArray];
            });
        }
        return nil;
    }];
}


- (void)download:(AWSS3TransferManagerDownloadRequest *)downloadRequest index : (NSUInteger)index {
    //    switch (downloadRequest.state) {
    //        case AWSS3TransferManagerRequestStateNotStarted:
    //        case AWSS3TransferManagerRequestStatePaused:
    //        {
    AWSS3TransferManager *transferManager = [AWSS3TransferManager defaultS3TransferManager];
    [[transferManager download:downloadRequest] continueWithBlock:^id(BFTask *task) {
        if ([task.error.domain isEqualToString:AWSS3TransferManagerErrorDomain]
            && task.error.code == AWSS3TransferManagerErrorPaused) {
        } else if (task.error) {
            [myDelegate StopIndicator];
        } else {
            //                    __weak AddServiceViewController *weakSelf = self;
            dispatch_async(dispatch_get_main_queue(), ^{

                
                [_delegate DownloadprocessCompleted:downloadRequest index:index];
                //                        AddServiceViewController *strongSelf = weakSelf;
                //
                //                        NSUInteger index = [strongSelf.collection indexOfObject:downloadRequest];
//                [imagesArray replaceObjectAtIndex:index
//                                       withObject:downloadRequest.downloadingFileURL];
//                NSIndexPath *indexPath = [NSIndexPath indexPathForRow:index inSection:0];
//                [collectionView reloadItemsAtIndexPaths:@[indexPath]];
            });
        }
        return nil;
    }];
    //        }
    //            break;
    //        default:
    //            break;
    //    }
}

-(void)BusinessProfilelistObjects:(id)sender ImageName:(NSMutableArray*)imageName folderName:(NSString *)folderName key:(int)section
{
//    appdelegate=(AppDelegate *)[UIApplication sharedApplication].delegate;
    NSError *error = nil;
    if (![[NSFileManager defaultManager] createDirectoryAtPath:[NSTemporaryDirectory() stringByAppendingPathComponent:@"download"]
                                   withIntermediateDirectories:YES
                                                    attributes:nil
                                                         error:&error]) {
    }
    
    AWSS3ListObjectsRequest *listObjectsRequest = [AWSS3ListObjectsRequest new];
    
    
    listObjectsRequest.bucket = S3BucketName;
    NSMutableArray *imagesArray=[NSMutableArray new];
//    [[s3 listObjects:listObjectsRequest] continueWithBlock:^id(BFTask *task) {
//        if (myDelegate.shouldCancelDownload==0) {
//            if (task.error) {
//                [myDelegate StopIndicator];
//            } else {
//                
                //            AWSS3ListObjectsOutput *listObjectsOutput = task.result;
                //            for (AWSS3Object *s3Object in listObjectsOutput.contents) {
                for (int i=0; i<imageName.count; i++) {
                    NSString *downloadingFilePath = [[NSTemporaryDirectory() stringByAppendingPathComponent:@"download"] stringByAppendingPathComponent:[imageName objectAtIndex:i]];
                    
                    NSURL *downloadingFileURL = [NSURL fileURLWithPath:downloadingFilePath];
                    
                    //            if ([[NSFileManager defaultManager] fileExistsAtPath:downloadingFilePath]) {
                    //                [self.collection addObject:downloadingFileURL];
                    //            } else {
                    AWSS3TransferManagerDownloadRequest *downloadRequest = [AWSS3TransferManagerDownloadRequest new];
                    downloadRequest.bucket = [NSString stringWithFormat:@"%@/%@",S3BucketName,folderName];
                    downloadRequest.key = [imageName objectAtIndex:i];
                    downloadRequest.downloadingFileURL = downloadingFileURL;
                    [imagesArray addObject:downloadRequest];
                    
                    [self BusinessProfiledownload:downloadRequest index:i key:section];
                    //            }
                }
//                
                dispatch_async(dispatch_get_main_queue(), ^{
                    
                    [_delegate BusinessProfileListObjectprocessCompleted:imagesArray key:section];
                });
//            }
//            return nil;
//        }
//        return nil;
//    }];
}


- (void)BusinessProfiledownload:(AWSS3TransferManagerDownloadRequest *)downloadRequest index : (NSUInteger)index key:(int)section {
    //    switch (downloadRequest.state) {
    //        case AWSS3TransferManagerRequestStateNotStarted:
    //        case AWSS3TransferManagerRequestStatePaused:
    //        {
    AWSS3TransferManager *transferManager = [AWSS3TransferManager defaultS3TransferManager];
    
    if (myDelegate.shouldCancelDownload==1) {
        [[downloadRequest cancel] continueWithBlock:^id(BFTask *task) {
            if (task.error) {
            }
            return nil;
        }];
    }
    else{
        [[transferManager download:downloadRequest] continueWithBlock:^id(BFTask *task) {
            if (myDelegate.shouldCancelDownload==1) {
                [[downloadRequest cancel] continueWithBlock:^id(BFTask *task) {
                    if (task.error) {
                    }
                    return nil;
                }];
            }
            else{
                if ([task.error.domain isEqualToString:AWSS3TransferManagerErrorDomain]
                    && task.error.code == AWSS3TransferManagerErrorPaused) {
                } else if (task.error) {
                    [myDelegate StopIndicator];
                } else {
                    
                    //                    __weak AddServiceViewController *weakSelf = self;
                    dispatch_async(dispatch_get_main_queue(), ^{
                        
                        
                        [_delegate BusinessProfileDownloadprocessCompleted:downloadRequest index:index key:section];
                        //                        AddServiceViewController *strongSelf = weakSelf;
                        //
                        //                        NSUInteger index = [strongSelf.collection indexOfObject:downloadRequest];
                        //                [imagesArray replaceObjectAtIndex:index
                        //                                       withObject:downloadRequest.downloadingFileURL];
                        //                NSIndexPath *indexPath = [NSIndexPath indexPathForRow:index inSection:0];
                        //                [collectionView reloadItemsAtIndexPaths:@[indexPath]];
                    });
                }
                return nil;
            }
            
            return nil;}
         
         ];
        
        //            break;
        //        default:
        //            break;
        //    }
    }
}

@end