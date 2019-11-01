include $(THEOS)/makefiles/common.mk

BUNDLE_NAME = BatterySaverToggle
BatterySaverToggle_BUNDLE_NAME = com.shade.nougat.BatterySaverToggle
BatterySaverToggle_BUNDLE_EXTENSION = bundle
BatterySaverToggle_FILES = $(wildcard *.m)
BatterySaverToggle_FRAMEWORKS = Foundation UIKit CoreGraphics CoreImage QuartzCore
BatterySaverToggle_EXTRA_FRAMEWORKS = NougatUI
BatterySaverToggle_INSTALL_PATH = /Library/Nougat/Toggles/
BatterySaverToggle_LDFLAGS = -F$(THEOS_OBJ_DIR)

include $(THEOS_MAKE_PATH)/bundle.mk