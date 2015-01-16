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

/**
 * The range of data can be downloaded to parse metadata.
 * If set to {0, 0}, the download will continue until there is no more data.
 * Default value is {0, 66560} (65KB).
 */
@property (nonatomic, assign) NSRange markerRange;

/**
 * The Completion Block.
 * Will get called when parse succeeded or failed, or the image request failed.
 */
@property (nonatomic, copy) EPImageMetaDataParseCompletionBlock completionBlock;

/**
 * Convenient method to parse image metadata at given URL.
 */
+ (void)parseImageMetaDataWithURL:(NSURL *)imageURL
                completionHandler:(EPImageMetaDataParseCompletionBlock)completionBlock;

/**
 * Create a new instance of EPImageMetaDataParser with an image URL.
 * The parsing will NOT start automatically.
 * You MUST call [parser start]; in order to start the parse action.
 * Or you can use the convenient method above.
 */
- (instancetype)initWithImageURL:(NSURL *)imageURL;

/**
 * Start the parse action, when succeeded or failed, completionBlock will get called.
 */
- (void)start;

@end
