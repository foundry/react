//
//  ImagePickerSegmentedControl.m
//  
//
//  Created by foundry / Foundry on 06/01/2013.
//  Copyright (c) 2013 foundry. Feel free to copy.
//
//  Permission is given to use this source code file without charge in any
//  project, commercial or otherwise, entirely at your risk, with the condition
//  that any redistribution (in part or whole) of source code must retain
//  this copyright and permission notice. Attribution in compiled projects is
//  appreciated but not required.
//

#import "CVImagePickerSegmentedControl.h"

@interface CVImagePickerSegmentedControl()

@property (nonatomic, strong) UIPopoverController* popOverController;
- (void)setupImagePicker:(UIImagePickerControllerSourceType)sourceType;
+ (void)saveCameraPrefs:(UIImagePickerController*)picker;
+ (void)setCameraPrefs:(UIImagePickerController*)imagePicker;


@end

@implementation CVImagePickerSegmentedControl

@synthesize delegate;
@synthesize transitionStyle = _transitionStyle;
@synthesize imagePickerControlsPresenting = _imagePickerControlsPresenting;
@synthesize imagePickerControlsDismissing = _imagePickerControlsDismissing;

- (IBAction)segmentValueChanged:(id)sender
{
        //using GCD to get responsive segment presses
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        dispatch_async(dispatch_get_main_queue(), ^{
            if ([sender selectedSegmentIndex]==0){
                [self setupImagePicker:UIImagePickerControllerSourceTypePhotoLibrary];
            }else {
                [self setupImagePicker:UIImagePickerControllerSourceTypeCamera];
            }
        });
    });
}

    //initialising from code
- (id)init
{
    return[self initWithItems:[NSArray arrayWithObjects:@"Picture library",@"Camera", nil]];
}

- (id) initWithItems:(NSArray *)items  //designated initialiser
{
    self = [super initWithItems:items];
    if (self) {
            //defaults to override
        
        self.segmentedControlStyle = UISegmentedControlStyleBar;
        self.tintColor = [UIColor lightGrayColor];
        self.momentary = YES;
        [self initialise];
    }
    return self;
}

    //initialising from storyboard
- (id) initWithCoder:(NSCoder *)aDecoder
{
    if (self =  [super initWithCoder:aDecoder])
        {
        [self initialise];
        }
    return self;
}


- (void) initialise
{
    
    [self addTarget:self
             action:@selector(segmentValueChanged:)
   forControlEvents:UIControlEventValueChanged];
    _transitionStyle = UIModalTransitionStyleCoverVertical;
    _imagePickerControlsPresenting = YES;
    _imagePickerControlsDismissing = YES;
    
}



#pragma mark - ##### IMAGEPICKER #####

