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
NougatUI_LIBRARIES = flipswitch
NougatUI_CFLAGS = -I../Headers -IMedia -INotifications
NougatUI_LDFLAGS = $(wildcard *.tbd)
NougatUI_INSTALL_PATH = /Library/Frameworks

include $(THEOS_MAKE_PATH)/framework.mk