include $(THEOS)/makefiles/common.mk

BUNDLE_NAME = DoNotDisturbToggle
DoNotDisturbToggle_BUNDLE_NAME = com.shade.nougat.DoNotDisturbToggle
DoNotDisturbToggle_BUNDLE_EXTENSION = bundle
DoNotDisturbToggle_FILES = $(wildcard *.m)
DoNotDisturbToggle_FRAMEWORKS = Foundation UIKit CoreGraphics CoreImage QuartzCore
DoNotDisturbToggle_EXTRA_FRAMEWORKS = NougatUI
DoNotDisturbToggle_INSTALL_PATH = /Library/Nougat/Toggles/
DoNotDisturbToggle_LDFLAGS += -F$(THEOS_OBJ_DIR)

include $(THEOS_MAKE_PATH)/bundle.mk