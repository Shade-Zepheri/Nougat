include $(THEOS)/makefiles/common.mk

BUNDLE_NAME = AirplaneModeToggle
AirplaneModeToggle_BUNDLE_NAME = com.shade.nougat.AirplaneModeToggle
AirplaneModeToggle_BUNDLE_EXTENSION = bundle
AirplaneModeToggle_FILES = $(wildcard *.m)
AirplaneModeToggle_FRAMEWORKS = Foundation UIKit CoreGraphics CoreImage QuartzCore
AirplaneModeToggle_EXTRA_FRAMEWORKS = NougatUI
AirplaneModeToggle_INSTALL_PATH = /Library/Nougat/Toggles/
AirplaneModeToggle_LDFLAGS += -F$(THEOS_OBJ_DIR)

include $(THEOS_MAKE_PATH)/bundle.mk