//
//  HHSwitch.h
//  BKLive
//
//  Created by Henry on 2022/3/9.
//

#import <UIKit/UIKit.h>
@class HHSwitch;

NS_ASSUME_NONNULL_BEGIN

@protocol HHSwitchDelegate <NSObject>

@optional

- (void)didTapSwitch:(HHSwitch *)hhSwitch;

- (void)animationDidStopForSwitch:(HHSwitch *)hhSwitch;

- (void)valueDidChanged:(HHSwitch *)hhSwitch on:(BOOL)on;

@end

@interface HHSwitch : UIView

@property (nonatomic, weak) id <HHSwitchDelegate> delegate;

@property (nonatomic, strong) UIColor *onColor;

@property (nonatomic, strong) UIColor *offColor;

@property (nonatomic, strong) UIColor *circleColor;

@property (nonatomic, assign) CGFloat animationDuration;

@property (nonatomic, assign) BOOL on;

@end

@interface HHSwitchAnimationManager : NSObject

@property (nonatomic, assign) CGFloat animationDuration;

- (instancetype)initWithAnimationDuration:(CGFloat)animationDuration;

- (CABasicAnimation *)moveAnimationWithFromPosition:(CGPoint)fromPosition toPosition:(CGPoint)toPosition;

- (CABasicAnimation *)backgroundColorAnimationFromValue:(NSValue *)fromValue toValue:(NSValue *)toValue;

@end

NS_ASSUME_NONNULL_END
