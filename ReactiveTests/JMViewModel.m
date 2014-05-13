//
//  JMViewModel.m
//  ReactiveTests
//
//  Created by foundry on 12/05/2014.
//  Copyright (c) 2014 foundry - feel free to copy
//

#import "JMViewModel.h"

@implementation JMViewModel


- (RACSignal*)sliderValueTextSignal {
    return [RACObserve(self, sliderValue)
     map:^id(NSNumber* value){
         return [NSString stringWithFormat:@"%.2f",value.floatValue];
     }];
}
- (RACSignal*)imageExistsSignal {
   return [RACObserve(self, image)
     map:^id(id value) {
         return @(value==nil);
     }];
}


@end
