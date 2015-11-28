//
//  ViewController.m
//  ToyCamera14
//
//  Created by 関口流星 on 2015/11/26.
//  Copyright © 2015年 関口流星. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
}

-(IBAction)doFilter:(id)sender {
    NSLog(@"フィルタ");
    UIActionSheet *aSheet = [[UIActionSheet alloc]
                             initWithTitle:@"フィルター選択" delegate:self
                             cancelButtonTitle:@"キャンセル" destructiveButtonTitle:nil
                             otherButtonTitles:@"セピア",@"ボタン２",@"ボタン３", nil];
    [aSheet setActionSheetStyle:UIActionSheetStyleDefault];
    [aSheet showInView:[self view]];
}

//「カメラ」ボタンをクリックされた時呼ばれるメソッド
-(IBAction)doCamera:(id)sender {
    NSLog(@"カメラ");
    UIImagePickerControllerSourceType sourceType = UIImagePickerControllerSourceTypeCamera;
    if (![UIImagePickerController
          isSourceTypeAvailable:sourceType]) {
        return;
    }
    //カメラを起動する
    UIImagePickerController *ipc = [[UIImagePickerController alloc] init];
    [ipc setSourceType:sourceType];
    [ipc setDelegate:self];
    [ipc setAllowsEditing:YES];
    [self presentViewController:ipc animated:YES completion:nil];
}



-(IBAction)doSave:(id)sender {
    NSLog(@"保存");
    UIImage *aImage = [_aImageView image];
    if( aImage == nil){
        return;
    }
   UIImageWriteToSavedPhotosAlbum(aImage, self, @selector(image:didFinishSavingWithError:contextInfo:), nil);
}


-(void)navigationController:(UINavigationController *)navigationController willShowViewController:(UIViewController *)viewController animated:(BOOL)animated {
    NSLog(@"撮影画面表示直前");
}

-(void)navigationController:(UINavigationController *)navigationController didShowViewController:(UIViewController *)viewController animated:(BOOL)animated {
    NSLog(@"撮影画面表示直後");
}

-(void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    NSLog(@"撮影");
    UIImage *aImage = [info objectForKey:UIImagePickerControllerEditedImage];
    [_aImageView setImage:aImage];
    [picker dismissViewControllerAnimated:YES completion:nil];
}


-(void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    NSLog(@"キャンセル");
    [picker dismissViewControllerAnimated:YES completion:nil];

}

-(void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    if ( buttonIndex == 0){
        NSLog(@"セピア");
        [self toSepia];
    }else if ( buttonIndex == 1){
        NSLog(@"ボタン２");
    }else if ( buttonIndex == 2){
        NSLog(@"ボタン３");
    }else {
        NSLog(@"キャンセル含めてそれ以外");
    }
}





CGContextRef CreateARGBBitmapContextBySize(size_t pixelsWide,size_t pixelsHigh){
    CGContextRef context = NULL;
    CGColorSpaceRef colorSpace;
    void *bitmapData;
    int bitmapByteCount;
    int bitmapBytePerRow;
    bitmapBytePerRow = (pixelsWide * 4);
    bitmapByteCount = (bitmapBytePerRow * pixelsHigh);
    colorSpace = CGColorSpaceCreateDeviceRGB();
    if (colorSpace == NULL) {
        NSLog(@"Error allocating color space");
        CGColorSpaceRelease( colorSpace );
        return NULL;
    }
    context = CGBitmapContextCreate(
                                    bitmapData,
                                    pixelsWide,
                                    pixelsHigh,
                                    8,
                                    bitmapBytePerRow,
                                    colorSpace,
                                    kCGImageAlphaNoneSkipFirst
                                    );
    if (context == NULL) {
        free (bitmapData);
        NSLog(@"Context not created!");
    }
    CGColorSpaceRelease( colorSpace );
    return context;
}


unsigned char roundCGFloatToUChar( CGFloat p ){
    if ( p < 0) return 0;
    if ( p > 255) return 255;
    return p;
}

-(void)filterSepia:(CGContextRef)cgctx {
    CGFloat width = CGBitmapContextGetWidth(cgctx);
    CGFloat height = CGBitmapContextGetHeight(cgctx);
    unsigned char* data = CGBitmapContextGetData(cgctx);
    CGFloat Gray;
    unsigned char A,R,G,B;
    CGFloat Alpha,Red,Green,Blue;
    long startByte;
    
    int x,y;
    for (y=0; y<height; y++) {
        for (x = 0; x<width; x++) {
            startByte = (y*width+x)*4;
            A = data[startByte+0];
            R = data[startByte+1];
            G = data[startByte+2];
            B = data[startByte+3];
            
            Gray = 0.298912 * R + 0.586611 * G + 0.114478 * B;
            
            Alpha = A;
            Red   = Gray + 20.01;
            Green = Gray -  2.46;
            Blue  = Gray - 41.28;
            
            A = roundCGFloatToUChar(Alpha);
            R = roundCGFloatToUChar(Red);
            G = roundCGFloatToUChar(Green);
            B = roundCGFloatToUChar(Blue);
            
            data[startByte+0] = A;
            data[startByte+1] = R;
            data[startByte+2] = G;
            data[startByte+3] = B;
        }
    }
}

-(void)toSepia {
    UIImage *orgImage = [_aImageView image];
    if ( orgImage == nil) {
        return;
    }
    
    CGFloat width = [orgImage size].width;
    CGFloat height = [orgImage size].height;
    CGContextRef cgctxPhoto = CreateARGBBitmapContextBySize(width, height);
    CGContextDrawImage(cgctxPhoto, CGRectMake(0.0f, 0.0f, width,height), [orgImage CGImage]);
    
    [self filterSepia:cgctxPhoto];
    
    CGImageRef cgimagerefPhoto = CGBitmapContextCreateImage( cgctxPhoto );
    UIImage *imagePhoto = [[UIImage alloc] initWithCGImage:cgimagerefPhoto];
    [_aImageView setImage:imagePhoto];
    
    CGImageRelease( cgimagerefPhoto );
    free(CGBitmapContextGetData( cgctxPhoto ));
    CGContextRelease( cgctxPhoto );
}

- (void)image:(UIImage *)image didFinishSavingWithError:(NSError *)error contextInfo:(void *)contextInfo {
    
    NSLog(@"保存終了");
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"保存終了" message:@"写真アルバムに画像を保存しました。" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil];
    [alert show];
}
//
//-(void)as{
//    
//}



- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}



@end










