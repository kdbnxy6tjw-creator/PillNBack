#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>
#import <objc/runtime.h>
#include <string.h>
#include "Common.h"

static BOOL pnbPill  = NO;
static BOOL pnbLock  = NO;
static BOOL pnbCover = NO;

// ③ 真机只调这一个常量
static CGFloat const kPNBLockRadius = 38.0;

static inline BOOL PNBHas(const char *n, const char *k) {
    return n && strstr(n, k) != NULL;
}

// 占位匹配：dump 后改成 %hook 精确类名，整段删掉
static inline BOOL PNBIsVolumeHUD(const char *n) {
    return PNBHas(n, "VolumeHUD") || PNBHas(n, "VolumeView") || PNBHas(n, "HUDView");
}

// 占位匹配：排除手电筒/相机圆钮；dump 后改成 %hook 精确类名，整段删掉
static inline BOOL PNBIsLockPanel(const char *n) {
    if (!n) return NO;
    if (PNBHas(n, "Flashlight") || PNBHas(n, "Camera") ||
        PNBHas(n, "Button")     || PNBHas(n, "Knob")) return NO;
    return PNBHas(n, "LockScreen") || PNBHas(n, "Panel") || PNBHas(n, "Wallpaper");
}

%ctor {
    pnbPill  = PNBBool(PNB_KEY_PILL,  YES);
    pnbLock  = PNBBool(PNB_KEY_LOCK,  YES);
    pnbCover = PNBBool(PNB_KEY_COVER, NO);   // ④ 可选，默认关
}

%hook UIView
- (void)layoutSubviews {
    %orig;
    if (!pnbPill && !pnbLock) return;

    const char *n = class_getName(object_getClass(self));
    if (!n) return;
    CGFloat w = CGRectGetWidth(self.bounds);
    CGFloat h = CGRectGetHeight(self.bounds);
    if (w <= 0.0 || h <= 0.0) return;

    CALayer *l = self.layer;
    // 命中"承载底色的那一层"；只改 layer 三个属性，不碰任何 subview / frame / 填充层
    if (pnbPill && PNBIsVolumeHUD(n)) {
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

// ④ 占位类名 + 占位方法名，16.3.1 未 dump。
// 卡的是 dismiss 时机，不能挪进 UIView 兜底（会反复设起始值跟弹簧打架）。
// dump 后只替换类名与方法名，起始态和 %orig 顺序保持不变。
@class CSCoverSheetViewController;

%hook CSCoverSheetViewController
- (void)dismissAnimated:(BOOL)animated withCompletion:(id)completion {
    if (pnbCover) {
        UIView *v = [(UIViewController *)self view];
        if (v) {
            v.alpha     = 0.92;
            v.transform = CGAffineTransformMakeScale(0.92, 0.92);
        }
    }
    %orig;   // 弹回全程交系统，不写 animate、不挂 display link
}
%end
