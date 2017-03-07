//
//  AWSDownload.h
//  Sure_sp
//
//  Created by Ranosys on 13/04/15.
//  Copyright (c) 2015 Ranosys. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "BFTask.h"
#import <AWSS3/AWSS3.h>
#import "Constants.h"

@protocol AWSDownloadDelegate <NSObject>
@optional
- (void) BusinessProfileListObjectprocessCompleted:(NSMutableArray *)imagesArray key:(int)section;
- (void) BusinessProfileDownloadprocessCompleted:(AWSS3TransferManagerDownloadRequest *)downloadRequest index : (NSUInteger)index key:(int)section;
- (void) ListObjectprocessCompleted:(NSMutableArray *)imagesArray;
- (void) DownloadprocessCompleted:(AWSS3TransferManagerDownloadRequest *)downloadRequest index : (NSUInteger)index;

@end
// Protocol Definition ends here
@interface AWSDownload : NSObject{
 id <AWSDownloadDelegate> _delegate;
}
@property (nonatomic,strong) id delegate;


-(void)listObjects:(id)sender ImageName:(NSMutableArray*)imageName folderName:(NSString *)folderName;
- (void)download:(AWSS3TransferManagerDownloadRequest *)downloadRequest index : (NSUInteger)index;
-(void)BusinessProfilelistObjects:(id)sender ImageName:(NSMutableArray*)imageName folderName:(NSString *)folderName key:(int)section;
- (void)BusinessProfiledownload:(AWSS3TransferManagerDownloadRequest *)downloadRequest index : (NSUInteger)index key:(int)section;
@end