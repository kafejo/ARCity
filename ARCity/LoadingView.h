//
//  LoadingView.h
//  ARCity
//
//  Created by Aleš Kocur on 28/04/15.
//  Copyright (c) 2015 metaio GmbH. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface LoadingView : UIView


@property (strong, nonatomic) IBOutlet UILabel *loadingLabel;

- (void)show;
- (void)hide;

@end
