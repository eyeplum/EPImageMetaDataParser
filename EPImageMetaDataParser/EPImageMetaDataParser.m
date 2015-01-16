//
//  EPImageMetaDataParser.m
//  EPImageMetaDataSample
//
//  Created by Yan Li on 3/8/14.
//  Copyright (c) 2014 eyeplum. All rights reserved.
//

#import "EPImageMetaDataParser.h"
#import <ImageIO/ImageIO.h>


static NSString * const kEPImageMetaDataParserErrorDomain = @"com.eyeplum.metaDataParserError";

static const NSInteger  kInvalidURLErrorCode    = -100;
static NSString * const kInvalidURLError        = @"Invalid image URL.";

static const NSInteger  kMetaDataParseErrorCode = -200;
static NSString * const kMetaDataParseError     = @"Failed to parse meta data.";

static const NSUInteger kDefaultByteLength      = 65 * 1024;

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

@property (nonatomic, strong) NSURLConnection *connection;
@property (nonatomic, strong) NSMutableData *imageData;
@property (nonatomic, strong) NSDictionary *metaData;
@property (nonatomic, assign) BOOL connectionCancelled;

@end


@implementation EPImageMetaDataParser

#pragma mark - Convenient Method

+ (void)parseImageMetaDataWithURL:(NSURL *)imageURL completionHandler:(EPImageMetaDataParseCompletionBlock)completionBlock {
    if (!imageURL) {
        if (completionBlock) {
            completionBlock(NO, nil, EPImageMetaDataParserError(kInvalidURLErrorCode, kInvalidURLError));
        }
        return;
    }

    EPImageMetaDataParser *parser = [[EPImageMetaDataParser alloc] initWithImageURL:imageURL];
    [parser setCompletionBlock:completionBlock];
    [parser start];
}


#pragma mark - Initializer

- (instancetype)initWithImageURL:(NSURL *)imageURL {
    if (!imageURL) {
        return nil;
    }

    if (self = [super init]) {
        _markerRange = NSMakeRange(0, kDefaultByteLength);
        _imageData = [NSMutableData data];
        _metaData = [NSDictionary dictionary];
        _connectionCancelled = NO;

        _connection = [[NSURLConnection alloc] initWithRequest:EPImageMetaDataParseRequest(imageURL, self.markerRange)
                                                      delegate:self
                                              startImmediately:NO];
    }

    return self;
}


#pragma mark - Start Connection

- (void)start {
    [self.connection start];
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
