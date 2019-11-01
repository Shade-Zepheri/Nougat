include $(THEOS)/makefiles/common.mk

BUNDLE_NAME = VPNToggle
VPNToggle_BUNDLE_NAME = com.shade.nougat.VPNToggle
VPNToggle_BUNDLE_EXTENSION = bundle
VPNToggle_FILES = $(wildcard *.m)
VPNToggle_FRAMEWORKS = Foundation UIKit CoreGraphics CoreImage QuartzCore
VPNToggle_EXTRA_FRAMEWORKS = NougatUI
VPNToggle_INSTALL_PATH = /Library/Nougat/Toggles/
VPNToggle_LDFLAGS += -F$(THEOS_OBJ_DIR)

include $(THEOS_MAKE_PATH)/bundle.mk