//
//  CCPieChart.h
//  CCPieChart
//
//  Created by hwawo on 16/5/22.
//  Copyright © 2016年 ReLife. All rights reserved.
//

#import <UIKit/UIKit.h>

struct CCShapeLayerAngle {
    double startAngle;
    double endAngle;
};
typedef struct CCShapeLayerAngle CCShapeLayerAngle;
CG_INLINE CCShapeLayerAngle CCShapeLayerAngleMake(double start, double end) {
    CCShapeLayerAngle angle; angle.startAngle=start;angle.endAngle=end;return  angle;
}
@interface CCLayer : CAShapeLayer

- (void)configrationLayerWithRadius:(CGFloat) radius
                              angle:(CCShapeLayerAngle) displayAngle;

@end

@interface CCPieChart : UIView

/*
 *radius        控件半径
 *center        控件的中心位置
 *colors        每个部分的颜色数组
 *ratioes       每个部分占多大比例，存入NSNumber对象，并且小于1，和小于1
 *offSet_       当移动的时候，中心点的移动距离的2倍，至少为10，当设置了后，图形会变小响应大小
 *
 */
- (instancetype)pieChartWithRadius:(CGFloat) radius
                            center:(CGPoint) center
                            colors:(NSArray <UIColor *>*) colors
                           ratioes:(NSArray <NSNumber *>*) ratioes
                            offSet:(CGFloat) offSet_;
/*
 *当某一个被点击时调用
 *NSInteger     第几个被点击了
 *BOOL          点击后应该变成的状态
 *
 */
@property (nonatomic, copy) void (^tappedHandler) (NSInteger, BOOL);

@end
