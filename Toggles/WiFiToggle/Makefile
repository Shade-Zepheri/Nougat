include $(THEOS)/makefiles/common.mk

BUNDLE_NAME = WiFiToggle
WiFiToggle_BUNDLE_NAME = com.shade.nougat.WiFiToggle
WiFiToggle_BUNDLE_EXTENSION = bundle
WiFiToggle_FILES = $(wildcard *.m)
WiFiToggle_FRAMEWORKS = Foundation UIKit CoreGraphics CoreImage QuartzCore
WiFiToggle_EXTRA_FRAMEWORKS = NougatUI
WiFiToggle_INSTALL_PATH = /Library/Nougat/Toggles/
WiFiToggle_LDFLAGS += -F$(THEOS_OBJ_DIR)

include $(THEOS_MAKE_PATH)/bundle.mk