export TARGET = iphone:latest:9.0
export ARCHS = armv7 arm64 arm64e

INSTALL_TARGET_PROCESSES = Preferences

ifneq ($(RESPRING),0)
	INSTALL_TARGET_PROCESSES += SpringBoard
endif

export ADDITIONAL_CFLAGS = -DTHEOS_LEAN_AND_MEAN -fobjc-arc

include $(THEOS)/makefiles/common.mk

SUBPROJECTS += NougatServices
SUBPROJECTS += NougatUI
SUBPROJECTS += SpringBoard
SUBPROJECTS += Settings

BUNDLE_NAME = Nougat-Resources
Nougat-Resources_INSTALL_PATH = /var/mobile/Library/

include $(THEOS_MAKE_PATH)/tweak.mk
include $(THEOS)/makefiles/bundle.mk
include $(THEOS_MAKE_PATH)/aggregate.mk

after-install::
ifeq ($(RESPRING),0)
	install.exec "uiopen 'prefs:root=Nougat'"
endif
