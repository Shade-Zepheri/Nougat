include $(THEOS)/makefiles/common.mk

BUNDLE_NAME = nougat
nougat_FILES = NUARootListController.m
nougat_INSTALL_PATH = /Library/PreferenceBundles
nougat_FRAMEWORKS = UIKit
nougat_PRIVATE_FRAMEWORKS = Preferences

include $(THEOS_MAKE_PATH)/bundle.mk

internal-stage::
	$(ECHO_NOTHING)mkdir -p $(THEOS_STAGING_DIR)/Library/PreferenceLoader/Preferences$(ECHO_END)
	$(ECHO_NOTHING)cp entry.plist $(THEOS_STAGING_DIR)/Library/PreferenceLoader/Preferences/nougat.plist$(ECHO_END)
