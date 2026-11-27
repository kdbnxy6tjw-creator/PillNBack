#import <UIKit/UIKit.h>
#include "Common.h"

%ctor {
    if (!PNBBool(PNB_KEY_BACK, YES)) return;

    // 只把 title 横向推出可视区；不用任何垂直负值，chevron / 点击区 / 侧滑全不动
    UIOffset off = UIOffsetMake(-1000, 0);
    UIBarMetrics m[] = {
        UIBarMetricsDefault,
        UIBarMetricsCompact,
        UIBarMetricsDefaultPrompt,
        UIBarMetricsCompactPrompt
    };
    for (NSUInteger i = 0; i < sizeof(m) / sizeof(m[0]); i++) {
        [[UIBarButtonItem appearance] setBackButtonTitlePositionAdjustment:off
                                                             forBarMetrics:m[i]];
    }
}
