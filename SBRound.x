#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>
#import <objc/runtime.h>
#include <string.h>
#include "Common.h"

static BOOL pnbPill = NO, pnbLock = NO, pnbCover = NO;
static CGFloat const kPNBLockRadius = 38.0;
static NSMutableSet *pnbSeen = nil;

static inline BOOL PNBHas(const char *n, const char *k) { return n && strstr(n, k); }

static inline BOOL PNBProbe(const char *n) {
    if (!n) return NO;
    return PNBHas(n,"HUD") || PNBHas(n,"Volume") || PNBHas(n,"CoverSheet") ||
           PNBHas(n,"LockScreen") || PNBHas(n,"Panel") || PNBHas(n,"Shade") ||
           PNBHas(n,"Notification") || PNBHas(n,"DashBoard") || PNBHas(n,"Wallpaper");
}

// 调试期：同类名只记一次，写到 Filza 能搜到的文件；拿到类名后我给的版本会整段删除
static void PNBLog(NSString *tag, NSString *name) {
    if (!pnbSeen) pnbSeen = [NSMutableSet new];
    NSString *k = [tag stringByAppendingString:name];
    if ([pnbSeen containsObject:k]) return;
    [pnbSeen addObject:k];
    NSString *p = [NSHomeDirectory() stringByAppendingPathComponent:@"Library/Preferences/PNBProbe.log"];
    NSString *old = [NSString stringWithContentsOfFile:p encoding:NSUTF8StringEncoding error:nil] ?: @"";
    [[old stringByAppendingFormat:@"%@ %@\n", tag, name]
        writeToFile:p atomically:YES encoding:NSUTF8StringEncoding error:nil];
}

%ctor {
    pnbPill  = PNBBool(PNB_KEY_PILL,  YES);
    pnbLock  = PNBBool(PNB_KEY_LOCK,  YES);
    pnbCover = PNBBool(PNB_KEY_COVER, NO);
}

%hook UIView
- (void)layoutSubviews {
    %orig;
    const char *n = class_getName(object_getClass(self));
    if (PNBProbe(n)) PNBLog(@"[VIEW] ", [NSString stringWithUTF8String:n]);

    if (!pnbPill && !pnbLock) return;
    CGFloat w = CGRectGetWidth(self.bounds), h = CGRectGetHeight(self.bounds);
    if (w <= 0 || h <= 0) return;
    CALayer *l = self.layer;
    // 形状三行不动，类名一中就生效
    if (pnbPill && (PNBHas(n,"VolumeHUD") || PNBHas(n,"VolumeView") || PNBHas(n,"HUDView"))) {
        l.cornerRadius = MIN(w, h) / 2.0;
        l.cornerCurve = kCACornerCurveContinuous;
        l.masksToBounds = YES;
    } else if (pnbLock && PNBHas(n,"LockScreen")) {   // 收窄，去掉 Panel/Wallpaper 误伤
        l.cornerRadius = kPNBLockRadius;
        l.cornerCurve = kCACornerCurveContinuous;
        l.masksToBounds = YES;
    }
}
%end

// ④ 抓 dismiss 目标：收起通知中心时看哪个 VC 消失
%hook UIViewController
- (void)viewWillDisappear:(BOOL)animated {
    PNBLog(@"[VC] ", NSStringFromClass([self class]));
    %orig;
}
%end

// ④ 原占位 hook 保留（类名/方法未中时静默，不报错）
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
