include $(THEOS)/makefiles/common.mk

BUNDLE_NAME = FlashlightToggle
FlashlightToggle_BUNDLE_NAME = com.shade.nougat.FlashlightToggle
FlashlightToggle_BUNDLE_EXTENSION = bundle
FlashlightToggle_FILES = $(wildcard *.m)
FlashlightToggle_FRAMEWORKS = Foundation UIKit CoreGraphics CoreImage QuartzCore
FlashlightToggle_EXTRA_FRAMEWORKS = NougatUI
FlashlightToggle_INSTALL_PATH = /Library/Nougat/Toggles/
FlashlightToggle_LDFLAGS += -F$(THEOS_OBJ_DIR)

include $(THEOS_MAKE_PATH)/bundle.mk