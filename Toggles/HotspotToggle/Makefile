include $(THEOS)/makefiles/common.mk

BUNDLE_NAME = HotspotToggle
HotspotToggle_BUNDLE_NAME = com.shade.nougat.HotspotToggle
HotspotToggle_BUNDLE_EXTENSION = bundle
HotspotToggle_FILES = $(wildcard *.m)
HotspotToggle_FRAMEWORKS = Foundation UIKit CoreGraphics CoreImage QuartzCore
HotspotToggle_EXTRA_FRAMEWORKS = NougatUI
HotspotToggle_INSTALL_PATH = /Library/Nougat/Toggles/
HotspotToggle_LDFLAGS = -F$(THEOS_OBJ_DIR)

include $(THEOS_MAKE_PATH)/bundle.mk