//
//  ViewController.h
//  ToyCamera14
//
//  Created by 関口流星 on 2015/11/26.
//  Copyright © 2015年 関口流星. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ViewController : UIViewController
<UINavigationControllerDelegate,
UIImagePickerControllerDelegate,
UIActionSheetDelegate
>

@property (nonatomic, retain) IBOutlet UIImageView *aImageView;


-(IBAction)doCamera:(id)sender;
-(IBAction)doFilter:(id)sender;
-(IBAction)doSave:(id)sender;

@end

