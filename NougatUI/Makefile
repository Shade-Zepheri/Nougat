include $(THEOS)/makefiles/common.mk

FRAMEWORK_NAME = NougatUI

NougatUI_FILES = $(wildcard *.[xm])
NougatUI_PUBLIC_HEADERS = $(wildcard *.h)
NougatUI_FRAMEWORKS = UIKit QuartzCore
NougatUI_EXTRA_FRAMEWORKS = NougatServices
NougatUI_LIBRARIES = flipswitch
NougatUI_CFLAGS = -I../Headers
NougatUI_LDFLAGS = $(wildcard *.tbd)
NougatUI_INSTALL_PATH = /Library/Frameworks

include $(THEOS_MAKE_PATH)/framework.mk