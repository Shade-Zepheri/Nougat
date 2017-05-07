export TARGET = iphone:9.3

CFLAGS = -fobjc-arc

INSTALL_TARGET_PROCESSES = SpringBoard

include $(THEOS)/makefiles/common.mk

TWEAK_NAME = Nougat
Nougat_FILES = $(wildcard *.x) $(wildcard *.m)
Nougat_FRAMEWORKS = UIKit QuartzCore
Nougat_LIBRARIES = flipswitch

SUBPROJECTS = nougat

include $(THEOS_MAKE_PATH)/tweak.mk
include $(THEOS_MAKE_PATH)/aggregate.mk
