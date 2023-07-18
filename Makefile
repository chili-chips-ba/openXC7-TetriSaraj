PREFIX ?= /snap/openxc7/current
DB_DIR=${PREFIX}/opt/nextpnr-xilinx/external/prjxray-db
CHIPDB=../chipdb

#PART = xc7a100tcsg324-1
PART = xc7a35tcpg236-1



.PHONY: all
all: top.bit

.PHONY: program
program: top.bit
	openFPGALoader --board basys3 --bitstream $<
	
top.json: basys3.v picosoc_noflash.v picorv32.v simpleuart.v progmem.v debounce.v vga_ram.v vga_map_ram.v vga_wrapper.v vga_controller.v seven_segment_ctrl.v uart_tx.v uart_rx.v
	yosys -p "synth_xilinx -flatten -abc9 -nobram -arch xc7 -top top; write_json top.json" basys3.v picosoc_noflash.v picorv32.v simpleuart.v progmem.v debounce.v vga_ram.v vga_map_ram.v vga_wrapper.v vga_controller.v seven_segment_ctrl.v uart_tx.v uart_rx.v


# The chip database only needs to be generated once
# that is why we don't clean it with make clean
${CHIPDB}/${PART}.bin:
	python3 ${PREFIX}/opt/nextpnr-xilinx/python/bbaexport.py --device ${PART} --bba ${PART}.bba
	bbasm -l ${PART}.bba ${CHIPDB}/${PART}.bin
	rm -f ${PART}.bba

top.fasm: top.json ${CHIPDB}/${PART}.bin
	nextpnr-xilinx --chipdb ${CHIPDB}/${PART}.bin --xdc basys3.xdc --json top.json --fasm $@ --verbose --debug
	
top.frames: top.fasm
	fasm2frames --part ${PART} --db-root ${DB_DIR}/artix7 $< > $@ #FIXME: fasm2frames should be on PATH

top.bit: top.frames
	xc7frames2bit --part_file ${DB_DIR}/artix7/${PART}/part.yaml --part_name ${PART} --frm_file $< --output_file $@
	

	
.PHONY: clean
clean:
	@rm -f *.bit
	@rm -f *.frames
	@rm -f *.fasm
	@rm -f *.json
clean_fw:
	rm -f main.elf
	rm -f main.lds
	rm -f main.map
	rm -f main.bin
	rm -f progmem.v
	rm -f firmware.hex
	rm -f main.hex
