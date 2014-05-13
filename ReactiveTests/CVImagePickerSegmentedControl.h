//
//  ImagePickerSegmentedControl.h
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
// CVImagePickerSegmentedControl presents a 2-button segmented controller and contains all methods required to present and dismiss a camera or photolibrary picker, passing the selected image up to its delegate. The delegate should normally be a UIViewController, as we delegate the actual presenting and dismissing.

/*
 minimal usage  
      _in code_
     CVImagePickerSegmentedControl* imagePickerControl = [[CVImagePickerSegmentedControl alloc] init];
     [imagePickerControl setDelegate:self];   //delegate must be a UIViewController
     
     _xib/storyboard_
     Drag out a 2-segment segmented control. Change it's class to this class. 
     Set it's delegate to the relevant View Controller.
 
    The only delegate method that needs to be implemented is:
    - (void) cvImagePickerControl:(CVImagePickerSegmentedControl*)control
            didFinishPickingImage:(UIImage*)image
                            info:(NSDictionary*)info;
    This passes the image data back to the viewController.
 
 */


#import <UIKit/UIKit.h>
@class UISegmentedControl;
@class CVImagePickerSegmentedControl;

@protocol CVImagePickerSegmentedControlDelegate

@required

- (void) cvImagePickerControl:(CVImagePickerSegmentedControl*)control
        didFinishPickingMedia:(UIImage*)image
                     withInfo:(NSDictionary*)info;
    //we don't need to implement these in the delegate if we are controlling the presenting and dismissing from this class, but they do need to be present in the delegate as methods to override (i.e. the delegate needs to be a UIViewController)
- (void) presentViewController:(UIViewController *)viewControllerToPresent
                      animated:(BOOL)flag
                    completion:(void (^)(void))completion;
- (void) dismissViewControllerAnimated:(BOOL)flag
                            completion:(void (^)(void))completion;

   //default viewForPopOver, it doesn't need implementing, it's a standard viewController property.
- (UIView*)view; 


@optional
- (void) presentViewController:(UIImagePickerController*)imagePicker;
- (void) dismissViewController;

    //for iPad
- (void)willPresentPopOverImagePickerController:(UIImagePickerController*)imagePicker
                                        popOver:(UIPopoverController*)popOver
                                     withRect:(CGRect*)rectPtr
                                         inView:(UIView *__autoreleasing *)viewPtr
                               arrowDirection:(UIPopoverArrowDirection*)arrowPtr;

    //for iPhone
- (void)willPresentImagePicker:(UIImagePickerController*)imagePicker;

/*
 Optional methods to access/modify imagePicker and popOver properties.
 Example usage
 - (void)willPresentImagePickerController:(UIImagePickerController*)imagePicker
                                  popOver:(UIPopoverController*)popOver
                                 withRect:(CGRect*)rectPtr
                                   inView:(UIView *__autoreleasing *)viewPtr;
                           arrowDirection:(UIPopoverArrowDirection*)arrowPtr;

 {

    *rectPtr = [[[self.subview subviews]objectAtIndex:0] frame];
    *viewPtr = self.subview;
    *arrowPtr = UIPopoverArrowDirectionUp;
 
 
    //rects, views, arrowDirection passed by reference so we can modify them in place.
    //sensible defaults are provided so none of these are required
 }

 
 */




@end

@interface CVImagePickerSegmentedControl : UISegmentedControl <UINavigationControllerDelegate, UIImagePickerControllerDelegate>

@property (nonatomic, weak) IBOutlet id <CVImagePickerSegmentedControlDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate> delegate;

@property (nonatomic, assign) UIModalTransitionStyle transitionStyle;
    //defaults to UIModalTransitionStyleCoverVertical if not set

@property (nonatomic, assign) BOOL imagePickerControlsPresenting;
@property (nonatomic, assign) BOOL imagePickerControlsDismissing;
    //default is YES (this class controls presenting/dismissing)
    //set to NO if we are controlling presenting/dismissing in the delegate.


@end
