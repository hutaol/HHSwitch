//
//  HHSwitch.m
//  BKLive
//
//  Created by Henry on 2022/3/9.
//

#import "HHSwitch.h"

NSString * const MoveAnimationKey = @"MoveAnimationKey";
NSString * const BackgroundColorAnimationKey = @"BackgroundColorAnimationKey";

@interface HHSwitch ()

@property (nonatomic, strong) UIView *backgroundView;

@property (nonatomic, strong) CAShapeLayer *circleLayer;

@property (nonatomic, assign) CGFloat paddingWidth;

@property (nonatomic, assign) CGFloat circleRadius;

@property (nonatomic, assign) CGFloat moveDistance;

@property (nonatomic, assign) BOOL isAnimating;

@property (nonatomic, assign) CGFloat layerWidth;

@property (nonatomic, strong) HHSwitchAnimationManager *animationManager;

@property (nonatomic, strong) UITapGestureRecognizer *tapGesture;

@end

@implementation HHSwitch

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self initSetupView];
    }
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self initSetupView];
    }
    return self;
}

// TODO: 太小了不好点击 扩大点击范围 <30
- (UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event {
    if (self.bounds.size.height >= 30) {
        return self;
    }
    CGRect touchRect = CGRectInset(self.bounds, -10, -10);
    if (CGRectContainsPoint(touchRect, point)) {
        for (UIView *subView in [self.subviews reverseObjectEnumerator]) {
            CGPoint convertedPoint = [subView convertPoint:point fromView:self];
            UIView *hitTestView = [subView hitTest:convertedPoint withEvent:event];
            if (hitTestView) {
                return hitTestView;
            }
        }
        return self;
    }
    return nil;
}

- (void)initSetupView {
    self.backgroundColor = [UIColor redColor];

    NSAssert(self.frame.size.width >= self.frame.size.height, @"switch width must be tall！");

    _onColor = [UIColor colorWithRed:73/255.0 green:182/255.0 blue:235/255.0 alpha:1.f];
    _offColor = [UIColor colorWithRed:211/255.0 green:207/255.0 blue:207/255.0 alpha:1.f];
    _circleColor = [UIColor whiteColor];
    _paddingWidth = self.frame.size.height * 0.1;
    _circleRadius = (self.frame.size.height - 2 * _paddingWidth) / 2;
    _animationDuration = 0.5f;

    _animationManager = [[HHSwitchAnimationManager alloc] initWithAnimationDuration:_animationDuration];
    _moveDistance = self.frame.size.width - _paddingWidth * 2 - _circleRadius * 2;
    _on = NO;
    _isAnimating = NO;
    
    self.backgroundView.backgroundColor = _offColor;
    self.circleLayer.fillColor = _circleColor.CGColor;
    self.layerWidth = self.circleLayer.frame.size.width;

    self.enabled = YES;

}

#pragma mark - set property

- (void)setBackgroundColor:(UIColor *)backgroundColor {
    return;
}

- (void)setOffColor:(UIColor *)offColor {
    _offColor = offColor;
    if (!_on) {
        _backgroundView.backgroundColor = offColor;
    }
}

- (void)setOnColor:(UIColor *)onColor {
    _onColor = onColor;
    if (_on) {
        _backgroundView.backgroundColor = onColor;
    }
}

- (void)setCircleColor:(UIColor *)circleColor {
    _circleColor = circleColor;
    _circleLayer.fillColor = circleColor.CGColor;
}

- (void)setAnimationDuration:(CGFloat)animationDuration {
    _animationDuration = animationDuration;
    _animationManager = [[HHSwitchAnimationManager alloc] initWithAnimationDuration:_animationDuration];
}

- (void)setOn:(BOOL)on {
    
    if ((_on && on)||(!_on && !on)) {
        return;
    }
    _on = on;
    if (on) {
        [self.backgroundView.layer removeAllAnimations];
        self.backgroundView.backgroundColor = _onColor;
        [self.circleLayer removeAllAnimations];
        self.circleLayer.position = CGPointMake(self.circleLayer.position.x + _moveDistance, self.circleLayer.position.y);
    } else {
        [self.backgroundView.layer removeAllAnimations];
        self.backgroundView.backgroundColor = _offColor;
        [self.circleLayer removeAllAnimations];
        self.circleLayer.position = CGPointMake(self.circleLayer.position.x - _moveDistance, self.circleLayer.position.y);
    }
}

- (void)setOn:(BOOL)on animated:(BOOL)animated {
    if ((_on && on)||(!_on && !on)) {
        return;
    }
    if (animated) {
        [self handleTapSwitch];
    } else {
        [self setOn:on];
    }
}

- (void)setEnabled:(BOOL)enabled {
    if (_enabled == enabled) {
        return;
    }
    _enabled = enabled;
    if (enabled) {
        [self addGestureRecognizer:self.tapGesture];
    } else {
        [self removeGestureRecognizer:self.tapGesture];
    }
}

#pragma mark GestureRecognizer

- (void)handleTapSwitch {
    if (_isAnimating) {
        return;
    }
    _isAnimating = YES;
    // layer
    CABasicAnimation *moveAnimation = [_animationManager moveAnimationWithFromPosition:_circleLayer.position toPosition:_on ? CGPointMake(_circleLayer.position.x - _moveDistance, _circleLayer.position.y) : CGPointMake(_circleLayer.position.x + _moveDistance, _circleLayer.position.y)];
    moveAnimation.delegate = self;
    [_circleLayer addAnimation:moveAnimation forKey:MoveAnimationKey];
    
    // backfroundView
    CABasicAnimation *colorAnimation = [_animationManager backgroundColorAnimationFromValue:(id)(_on ? _onColor : _offColor).CGColor toValue:(id)(_on ? _offColor : _onColor).CGColor];
    [_backgroundView.layer addAnimation:colorAnimation forKey:BackgroundColorAnimationKey];
    
    // start delegate
    if ([self.delegate respondsToSelector:@selector(didTapSwitch:)]) {
        [self.delegate didTapSwitch:self];
    }
    
}

- (UIView *)backgroundView {
    if (!_backgroundView) {
        _backgroundView = [[UIView alloc] init];
        _backgroundView.frame = self.bounds;
        _backgroundView.layer.cornerRadius = self.frame.size.height / 2;
        _backgroundView.layer.masksToBounds = YES;
        [self addSubview:_backgroundView];
    }
    return _backgroundView;
}

- (CAShapeLayer *)circleLayer {
    if (!_circleLayer) {
        _circleLayer = [CAShapeLayer layer];
        [_circleLayer setFrame:CGRectMake(_paddingWidth, _paddingWidth, _circleRadius * 2, _circleRadius *2)];
        UIBezierPath *circlePath = [UIBezierPath bezierPathWithOvalInRect:_circleLayer.bounds];
        _circleLayer.path = circlePath.CGPath;
        [self.backgroundView.layer addSublayer:_circleLayer];
    }
    return _circleLayer;
}

- (UITapGestureRecognizer *)tapGesture {
    if (!_tapGesture) {
        _tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTapSwitch)];
    }
    return _tapGesture;
}

