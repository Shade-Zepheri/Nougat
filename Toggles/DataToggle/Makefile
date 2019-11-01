include $(THEOS)/makefiles/common.mk

BUNDLE_NAME = DataToggle
DataToggle_BUNDLE_NAME = com.shade.nougat.DataToggle
DataToggle_BUNDLE_EXTENSION = bundle
DataToggle_FILES = $(wildcard *.m)
DataToggle_FRAMEWORKS = Foundation UIKit CoreGraphics CoreImage QuartzCore
DataToggle_EXTRA_FRAMEWORKS = NougatUI
DataToggle_INSTALL_PATH = /Library/Nougat/Toggles/
DataToggle_LDFLAGS += -F$(THEOS_OBJ_DIR)

include $(THEOS_MAKE_PATH)/bundle.mk