//
//  JMViewController.m
//  ReactiveTests
//
//  Created by foundry on 10/05/2014.
//  Copyright (c) 2014 foundry - feel free to copy
//

#import "JMViewController.h"
#import "CVImagePickerSegmentedControl.h"
#import "JMViewModel.h"
@interface JMViewController ()<CVImagePickerSegmentedControlDelegate>
@property (weak, nonatomic) IBOutlet UINavigationBar* frostedPanel;
@property (weak, nonatomic) IBOutlet UIImageView *imageView;
@property (weak, nonatomic) IBOutlet UIButton *button;
@property (weak, nonatomic) IBOutlet UISlider *slider;
@property (weak, nonatomic) IBOutlet UILabel *label;
@property (strong, nonatomic) JMViewModel* viewModel;

@end

@implementation JMViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.viewModel = [[JMViewModel alloc] init];
    [self setupViews];
    [self setupRAC];
    self.viewModel.sliderValue = 0.5;
}

- (void) setupViews {
    self.frostedPanel.translucent = YES;
    self.frostedPanel.barStyle = UIBarStyleBlack;
}
#pragma mark - setup
- (void)setupRAC {
    
    [[self.button rac_signalForControlEvents:UIControlEventTouchUpInside]
     subscribeNext:^(id x) {
        self.viewModel.image = nil;
    }];
    
    [[self.slider rac_signalForControlEvents:UIControlEventValueChanged]
     subscribeNext:^(UISlider* slider) {
        self.viewModel.sliderValue = slider.value;
    }];
    
       RAC(self.label, text, @"")
    =  self.viewModel.sliderValueTextSignal;
    
       RAC(self.button, hidden, @YES)
    =  RAC(self.slider, hidden, @YES)
    =  RAC(self.label,  hidden, @YES)
    =  self.viewModel.imageExistsSignal;

       RAC(self.imageView, image, nil)
    =  RACObserve(self.viewModel,image);
    
       RAC(self.imageView, alpha, @1.0)
    =  RACObserve(self.viewModel, sliderValue);
}


- (void)cvImagePickerControl:(CVImagePickerSegmentedControl *)control
       didFinishPickingMedia:(UIImage *)image
                    withInfo:(NSDictionary *)info {
    self.viewModel.image  = image;
}









@end
