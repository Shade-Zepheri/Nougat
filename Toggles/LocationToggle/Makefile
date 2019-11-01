include $(THEOS)/makefiles/common.mk

BUNDLE_NAME = LocationToggle
LocationToggle_BUNDLE_NAME = com.shade.nougat.LocationToggle
LocationToggle_BUNDLE_EXTENSION = bundle
LocationToggle_FILES = $(wildcard *.m)
LocationToggle_FRAMEWORKS = Foundation UIKit CoreGraphics CoreImage QuartzCore
LocationToggle_EXTRA_FRAMEWORKS = NougatUI
LocationToggle_INSTALL_PATH = /Library/Nougat/Toggles/
LocationToggle_LDFLAGS = -F$(THEOS_OBJ_DIR)

include $(THEOS_MAKE_PATH)/bundle.mk