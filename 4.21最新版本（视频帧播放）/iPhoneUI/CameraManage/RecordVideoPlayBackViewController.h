//
//  IPCamVideoPlayerViewController.h
//  AtHomeCam
//
//  Created by Circlely Networks on 24/12/13.
//
//

#import <UIKit/UIKit.h>

@class StreamAVRender;

@interface RecordVideoPlayBackViewController : UIViewController
{
   
    
    @public
    StreamAVRender* streamRender;
}

-(id)initWithStreamURL:(NSString*)streamURL
              FileName:(NSString *)fileName
                AVSCID:(NSString *)CIDNubmer
            recordType:(NSUInteger)type;

-(id)initWithStreamURL:(NSString*)streamURL
              FileName:(NSString *)fileName
                AVSCID:(NSString *)CIDNubmer
          andTimeRange:(NSString *)timeRange
            recordType:(NSUInteger)recordType;

@property (retain, nonatomic) IBOutlet UIView *playerView;
@property (retain, nonatomic) IBOutlet UIButton *playerBtn;

@property (retain, nonatomic) IBOutlet UIImageView *playimageView;


@property (retain, nonatomic) IBOutlet UILabel *leftTimeLabel;
@property (retain, nonatomic) IBOutlet UILabel *rightTimeLabel;
@property (retain, nonatomic) IBOutlet UIView *videoplayerVIew;

@property (retain, nonatomic) IBOutlet UIButton *fullScreenBtn;



@property (retain, nonatomic) IBOutlet UISlider *timeSlider;

@property (retain, nonatomic) IBOutlet NSLayoutConstraint *playerViewUpSpace;
@property (retain, nonatomic) IBOutlet NSLayoutConstraint *playerViewRightSpace;
@property (retain, nonatomic) IBOutlet NSLayoutConstraint *playerViewLeftSpace;



@property (retain, nonatomic) IBOutlet UIButton *fullScreenPlayBtn;
@property (nonatomic, copy) NSString* timeRange ;
@property (strong, nonatomic) NSString *fileName;
@property (assign, nonatomic) NSUInteger recordType;
@property (strong, nonatomic) NSString *streamURL;

- (IBAction)sliderValueChanged:(id)sender;

- (IBAction)pauseBtnClicked:(id)sender;

- (IBAction)fullScreenBtnClicked:(id)sender;

@property (retain, nonatomic) IBOutlet NSLayoutConstraint *upSpace;
@property (retain, nonatomic) IBOutlet NSLayoutConstraint *rightSpace;

@property (retain, nonatomic) IBOutlet NSLayoutConstraint *leftSpace;

@property (retain, nonatomic) IBOutlet NSLayoutConstraint *videoPlayerViewHeightSpace;


@end

