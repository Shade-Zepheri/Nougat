include $(THEOS)/makefiles/common.mk

FRAMEWORK_NAME = NougatServices
NougatServices_FILES = $(wildcard *.m)
NougatServices_PUBLIC_HEADERS = $(wildcard *.h)
NougatServices_FRAMEWORKS = UIKit QuartzCore CoreTelephony
NougatServices_EXTRA_FRAMEWORKS = Cephei
NougatServices_LIBRARIES = MobileGestalt
NougatServices_CFLAGS = -I../Headers
NougatServices_INSTALL_PATH = /usr/lib

include $(THEOS_MAKE_PATH)/framework.mk

after-NougatServices-stage::
	@# create directories
	$(ECHO_NOTHING)mkdir -p $(THEOS_STAGING_DIR)/Library/Frameworks$(ECHO_END)

	@# /usr/lib/NougatServices.framework -> /Library/Frameworks/NougatServices.framework
	$(ECHO_NOTHING)ln -s /usr/lib/NougatServices.framework $(THEOS_STAGING_DIR)/Library/Frameworks/NougatServices.framework$(ECHO_END)