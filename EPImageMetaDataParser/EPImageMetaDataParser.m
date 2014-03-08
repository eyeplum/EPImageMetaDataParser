//
//  EPImageMetaDataParser.m
//  EPImageMetaDataSample
//
//  Created by Yan Li on 3/8/14.
//  Copyright (c) 2014 eyeplum. All rights reserved.
//

#import "EPImageMetaDataParser.h"

static NSString * const kEPImageMetaDataParserErrorDomain = @"com.eyeplum.metaDataParserError";

static const NSInteger  kInvalidURLErrorCode = -100;
static NSString * const kInvalidURLError     = @"Image URL is invalid.";

static const NSInteger  kMetaDataParseErrorCode = -200;
static NSString * const kMetaDataParseError     = @"Failed to parse meta data.";

static const NSUInteger kFixedBytesRange = 1024 * 64;

static NSError *EPImageMetaDataParserError(NSInteger errorCode, NSString *errorReason)
{
    @autoreleasepool {
        return [NSError errorWithDomain:kEPImageMetaDataParserErrorDomain
                                   code:errorCode
                               userInfo:@{NSLocalizedFailureReasonErrorKey:errorReason}];
    }
}

static NSMutableURLRequest *EPImageMetaDataParseRequest(NSURL *imageURL, NSUInteger bytesOffset, NSUInteger bytesRange) {
    @autoreleasepool {
        NSMutableURLRequest *imageFetchRequest = [[NSMutableURLRequest alloc] initWithURL:imageURL];
        NSString *rangeString = [NSString stringWithFormat:@"bytes=%@-%@", @(bytesOffset), @(bytesRange)];
        [imageFetchRequest setValue:rangeString forHTTPHeaderField:@"Range"];
        return imageFetchRequest;
    }
}


@implementation EPImageMetaDataParser

#pragma mark - Shared Instance

+ (instancetype)sharedMetaDataParser {
    static dispatch_once_t onceToken;
    static EPImageMetaDataParser *_sharedParser;
    dispatch_once(&onceToken, ^{
        _sharedParser = [[self alloc] init];
    });

    return _sharedParser;
}


#pragma mark - Public Method

- (void)parseMetaDataWithImageAtURL:(NSURL *)imageURL
                  completionHandler:(void (^)(BOOL success, NSDictionary *metaData, NSError *error))completion {

    if (!imageURL) {
        if (completion) {
            completion(NO, nil, EPImageMetaDataParserError(kInvalidURLErrorCode, kInvalidURLError));
        }
        return;
    }

    // FIXME: Hardcoded range is bad.
    [NSURLConnection sendAsynchronousRequest:EPImageMetaDataParseRequest(imageURL, 0, kFixedBytesRange)
                                       queue:[NSOperationQueue mainQueue]
                           completionHandler:^(NSURLResponse *response, NSData *data, NSError *connectionError) {

                               if (data == nil) {
                                   if (completion) {
                                       completion(NO, nil, connectionError);
                                   }
                                   return;
                               }

                               NSDictionary *metaData = [self metaDataWithImageData:data];
                               if (metaData == nil) {
                                   if (completion) {
                                       completion(NO, nil, EPImageMetaDataParserError(kMetaDataParseErrorCode, kMetaDataParseError));
                                   }
                                   return;
                               }

                               if (completion) {
                                   completion(YES, metaData, nil);
                               }

                           }];
}


#pragma mark - Utility

- (NSDictionary *)metaDataWithImageData:(NSData *)imageData {
    if (imageData == nil) {
        return nil;
    }

    CGImageSourceRef imageSource = CGImageSourceCreateWithData((__bridge CFDataRef) imageData, NULL);
    if (imageSource == nil) {
        return nil;
    }

    NSDictionary *metaDataDictionary = CFBridgingRelease(CGImageSourceCopyPropertiesAtIndex(imageSource, 0, NULL));
    CFRelease(imageSource);

    return metaDataDictionary;
}

@end
