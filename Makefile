export TARGET = iphone:11.2:9.0

INSTALL_TARGET_PROCESSES = Preferences

include $(THEOS)/makefiles/common.mk

TWEAK_NAME = Nougat
Nougat_FILES = $(wildcard *.x) $(wildcard *.m)
Nougat_FRAMEWORKS = UIKit QuartzCore
Nougat_PRIVATE_FRAMEWORKS = BackBoardServices FrontBoard
Nougat_EXTRA_FRAMEWORKS = Cephei
Nougat_LIBRARIES = flipswitch
Nougat_CFLAGS = -fobjc-arc -IHeaders

BUNDLE_NAME = Nougat-Resources
Nougat-Resources_INSTALL_PATH = /var/mobile/Library/

SUBPROJECTS = Settings

include $(THEOS_MAKE_PATH)/tweak.mk
include $(THEOS)/makefiles/bundle.mk
include $(THEOS_MAKE_PATH)/aggregate.mk

after-install::
ifneq ($(RESPRING),0)
	install.exec "spring 'prefs:root=Nougat'"
else
	install.exec "uiopen 'prefs:root=Nougat'"
endif