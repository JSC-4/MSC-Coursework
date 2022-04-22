CC = arm-linux-gnueabihf-gcc 
obj-m := hcsr04.o
SRC := $(shell pwd)
all:
	$(MAKE) -C $(KERNEL_SRC) M=$(SRC)

modules_install:
	$(MAKE) INSTALL_MOD_DIR=kernel/drivers/my_mod -C $(KERNEL_SRC) M=$(SRC) modules_install
hcsr04_test:hcsr04_test.c
	$(CC) -o $@ $^

clean:
	rm -f *.o *~core.depend .*.cmd *.ko *.mod.c 
	rm -f Module.markers Module.symvers modules
	rm -rf .tmp_versions Modules.symvers

