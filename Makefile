ifeq ($(SIMULATOR),1)
	export TARGET = simulator:clang:latest:10.0
	export ARCHS = x86_64
else
	export TARGET = iphone:latest:10.0
	export ARCHS = armv7 arm64 arm64e
endif

INSTALL_TARGET_PROCESSES = Preferences

ifneq ($(RESPRING),0)
	INSTALL_TARGET_PROCESSES += SpringBoard
endif

export ADDITIONAL_CFLAGS = -DTHEOS_LEAN_AND_MEAN -fobjc-arc

include $(THEOS)/makefiles/common.mk

SUBPROJECTS += NougatServices
SUBPROJECTS += NougatUI
SUBPROJECTS += SpringBoard
SUBPROJECTS += Toggles
SUBPROJECTS += Settings

include $(THEOS_MAKE_PATH)/aggregate.mk

after-install::
ifeq ($(RESPRING),0)
	install.exec "uiopen 'prefs:root=Nougat'"
endif
