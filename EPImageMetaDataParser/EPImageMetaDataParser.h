//
//  EPImageMetaDataParser.h
//  EPImageMetaDataSample
//
//  Created by Yan Li on 3/8/14.
//  Copyright (c) 2014 eyeplum. All rights reserved.
//



@interface EPImageMetaDataParser : NSObject

+ (instancetype)sharedMetaDataParser;

- (void)parseMetaDataWithImageAtURL:(NSURL *)imageURL
                  completionHandler:(void(^)(BOOL success, NSDictionary *metaData, NSError *error))completion;

@end
