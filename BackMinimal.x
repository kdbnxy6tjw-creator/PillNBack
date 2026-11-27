#import <UIKit/UIKit.h>
#include "Common.h"

%ctor {
    if (!PNBBool(PNB_KEY_BACK, YES)) return;

    UIOffset off = UIOffsetMake(0, -100);
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
    // 不换 leftBarButtonItem：原生 chevron、点击区、侧滑返回全保留
}
