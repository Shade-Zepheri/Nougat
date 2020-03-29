include $(THEOS)/makefiles/common.mk

TWEAK_NAME = Nougat
Nougat_FILES = $(wildcard *.x) $(wildcard *.m)
Nougat_FRAMEWORKS = UIKit
Nougat_EXTRA_FRAMEWORKS = NougatUI NougatServices
Nougat_CFLAGS = -I../Headers
Nougat_LDFLAGS = $(wildcard *.tbd)

include $(THEOS_MAKE_PATH)/tweak.mk