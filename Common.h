#ifndef PNB_COMMON_H
#define PNB_COMMON_H

#include <CoreFoundation/CoreFoundation.h>

#define PNB_DOMAIN    CFSTR("com.you.pillnback")
#define PNB_KEY_PILL  CFSTR("pillHUD")
#define PNB_KEY_BACK  CFSTR("minimalBack")
#define PNB_KEY_LOCK  CFSTR("lockRound")
#define PNB_KEY_COVER CFSTR("coverScale")

// 只读一次，不 synchronize、不挂通知；进程重启才拿到新值
static inline BOOL PNBBool(CFStringRef key, BOOL fallback) {
    CFTypeRef v = CFPreferencesCopyAppValue(key, PNB_DOMAIN);
    if (!v) return fallback;
    BOOL on = NO;
    if (CFGetTypeID(v) == CFBooleanGetTypeID()) {
        on = CFBooleanGetValue((CFBooleanRef)v);
    } else if (CFGetTypeID(v) == CFNumberGetTypeID()) {
        int n = 0;
        CFNumberGetValue((CFNumberRef)v, kCFNumberIntType, &n);
        on = (n != 0);
    }
    CFRelease(v);
    return on;
}

#endif
