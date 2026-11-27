#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>
#include "Common.h"

static BOOL pnbBack = NO;

%ctor {
    pnbBack = PNBBool(PNB_KEY_BACK, YES);
}

// 只去文字：父 VC 的 backBarButtonItem 标题置空，零偏移。
// 不用 setBackButtonTitlePositionAdjustment（垂直抬走 chevron / 横向挤到边）
// 不用 leftBarButtonItem（保系统 chevron + 点击区 + 侧滑返回）
%hook UIViewController
- (void)viewDidLoad {
    %orig;
    if (!pnbBack) return;
    self.navigationItem.backBarButtonItem =
        [[UIBarButtonItem alloc] initWithTitle:@""
                                         style:UIBarButtonItemStylePlain
                                        target:nil
                                        action:nil];
}
%end

// 纯色圆底：不玻璃 / 不模糊 / 不描边 / 不高光；只认导航栏左侧带 chevron 的小方块
%hook UIView
- (void)layoutSubviews {
    %orig;
    if (!pnbBack) return;
    CGFloat w = CGRectGetWidth(self.bounds), h = CGRectGetHeight(self.bounds);
    if (w < 20 || w > 60 || h < 20 || h > 60) return;
    if (CGRectGetMinX(self.frame) > 80) return;

    UIView *p = self.superview; BOOL inNav = NO;
    while (p) { if ([p isKindOfClass:[UINavigationBar class]]) { inNav = YES; break; } p = p.superview; }
    if (!inNav) return;

    BOOL hasChevron = NO;
    for (UIView *s in self.subviews)
        if ([s isKindOfClass:[UIImageView class]]) { hasChevron = YES; break; }
    if (!hasChevron) return;

    self.backgroundColor = [UIColor colorWithWhite:1.0 alpha:0.18];
    self.layer.cornerRadius  = MIN(w, h) / 2.0;
    self.layer.cornerCurve   = kCACornerCurveContinuous;
    self.layer.masksToBounds = YES;
}
%end
