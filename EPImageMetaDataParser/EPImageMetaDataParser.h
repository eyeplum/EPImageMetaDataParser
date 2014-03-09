//
//  EPImageMetaDataParser.h
//  EPImageMetaDataSample
//
//  Created by Yan Li on 3/8/14.
//  Copyright (c) 2014 eyeplum. All rights reserved.
//

#import "EPImageMetaDataConstants.h"

typedef void(^EPImageMetaDataParseCompletionBlock)(BOOL success, NSDictionary *metaData, NSError *error);

@interface EPImageMetaDataParser : NSObject

// Default range is 0-64KB
@property (nonatomic, assign) NSRange markerRange;
@property (nonatomic, copy) EPImageMetaDataParseCompletionBlock completionBlock;

+ (void)parseImageMetaDataWithURL:(NSURL *)imageURL
                completionHandler:(EPImageMetaDataParseCompletionBlock)completionBlock;

- (instancetype)initWithImageURL:(NSURL *)imageURL;
- (void)start;

@end
