#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>
#import <objc/runtime.h>
#include <string.h>
#include "Common.h"

static BOOL pnbPill = NO, pnbLock = NO, pnbCover = NO;
static CGFloat const kPNBLockRadius = 38.0;

static inline BOOL PNBHas(const char *n, const char *k) { return n && strstr(n, k) != NULL; }
static inline BOOL PNBIsVolumeHUD(const char *n) {
    return PNBHas(n, "VolumeHUD") || PNBHas(n, "VolumeView") || PNBHas(n, "HUDView");
}
// 原样放回：Panel/Wallpaper 宽匹配，通知中心圆角靠它回来
static inline BOOL PNBIsLockPanel(const char *n) {
    if (!n) return NO;
    if (PNBHas(n,"Flashlight") || PNBHas(n,"Camera") || PNBHas(n,"Button") || PNBHas(n,"Knob")) return NO;
    return PNBHas(n,"LockScreen") || PNBHas(n,"Panel") || PNBHas(n,"Wallpaper");
}

%ctor {
    pnbPill  = PNBBool(PNB_KEY_PILL,  YES);
    pnbLock  = PNBBool(PNB_KEY_LOCK,  YES);
    pnbCover = PNBBool(PNB_KEY_COVER, NO);
}

%hook UIView
- (void)layoutSubviews {
    %orig;
    if (!pnbPill && !pnbLock) return;
    const char *n = class_getName(object_getClass(self));
    CGFloat w = CGRectGetWidth(self.bounds), h = CGRectGetHeight(self.bounds);
    if (w <= 0 || h <= 0) return;

    // ① 几何兜底：横向细长浮条（音量 HUD），避开顶部状态栏；不靠类名
    BOOL geoHUD = NO;
    if (pnbPill && self.window) {
        CGRect r = [self convertRect:self.bounds toView:self.window];
        geoHUD = (CGRectGetMinY(r) > 80.0 && w > 150.0 &&
                  h >= 18.0 && h <= 64.0 && w > h * 2.5);
    }

    CALayer *l = self.layer;
    // 形状三行一字未动
    if (pnbPill && (PNBIsVolumeHUD(n) || geoHUD)) {
        l.cornerRadius  = MIN(w, h) / 2.0;
        l.cornerCurve   = kCACornerCurveContinuous;
        l.masksToBounds = YES;
    } else if (pnbLock && PNBIsLockPanel(n)) {
        l.cornerRadius  = kPNBLockRadius;
        l.cornerCurve   = kCACornerCurveContinuous;
        l.masksToBounds = YES;
    }
}
%end

// ④ 占位，16.3.1 未 dump，本版仍静默不生效
@class CSCoverSheetViewController;
%hook CSCoverSheetViewController
- (void)dismissAnimated:(BOOL)animated withCompletion:(id)completion {
    if (pnbCover) {
        UIView *v = [(UIViewController *)self view];
        if (v) { v.alpha = 0.92; v.transform = CGAffineTransformMakeScale(0.92, 0.92); }
    }
    %orig;
}
%end
