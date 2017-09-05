//
//  GizWeakScriptMessageDelegate.m
//  GizIndustrySolution
//
//  Created by Jubal on 2017/1/5.
//  Copyright © 2017年 Gizwits. All rights reserved.
//

#import "GizWeakScriptMessageDelegate.h"

@implementation GizWeakScriptMessageDelegate

- (instancetype)initWithDelegate:(id<WKScriptMessageHandler>)scriptDelegate {
    self = [super init];
    if (self) {
        _scriptDelegate = scriptDelegate;
    }
    return self;
}

- (void)userContentController:(WKUserContentController *)userContentController didReceiveScriptMessage:(WKScriptMessage *)message {
    [self.scriptDelegate userContentController:userContentController didReceiveScriptMessage:message];
}

@end
