export TARGET = iphone:9.2

CFLAGS = -fobjc-arc

INSTALL_TARGET_PROCESSES = Preferences

ifeq ($(RESPRING),1)
INSTALL_TARGET_PROCESSES += SpringBoard
endif

include $(THEOS)/makefiles/common.mk

TWEAK_NAME = Nougat
Nougat_FILES = $(wildcard *.x) $(wildcard *.m)
Nougat_FRAMEWORKS = UIKit QuartzCore
Nougat_PRIVATE_FRAMEWORKS = BackBoardServices
Nougat_LIBRARIES = flipswitch

BUNDLE_NAME = Nougat-Resources
Nougat-Resources_INSTALL_PATH = /var/mobile/Library/

SUBPROJECTS = nougat

include $(THEOS_MAKE_PATH)/tweak.mk
include $(THEOS)/makefiles/bundle.mk
include $(THEOS_MAKE_PATH)/aggregate.mk
