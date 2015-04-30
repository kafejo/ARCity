//
//  LoadingView.m
//  ARCity
//
//  Created by Aleš Kocur on 28/04/15.
//  Copyright (c) 2015 metaio GmbH. All rights reserved.
//

#import "LoadingView.h"

@implementation LoadingView

- (void)show {
    self.hidden = NO;
    
}

- (void)hide {
    
    [UIView animateWithDuration:1.0 delay:0.0 options:UIViewAnimationOptionCurveEaseIn animations:^{
        self.loadingLabel.alpha = 0.0;
    } completion:^(BOOL finished) {
        self.hidden = YES;
    }];
}


@end
