include $(THEOS)/makefiles/common.mk

TWEAK_NAME = Nougat
Nougat_FILES = $(wildcard *.x) $(wildcard *.m)
Nougat_FRAMEWORKS = UIKit
Nougat_PRIVATE_FRAMEWORKS = BaseBoard FrontBoard FrontBoardServices SpringBoardUI
Nougat_EXTRA_FRAMEWORKS = NougatUI NougatServices
Nougat_CFLAGS = -I../Headers

include $(THEOS_MAKE_PATH)/tweak.mk