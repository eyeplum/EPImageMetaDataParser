//
//  EPAppDelegate.m
//  EPImageMetaDataSample
//
//  Created by Yan Li on 3/8/14.
//  Copyright (c) 2014 eyeplum. All rights reserved.
//

#import "EPAppDelegate.h"
#import "EPImageMetaDataParser.h"

@interface EPAppDelegate ()

@property (nonatomic, weak) IBOutlet NSTextField *textField;
@property (nonatomic, weak) IBOutlet NSButton *parseButton;
@property (nonatomic, unsafe_unretained) IBOutlet NSTextView *textView;

- (IBAction)parseMetaData:(id)sender;

@end

@implementation EPAppDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
    // ...
}


- (IBAction)parseMetaData:(id)sender {
    NSURL *imageURL = [NSURL URLWithString:self.textField.stringValue];
    [self.parseButton setEnabled:NO];

    [EPImageMetaDataParser parseImageMetaDataWithURL:imageURL completionHandler:^(BOOL success, NSDictionary *metaData, NSError *error) {
        [self.parseButton setEnabled:YES];
        [self.textView setString:metaData.description ?: error.description];
    }];
}

@end
