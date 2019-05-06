export TARGET = iphone:latest:9.0
export ARCHS = armv7 arm64 arm64e

INSTALL_TARGET_PROCESSES = Preferences

ifneq ($(RESPRING),0)
	INSTALL_TARGET_PROCESSES += SpringBoard
endif

export ADDITIONAL_CFLAGS = -DTHEOS_LEAN_AND_MEAN -fobjc-arc

include $(THEOS)/makefiles/common.mk

TWEAK_NAME = Nougat
Nougat_FILES = $(wildcard *.[xm])
Nougat_FRAMEWORKS = UIKit QuartzCore
#Nougat_PRIVATE_FRAMEWORKS = BackBoardServices BaseBoard FrontBoard
Nougat_EXTRA_FRAMEWORKS = Cephei
Nougat_LIBRARIES = flipswitch
Nougat_CFLAGS = -IHeaders
Nougat_LDFLAGS = $(wildcard includes/*.tbd)

BUNDLE_NAME = Nougat-Resources
Nougat-Resources_INSTALL_PATH = /var/mobile/Library/

SUBPROJECTS = Settings

include $(THEOS_MAKE_PATH)/tweak.mk
include $(THEOS)/makefiles/bundle.mk
include $(THEOS_MAKE_PATH)/aggregate.mk

after-install::
ifeq ($(RESPRING),0)
	install.exec "uiopen 'prefs:root=Nougat'"
endif