#pragma mark AnimationDelegate

- (void)animationDidStop:(CAAnimation *)anim finished:(BOOL)flag {
    if (flag) {
        
        if (_on) {
            _circleLayer.position = CGPointMake(_circleLayer.position.x - _moveDistance, _circleLayer.position.y);
            _on = NO;
        } else {
            _circleLayer.position = CGPointMake(_circleLayer.position.x + _moveDistance, _circleLayer.position.y);
            _on = YES;
        }
        _isAnimating = NO;

        // stop delegate
        if ([self.delegate respondsToSelector:@selector(animationDidStopForSwitch:)]) {
            [self.delegate animationDidStopForSwitch:self];
        }
        
        // valueChanged
        if ([self.delegate respondsToSelector:@selector(valueDidChanged:on:)]) {
            [self.delegate valueDidChanged:self on:self.on];
        }
        
        [self.circleLayer removeAllAnimations];
//        [self.backgroundView.layer removeAllAnimations];
    }
}

- (void)dealloc {
    _tapGesture = nil;
    self.delegate = nil;
}

@end

@implementation HHSwitchAnimationManager

- (instancetype)initWithAnimationDuration:(CGFloat)animationDuration {
    self = [super init];
    if (self) {
        _animationDuration = animationDuration;
    }
    return self;
}

- (CABasicAnimation *)moveAnimationWithFromPosition:(CGPoint)fromPosition toPosition:(CGPoint)toPosition {
    CABasicAnimation *moveAnimation = [CABasicAnimation animationWithKeyPath:@"position"];
    moveAnimation.fromValue = [NSValue valueWithCGPoint:fromPosition];
    moveAnimation.toValue = [NSValue valueWithCGPoint:toPosition];
    moveAnimation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
    moveAnimation.duration = _animationDuration * 2 /3;
    moveAnimation.removedOnCompletion = NO;
    moveAnimation.fillMode = kCAFillModeForwards;
    return moveAnimation;
}

- (CABasicAnimation *)backgroundColorAnimationFromValue:(NSValue *)fromValue toValue:(NSValue *)toValue {
    CABasicAnimation *colorAnimation = [CABasicAnimation animationWithKeyPath:@"backgroundColor"];
    colorAnimation.fromValue = fromValue;
    colorAnimation.toValue = toValue;
    colorAnimation.duration = _animationDuration * 2 /3;
    colorAnimation.removedOnCompletion = NO;
    colorAnimation.fillMode = kCAFillModeForwards;
    return colorAnimation;

}

@end
