include $(THEOS)/makefiles/common.mk

TWEAK_NAME = Nougat
Nougat_FILES = $(wildcard *.x)
Nougat_FRAMEWORKS = UIKit
Nougat_EXTRA_FRAMEWORKS = NougatUI NougatServices
Nougat_CFLAGS = -I../Headers

include $(THEOS_MAKE_PATH)/tweak.mk

ifeq ($(SIMULATOR),1)
after-all::
	@echo Copying .dylib to /opt/simject
	@cp -v $(THEOS_OBJ_DIR)/$(TWEAK_NAME).dylib /opt/simject
	@echo Copying .plist to /opt/simject
	@cp -v $(TWEAK_NAME).plist /opt/simject
	@echo Signing .dylib in /opt/simject
	@ldid -S /opt/simject/$(TWEAK_NAME).dylib
endif