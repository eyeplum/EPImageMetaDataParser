//
//  EPImageMetaDataParser.h
//  EPImageMetaDataSample
//
//  Created by Yan Li on 3/8/14.
//  Copyright (c) 2014 eyeplum. All rights reserved.
//

#import "EPImageMetaDataConstants.h"

typedef void(^EPImageMetaDataParseCompletionBlock)(BOOL, NSDictionary *, NSError *);

@interface EPImageMetaDataParser : NSObject

// Default range is 0-64KB
@property (nonatomic, assign) NSRange markerRange;

+ (instancetype)sharedMetaDataParser;
- (instancetype)init;

- (void)parseMetaDataWithImageAtURL:(NSURL *)imageURL
                  completionHandler:(EPImageMetaDataParseCompletionBlock)completionBlock;

@end