- (void) setupImagePicker:(UIImagePickerControllerSourceType)type
{
    UIImagePickerController* imagePicker = [[UIImagePickerController alloc] init];
    if (type == UIImagePickerControllerSourceTypeCamera
        && [UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
        [imagePicker setSourceType:UIImagePickerControllerSourceTypeCamera];
        imagePicker.mediaTypes =[UIImagePickerController availableMediaTypesForSourceType:imagePicker.sourceType];
        [[self class] setCameraPrefs:imagePicker];
    } else {
        [imagePicker setSourceType:UIImagePickerControllerSourceTypePhotoLibrary];
        imagePicker.mediaTypes =[UIImagePickerController availableMediaTypesForSourceType:imagePicker.sourceType];
    }
    [imagePicker setDelegate:self];
    imagePicker.modalTransitionStyle = self.transitionStyle; 
    
        
    if (self.imagePickerControlsPresenting) {
        
        if ([[UIDevice currentDevice] userInterfaceIdiom] ==UIUserInterfaceIdiomPad
            // && (  type == UIImagePickerControllerSourceTypePhotoLibrary
            //  ||type ==UIImagePickerControllerSourceTypeSavedPhotosAlbum)
            )
            {  //iPad
            self.popOverController =
                [[UIPopoverController alloc] initWithContentViewController:imagePicker];
            UIPopoverArrowDirection arrowDirection = UIPopoverArrowDirectionAny;
            UIView* view = self.delegate.view;
            
            CGRect rect = self.frame;
            int arrowShift = (type == UIImagePickerControllerSourceTypeCamera)? 1:-1;
            rect.origin = CGPointMake(rect.origin.x+arrowShift*rect.size.width/4,rect.origin.y);
            if ([self.delegate respondsToSelector:
                 @selector(willPresentPopOverImagePickerController:popOver:withRect:inView:arrowDirection:)]) {
            [self.delegate willPresentPopOverImagePickerController:imagePicker
                                                    popOver:self.popOverController
                                                   withRect:&rect
                                                     inView:&view
                                             arrowDirection:&arrowDirection];
            }
            if (CGRectIsEmpty(rect)) rect = view.bounds;
            [self.popOverController presentPopoverFromRect:rect
                                                    inView:view
                                  permittedArrowDirections:arrowDirection
                                                  animated:YES];
            } else {  //iPhone
                if ([self.delegate respondsToSelector:@selector(willPresentImagePicker:)]) {
                    [self.delegate willPresentImagePicker:imagePicker];
                }
                [self.delegate presentViewController:imagePicker
                                            animated:YES
                                          completion:nil];
           }
    } else {
        [self.delegate presentViewController:imagePicker];
    }
    
    
}

#pragma mark - ##### IMAGEPICKER DELEGATE #####

- (void) imagePickerController:(UIImagePickerController *)picker
 didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    UIImage* image = [info objectForKey:UIImagePickerControllerOriginalImage];
    if ([picker sourceType] == UIImagePickerControllerSourceTypeCamera) {
        UIImageWriteToSavedPhotosAlbum(image, self, nil, nil);
        [[self class] saveCameraPrefs:picker];
    }
    [self.delegate cvImagePickerControl:self
                  didFinishPickingMedia:image
                               withInfo:info];
    if (self.imagePickerControlsDismissing) {
        if (self.popOverController) {
            [self.popOverController dismissPopoverAnimated:YES];
        } else {
            [self.delegate dismissViewControllerAnimated:YES
                                                         completion:nil];
        }
    } else {
        [self.delegate dismissViewController];
    }
}

#pragma mark - ##### CLASS UTILITY METHODS #####

#define DEFAULTS_FLASH_MODE @"HWImagePickerFlashMode"
#define DEFAULTS_CAMERA_DEVICE @"HWImagePickerCameraDevice"

+ (void)saveCameraPrefs:(UIImagePickerController*)picker
{
    NSUserDefaults* defaults = [NSUserDefaults standardUserDefaults];
    NSString* flashKey = [NSString stringWithFormat:@"%@%@",[self class],DEFAULTS_FLASH_MODE];
    NSString* deviceKey = [NSString stringWithFormat:@"%@%@",[self class],DEFAULTS_CAMERA_DEVICE];
    [defaults setInteger:[picker cameraFlashMode] forKey:flashKey];
    [defaults setInteger:[picker cameraDevice] forKey:deviceKey];
}



+ (void) setCameraPrefs:(UIImagePickerController*)imagePicker
{
    NSUserDefaults* defaults = [NSUserDefaults standardUserDefaults];
    NSString* flashKey = [NSString stringWithFormat:@"%@%@",[self class],DEFAULTS_FLASH_MODE];
    NSString* deviceKey = [NSString stringWithFormat:@"%@%@",[self class],DEFAULTS_CAMERA_DEVICE];
    
    
    if ([defaults integerForKey:flashKey]) {
        UIImagePickerControllerCameraFlashMode flashMode = [defaults integerForKey:flashKey];
        [imagePicker setCameraFlashMode:flashMode];
    }
    if ([defaults integerForKey:deviceKey]) {
        UIImagePickerControllerCameraDevice cameraDevice = [defaults integerForKey:deviceKey];
        [imagePicker setCameraDevice:cameraDevice];
    }
}


@end
