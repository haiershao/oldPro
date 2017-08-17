

#import "SJAvatarBrowser.h"
#import "UIImageView+WebCache.h"
#import "UIImageView+RecodPictureCache.h"

#define kCidStr  @"cidstring"

static CGRect oldframe;
@implementation SJAvatarBrowser
+(void)showImage:(NSString *)path fileType:(NSUInteger)fileType{
    
    __typeof(self) __weak safeSelf = self;
    UIImageView *avatarImageView = [[UIImageView alloc] init];
    
    
    NSRange foundObj = [path rangeOfString:@"HuaWo"];
    
    if (foundObj.location != NSNotFound) {
        [avatarImageView sd_setImageWithURL:[NSURL fileURLWithPath:path]];
        
        [avatarImageView sd_setImageWithURL:[NSURL fileURLWithPath:path] completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
            
            //[safeSelf AvatarSetImage:image];
            
            UIWindow *window=[UIApplication sharedApplication].keyWindow;
            UIView *backgroundView=[[UIView alloc]initWithFrame:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height)];
            
            //oldframe=[avatarImageView convertRect:avatarImageView.bounds toView:window];
            oldframe = CGRectMake(backgroundView.frame.size.width/2.f, backgroundView.frame.size.height/2.f, 0, 0);
            
            backgroundView.backgroundColor=[UIColor blackColor];
            backgroundView.alpha=0;
            UIImageView *imageView=[[UIImageView alloc]initWithFrame:oldframe];
            imageView.image=image;
            imageView.tag=1;
            [backgroundView addSubview:imageView];
            [window addSubview:backgroundView];
            
            UITapGestureRecognizer *tap=[[UITapGestureRecognizer alloc]initWithTarget:safeSelf action:@selector(hideImage:)];
            [backgroundView addGestureRecognizer: tap];
            
            [UIView animateWithDuration:0.3 animations:^{
                imageView.frame=CGRectMake(0,([UIScreen mainScreen].bounds.size.height-image.size.height*[UIScreen mainScreen].bounds.size.width/image.size.width)/2, [UIScreen mainScreen].bounds.size.width, image.size.height*[UIScreen mainScreen].bounds.size.width/image.size.width);
                backgroundView.alpha=1;
            } completion:^(BOOL finished) {
                
            }];

        }];
        
    }else{
        
        NSString *cid = [[NSUserDefaults standardUserDefaults] objectForKey:kCidStr];
        
        
        
        [avatarImageView sd_RecodPictureCache_setImageWithCid:cid fileName:path recordType:fileType placeholderImage:[UIImage imageNamed:@""] completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
          
            //[safeSelf AvatarSetImage:image];
            
            UIWindow *window=[UIApplication sharedApplication].keyWindow;
            UIView *backgroundView=[[UIView alloc]initWithFrame:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height)];
            
            //oldframe=[avatarImageView convertRect:avatarImageView.bounds toView:window];
            oldframe = CGRectMake(backgroundView.frame.size.width/2.f, backgroundView.frame.size.height/2.f, 0, 0);
            
            backgroundView.backgroundColor=[UIColor blackColor];
            backgroundView.alpha=0;
            UIImageView *imageView=[[UIImageView alloc]initWithFrame:oldframe];
            imageView.image=image;
            imageView.tag=1;
            [backgroundView addSubview:imageView];
            [window addSubview:backgroundView];
            
            UITapGestureRecognizer *tap=[[UITapGestureRecognizer alloc]initWithTarget:safeSelf action:@selector(hideImage:)];
            [backgroundView addGestureRecognizer: tap];
            
            [UIView animateWithDuration:0.3 animations:^{
                imageView.frame=CGRectMake(0,([UIScreen mainScreen].bounds.size.height-image.size.height*[UIScreen mainScreen].bounds.size.width/image.size.width)/2, [UIScreen mainScreen].bounds.size.width, image.size.height*[UIScreen mainScreen].bounds.size.width/image.size.width);
                backgroundView.alpha=1;
            } completion:^(BOOL finished) {
                
            }];

        }];
        
    }
    
    
    
}

//- (void)AvatarSetImage:(UIImage *)image{
//    
//    //UIImage *image=avatarImageView.image;
//    UIWindow *window=[UIApplication sharedApplication].keyWindow;
//    UIView *backgroundView=[[UIView alloc]initWithFrame:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height)];
//    
//    //oldframe=[avatarImageView convertRect:avatarImageView.bounds toView:window];
//    oldframe = CGRectMake(backgroundView.frame.size.width/2.f, backgroundView.frame.size.height/2.f, 0, 0);
//    
//    backgroundView.backgroundColor=[UIColor blackColor];
//    backgroundView.alpha=0;
//    UIImageView *imageView=[[UIImageView alloc]initWithFrame:oldframe];
//    imageView.image=image;
//    imageView.tag=1;
//    [backgroundView addSubview:imageView];
//    [window addSubview:backgroundView];
//    
//    UITapGestureRecognizer *tap=[[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(hideImage:)];
//    [backgroundView addGestureRecognizer: tap];
//    
//    [UIView animateWithDuration:0.3 animations:^{
//        imageView.frame=CGRectMake(0,([UIScreen mainScreen].bounds.size.height-image.size.height*[UIScreen mainScreen].bounds.size.width/image.size.width)/2, [UIScreen mainScreen].bounds.size.width, image.size.height*[UIScreen mainScreen].bounds.size.width/image.size.width);
//        backgroundView.alpha=1;
//    } completion:^(BOOL finished) {
//        
//    }];
//    
//}

+(void)hideImage:(UITapGestureRecognizer*)tap{
    UIView *backgroundView=tap.view;
    UIImageView *imageView=(UIImageView*)[tap.view viewWithTag:1];
    [UIView animateWithDuration:0.3 animations:^{
        imageView.frame=oldframe;
        backgroundView.alpha=0;
    } completion:^(BOOL finished) {
        [backgroundView removeFromSuperview];
    }];
}
@end
