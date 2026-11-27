#import <UIKit/UIKit.h>
#include "Common.h"

static BOOL pnbBack = NO;

// 纯色圆底：公开 API 生成图片，不玻璃/不描边/不高光，不猜导航栏私有 view
static UIImage *PNBBackDot(void) {
    CGFloat s = 34.0;
    UIGraphicsImageRenderer *r = [[UIGraphicsImageRenderer alloc] initWithSize:CGSizeMake(s, s)];
    UIImage *raw = [r imageWithActions:^(UIGraphicsImageRendererContext *ctx) {
        CGContextRef c = ctx.CGContext;
        CGContextSetFillColorWithColor(c, [UIColor colorWithWhite:1.0 alpha:0.18].CGColor);
        CGContextFillEllipseInRect(c, CGRectMake(0, 0, s, s));
    }];
    return [raw resizableImageWithCapInsets:UIEdgeInsetsMake(16, 16, 16, 16)
                              resizingMode:UIImageResizingModeStretch];
}

%ctor {
    pnbBack = PNBBool(PNB_KEY_BACK, YES);
    if (!pnbBack) return;
    UIImage *dot = PNBBackDot();
    UIBarMetrics m[] = { UIBarMetricsDefault, UIBarMetricsCompact,
                         UIBarMetricsDefaultPrompt, UIBarMetricsCompactPrompt };
    for (NSUInteger i = 0; i < sizeof(m)/sizeof(m[0]); i++) {
        [[UIBarButtonItem appearance] setBackButtonBackgroundImage:dot
                                                          forState:UIControlStateNormal
                                                        barMetrics:m[i]];
        [[UIBarButtonItem appearance] setBackButtonBackgroundImage:dot
                                                          forState:UIControlStateHighlighted
                                                        barMetrics:m[i]];
    }
    // 完全不用 UIOffset：垂直抬走 chevron、横向挤到贴边，两次都是它引起的
}

%hook UIViewController
- (void)viewDidLoad {
    %orig;
    if (!pnbBack) return;
    // 零偏移去文字；原生 chevron / 点击区 / 侧滑全留
    self.navigationItem.backBarButtonItem =
        [[UIBarButtonItem alloc] initWithTitle:@""
                                         style:UIBarButtonItemStylePlain
                                        target:nil action:nil];
}
%end
