include $(THEOS)/makefiles/common.mk

FRAMEWORK_NAME = NougatServices

NougatServices_FILES = $(wildcard *.m)
NougatServices_PUBLIC_HEADERS = $(wildcard *.h)
NougatServices_FRAMEWORKS = UIKit QuartzCore CoreTelephony
NougatServices_EXTRA_FRAMEWORKS = Cephei
NougatServices_CFLAGS = -I../Headers
NougatServices_INSTALL_PATH = /Library/Frameworks

include $(THEOS_MAKE_PATH)/framework.mk
