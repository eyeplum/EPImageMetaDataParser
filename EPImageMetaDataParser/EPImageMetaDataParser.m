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

static const NSUInteger kDefaultByteLength = 64 * 1024;

static NSError *EPImageMetaDataParserError(NSInteger errorCode, NSString *errorReason)
{
    @autoreleasepool {
        return [NSError errorWithDomain:kEPImageMetaDataParserErrorDomain
                                   code:errorCode
                               userInfo:@{NSLocalizedFailureReasonErrorKey:errorReason}];
    }
}

static NSMutableURLRequest *EPImageMetaDataParseRequest(NSURL *imageURL, NSRange markerRange)
{
    @autoreleasepool {
        NSMutableURLRequest *imageFetchRequest = [[NSMutableURLRequest alloc] initWithURL:imageURL
                                                                              cachePolicy:NSURLRequestReloadIgnoringLocalAndRemoteCacheData
                                                                          timeoutInterval:0];

        if (!NSEqualRanges(NSMakeRange(0, 0), markerRange)) {
            NSString *rangeString = [NSString stringWithFormat:@"bytes=%@-%@", @(markerRange.location), @(NSMaxRange(markerRange))];
            [imageFetchRequest setValue:rangeString forHTTPHeaderField:@"Range"];
        }

        return imageFetchRequest;
    }
}

static NSDictionary *EPImageMetaDataWithImageData(NSData *imageData)
{
    @autoreleasepool {
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
}


@interface EPImageMetaDataParser () <NSURLConnectionDataDelegate>

@property (nonatomic, copy) EPImageMetaDataParseCompletionBlock completionBlock;
@property (nonatomic, strong) NSMutableData *imageData;
@property (nonatomic, strong) NSDictionary *metaData;
@property (nonatomic, assign) BOOL connectionCancelled;

@end


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


- (instancetype)init {
    if (self = [super init]) {
        _markerRange = NSMakeRange(0, kDefaultByteLength);
    }

    return self;
}


#pragma mark - Public Method

- (void)parseMetaDataWithImageAtURL:(NSURL *)imageURL
                  completionHandler:(EPImageMetaDataParseCompletionBlock)completionBlock {

    if (!imageURL) {
        if (completionBlock) {
            completionBlock(NO, nil, EPImageMetaDataParserError(kInvalidURLErrorCode, kInvalidURLError));
        }
        return;
    }

    self.completionBlock = completionBlock;
    self.imageData = [NSMutableData data];
    self.metaData = [NSDictionary dictionary];
    self.connectionCancelled = NO;

    [NSURLConnection connectionWithRequest:EPImageMetaDataParseRequest(imageURL, self.markerRange)
                                  delegate:self];
}


#pragma mark - NSURLConnectionDelegate

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
    if (self.connectionCancelled) {
        return;
    }

    if (self.completionBlock) {
        self.completionBlock(NO, nil, error);
    }

    self.imageData = nil;
    self.completionBlock = nil;
    self.metaData = nil;
}


- (void)connectionDidFinishLoading:(NSURLConnection *)connection {
    if (self.connectionCancelled) {
        return;
    }

    if (self.completionBlock) {
        NSError *parseError;

        BOOL success = self.metaData.count > 0;
        if (!success) {
            parseError = EPImageMetaDataParserError(kMetaDataParseErrorCode, kMetaDataParseError);
        }

        self.completionBlock(success, self.metaData, parseError);
    }

    self.imageData = nil;
    self.completionBlock = nil;
    self.metaData = nil;
}


- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
    if (self.connectionCancelled) {
        return;
    }

    [self.imageData appendData:data];

    self.metaData = EPImageMetaDataWithImageData(self.imageData);
    if (self.metaData.count > 0) {
        [connection cancel];
        [self connectionDidFinishLoading:connection];
        self.connectionCancelled = YES;
    }
}


- (NSCachedURLResponse *)connection:(NSURLConnection *)connection willCacheResponse:(NSCachedURLResponse *)cachedResponse {
    return nil;
}

@end
