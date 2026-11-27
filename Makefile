ARCHS = arm64e
TARGET = iphone:latest:16.0
THEOS_PACKAGE_SCHEME = roothide
FINALPACKAGE = 1
ADDITIONAL_CFLAGS = -I$(CURDIR)

include $(THEOS)/makefiles/common.mk

TWEAK_NAME = SBRound BackMinimal
SBRound_FILES = SBRound.x
BackMinimal_FILES = BackMinimal.x
SBRound_FRAMEWORKS = UIKit Foundation QuartzCore
BackMinimal_FRAMEWORKS = UIKit Foundation

include $(THEOS_MAKE_PATH)/tweak.mk
