include $(THEOS)/makefiles/common.mk

BUNDLE_NAME = Nougat
Nougat_FILES = $(wildcard *.m)
Nougat_INSTALL_PATH = /Library/PreferenceBundles
Nougat_FRAMEWORKS = UIKit
#Nougat_PRIVATE_FRAMEWORKS = Preferences
Nougat_EXTRA_FRAMEWORKS = Cephei CepheiPrefs
Nougat_CFLAGS = -I../Headers -I../
Nougat_LDFLAGS = Preferences.tbd

include $(THEOS_MAKE_PATH)/bundle.mk

internal-stage::
	$(ECHO_NOTHING)mkdir -p $(THEOS_STAGING_DIR)/Library/PreferenceLoader/Preferences$(ECHO_END)
	$(ECHO_NOTHING)cp entry.plist $(THEOS_STAGING_DIR)/Library/PreferenceLoader/Preferences/Nougat.plist$(ECHO_END)
