//
//  JMViewModel.h
//  ReactiveTests
//
//  Created by foundry on 12/05/2014.
//  Copyright (c) 2014 foundry - feel free to copy
//

#import <Foundation/Foundation.h>

@interface JMViewModel : NSObject

@property (nonatomic, assign) float sliderValue;
@property (nonatomic, strong) UIImage* image;

- (RACSignal*)sliderValueTextSignal;
- (RACSignal*)imageExistsSignal;

@end
