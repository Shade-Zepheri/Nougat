include $(THEOS)/makefiles/common.mk

# Get Sources
SOURCES  = $(shell find . -name '*.m')
SOURCES += $(shell find . -name '*.x')
HEADERS = $(shell find . -name '*.h') 

FRAMEWORK_NAME = NougatUI
NougatUI_FILES = $(SOURCES)
NougatUI_PUBLIC_HEADERS = $(HEADERS)
NougatUI_FRAMEWORKS = UIKit QuartzCore
NougatUI_EXTRA_FRAMEWORKS = NougatServices
NougatUI_LIBRARIES = flipswitch palette
NougatUI_CFLAGS = -I../Headers -IMedia -INotifications -IButtons -IExtensions
NougatUI_LDFLAGS = $(wildcard *.tbd)
NougatUI_INSTALL_PATH = /usr/lib

include $(THEOS_MAKE_PATH)/framework.mk

after-NougatUI-stage::
	@# create directories
	$(ECHO_NOTHING)mkdir -p $(THEOS_STAGING_DIR)/Library/Frameworks$(ECHO_END)

	@# /usr/lib/NougatUI.framework -> /Library/Frameworks/NougatUI.framework
	$(ECHO_NOTHING)ln -s /usr/lib/NougatUI.framework $(THEOS_STAGING_DIR)/Library/Frameworks/NougatUI.framework$(ECHO_END)