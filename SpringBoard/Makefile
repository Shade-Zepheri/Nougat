include $(THEOS)/makefiles/common.mk

TWEAK_NAME = Nougat
Nougat_FILES = $(wildcard *.x)
Nougat_FRAMEWORKS = UIKit
Nougat_EXTRA_FRAMEWORKS = NougatUI NougatServices
Nougat_CFLAGS = -I../Headers
Nougat_LDFLAGS += -F$(THEOS_OBJ_DIR)

include $(THEOS_MAKE_PATH)/tweak.mk