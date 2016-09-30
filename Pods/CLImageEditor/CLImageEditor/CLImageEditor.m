//
//  CLImageEditor.m
//
//  Created by sho yakushiji on 2013/10/17.
//  Copyright (c) 2013年 CALACULU. All rights reserved.
//

#import "CLImageEditor.h"

#import "_CLImageEditorViewController.h"

@interface CLImageEditor ()

@end


@implementation CLImageEditor

- (id)init
{
    return [_CLImageEditorViewController new];
}

- (id)initWithImage:(UIImage*)image
{
    return [self initWithImage:image delegate:nil forceToCrop:NO];
}

- (id)initWithImage:(UIImage*)image delegate:(id<CLImageEditorDelegate>)delegate forceToCrop:(BOOL)forceToCrop
{
    return [[_CLImageEditorViewController alloc] initWithImage:image delegate:delegate forceToCrop:forceToCrop];
}

- (id)initWithDelegate:(id<CLImageEditorDelegate>)delegate
{
    return [[_CLImageEditorViewController alloc] initWithDelegate:delegate];
}

- (void)showInViewController:(UIViewController*)controller withImageView:(UIImageView*)imageView;
{

}

- (void)setCurrentTool:(CLImageToolBase *)currentTool
{

}


- (CLImageEditorTheme*)theme
{
    return [CLImageEditorTheme theme];
}

@end
