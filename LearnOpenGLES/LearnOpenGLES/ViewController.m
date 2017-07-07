//
//  ViewController.m
//  LearnOpenGLES
//
//  Created by IceMaple on 2017/6/28.
//  Copyright © 2017年 HF. All rights reserved.
//

#import "ViewController.h"
#import <AssetsLibrary/AssetsLibrary.h>
#import <AVFoundation/AVFoundation.h>


#import "HFOpenGLView.h"

@interface ViewController ()
@property (nonatomic,strong) UILabel *mLabel;
@property (nonatomic,strong) NSDate *mStartDate;

@property (nonatomic,strong) AVAsset *mAsset;
@property (nonatomic,strong) AVAssetReader *mReader;
@property (nonatomic,strong) AVAssetReaderTrackOutput *mReaderVideoTrackOutput;

@property (nonatomic,strong) HFOpenGLView *mGLView;
@property (nonatomic,strong) CADisplayLink *mDisplayLink;


@end

@implementation ViewController
- (void)viewDidLoad {
    [super viewDidLoad];

    self.view.backgroundColor = [UIColor grayColor];
    self.mGLView = (HFOpenGLView *)self.view;
    
    [self.mGLView setupGL];
    
    
    [self setUI];

}
- (void)setUI {
    
    
    
    
    self.mLabel = [[UILabel alloc] initWithFrame:CGRectMake(100, 100, 100, 100)];
    self.mLabel.textColor = [UIColor redColor];
    [self.view addSubview:self.mLabel];
    
    self.mDisplayLink = [CADisplayLink displayLinkWithTarget:self selector:@selector(displayLinkCallback:)];
    self.mDisplayLink.frameInterval = 2;
    [self.mDisplayLink addToRunLoop:[NSRunLoop currentRunLoop] forMode:NSRunLoopCommonModes];
    [self.mDisplayLink setPaused:YES];
    
    [self loadAsset];
    
    
}
- (void)loadAsset {
    
    NSDictionary *inputOptions = [NSDictionary dictionaryWithObject:[NSNumber numberWithBool:YES] forKey:AVURLAssetPreferPreciseDurationAndTimingKey];
    AVURLAsset *inputAsset = [[AVURLAsset alloc] initWithURL:[[NSBundle mainBundle] URLForResource:@"City" withExtension:@"mp4"] options:inputOptions];
    __weak typeof(self) weakSelf = self;
    [inputAsset loadValuesAsynchronouslyForKeys:[NSArray arrayWithObject:@"trucks"] completionHandler:^{
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            NSError *error = nil;
            AVKeyValueStatus tracksStatus = [inputAsset statusOfValueForKey:@"trucks" error:&error];
            if (tracksStatus != AVKeyValueStatusLoaded) {
                NSLog(@"error %@",error);
                return;
            }
            weakSelf.mAsset = inputAsset;
            [weakSelf processAsset];
            
        });
    }];
    
    
}
- (void)processAsset {
    self.mReader = [self createReader];
    
    if ([self.mReader startReading] == NO) {
        NSLog(@"Error reading from file at URL : %@",self.mAsset);
        return;
    } else {
        self.mStartDate = [NSDate dateWithTimeIntervalSinceNow:0];
        [self.mDisplayLink setPaused:NO];
        NSLog(@"Start reading success.");
    }
    
}
- (AVAssetReader *)createReader {
    NSError *error = nil;
    AVAssetReader *assetReader = [AVAssetReader assetReaderWithAsset:self.mAsset error:&error];
    NSMutableDictionary *outputSettings = [NSMutableDictionary dictionary];
    [outputSettings setObject:@(kCVPixelFormatType_420YpCbCr8BiPlanarFullRange) forKey:(id)kCVPixelBufferPixelFormatTypeKey];
    self.mReaderVideoTrackOutput = [AVAssetReaderTrackOutput assetReaderTrackOutputWithTrack:[[self.mAsset tracksWithMediaType:AVMediaTypeVideo] objectAtIndex:0] outputSettings:outputSettings];
    self.mReaderVideoTrackOutput.alwaysCopiesSampleData = NO;
    [assetReader addOutput:self.mReaderVideoTrackOutput];
    
    
    return assetReader;
}

- (void)displayLinkCallback:(CADisplayLink *)sender {
    
    CMSampleBufferRef sampleBuffer = [self.mReaderVideoTrackOutput copyNextSampleBuffer];
    CVPixelBufferRef pixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer);
    if (pixelBuffer) {
        
        self.mLabel.text = [NSString stringWithFormat:@"%.f",[[NSDate dateWithTimeIntervalSinceNow:0] timeIntervalSinceDate:self.mStartDate]];
        [self.mLabel sizeToFit];
        [self.mGLView displayWithPixelBuffer:pixelBuffer];
        if (pixelBuffer != NULL) {
            CFRelease(pixelBuffer);
            
        }
        
    }else {
        NSLog(@"播放完成");
        [self.mDisplayLink setPaused:YES];
        UIAlertView *al = [[UIAlertView alloc] initWithTitle:@"提示" message:@"播放完成" delegate:nil cancelButtonTitle:@"取消" otherButtonTitles:@"确定", nil];
        [al show];
    }
    
    
}
#pragma mark - Simple Editor

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    
    return (interfaceOrientation == UIDeviceOrientationLandscapeRight);
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
