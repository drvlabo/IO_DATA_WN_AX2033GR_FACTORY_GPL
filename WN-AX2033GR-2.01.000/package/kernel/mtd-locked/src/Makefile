PWD	:= $(shell pwd)
EXTRA_CFLAGS := -DCONFIG_KMOD_MTD_LOCKED_MTD_NAME='"$(LOCKEDMTDNAME)"'

default: all

obj-m           :=  mtd_locked.o

all:
	make -C $(KERNELPATH) M=$(PWD) modules

clean:
	rm -rf Module.markers  Module.symvers modules.order *~ *.o *.ko *.mod.o *.mod.c
