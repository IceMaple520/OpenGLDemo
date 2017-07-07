//
//  HFOpenGLView.h
//  LearnOpenGLES
//
//  Created by IceMaple on 2017/6/28.
//  Copyright © 2017年 HF. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <OpenGLES/ES2/gl.h>
#import <OpenGLES/ES2/glext.h>



@interface HFOpenGLView : UIView

@property (nonatomic , assign) BOOL isFullYUVRange;

- (void)setupGL;


- (void)displayWithPixelBuffer:(CVPixelBufferRef)pixelBuffer;


@end
