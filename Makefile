# Run these 4 lines every time you start WSL
# export F4PGA_INSTALL_DIR=/opt/f4pga
# export FPGA_FAM="xc7"
# source "$F4PGA_INSTALL_DIR/$FPGA_FAM/conda/etc/profile.d/conda.sh"
# conda activate $FPGA_FAM

# Then clean and compile firmware C files
# make clean_fw
# make firmware

# The last command is to generate the bit file
# make -C .

current_dir := ${CURDIR}
TARGET      := basys3
TOP         := top

SOURCES     := \
	${current_dir}/1.hw/ip.misc/debounce.v \
	${current_dir}/1.hw/ip.misc/simpleuart.v \
	/
	${current_dir}/1.hw/ip.cpu/progmem.v \
	${current_dir}/1.hw/ip.cpu/picorv32.v \
	${current_dir}/1.hw/ip.cpu/picosoc_noflash.v \
	/
	${current_dir}/1.hw/ip.vga/vga_ram.v \
	${current_dir}/1.hw/ip.vga/vga_map_ram.v \
	${current_dir}/1.hw/ip.vga/vga_wrapper.v \
	${current_dir}/1.hw/ip.vga/vga_controller.v \
	\
	${current_dir}/1.hw/top.basys3.v

BOARD_BUILDDIR := ${current_dir}/3.build

#Install gcc package: apt install gcc-riscv64-unknown-elf
CROSS=riscv64-unknown-elf-

XDC := ${current_dir}1.hw/top.basys3.xdc

#include ${current_dir}/../../common/common.mk

firmware: 2.sw/main.elf
        $(CROSS)objcopy -O binary 2.sw/main.elf 2.sw/main.bin
        python progmem.py

main.elf: 2.sw/main.lds 2.sw/start.s 2.sw/main.c
        $(CROSS)gcc $(CFLAGS) -march=rv32im -mabi=ilp32 -Wl,--build-id=none,-Bstatic,-T,main.lds,-Map,main.map,--strip-debug -ffreestanding -nostdlib -o 2.sw/main.elf 2.sw/start.s 2.sw/main.c 2.sw/uart.c

main.lds: 2.sw/sections.lds
        $(CROSS)cpp -P -o $@ $^

clean_fw:
        rm -f 1.hw/ip.cpu/progmem.v
        rm -f 2.sw/main.elf
        rm -f 2.sw/main.lds
        rm -f 2.sw/main.map
        rm -f 2.sw/main.bin
