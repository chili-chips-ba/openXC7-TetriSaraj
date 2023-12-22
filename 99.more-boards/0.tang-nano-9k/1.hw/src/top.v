module top (
    input 	clk_27,		// 100MHz on Basys 3 //27MHz on TangNano9k
	
	input 	btnC,		// btnCenter on Basys 3
	input	btnU,		// btnUp on Basys 3
	input 	btnD,		// btnDown on Basys 3
	input 	btnL,		// btnLeft on Basys 3
	input	btnR,		// btnRight on Basys 3

    output  [5:0] led_n,

    //HDMI output, goes directly to connector
    output hdmi_clk_p,
    output hdmi_clk_n,
    output  [2:0] hdmi_dat_p,
    output  [2:0] hdmi_dat_n

);

    //clk_27 to clk_75
    Gowin_rPLL clk27_to_clk64_8(
        .clkout(clk), //output clkout
        .clkin(clk_27) //input clkin
    );

    ///////////////////////////////////
    // Peripheral Bus
    ///////////////////////////////////	
	wire            iomem_valid;
	wire            iomem_ready;
	wire    [ 3:0]  iomem_wstrb;
	wire    [31:0]  iomem_addr;
	wire    [31:0]  iomem_wdata;
	wire    [31:0]  iomem_rdata;

	reg     [31:0]  gpio;
	reg     [31:0]  gpio_iomem_rdata;
	reg 		    gpio_iomem_ready;
	wire 		    vga_iomem_ready;
	
	wire[4:0] buttons;
	assign buttons = { btnC, btnD, btnL, btnR, btnU};
 		
    // enable signals for each of the peripherals
    wire gpio_en    = (iomem_addr[31:24] == 8'h03); /* GPIO mapped to 0x03xx_xxxx */
    wire video_en   = (iomem_addr[31:24] == 8'h05); /* Video device mapped to 0x05xx_xxxx */
	
	assign led_n[0] = btnL;
    assign led_n[1] = btnR;

    assign iomem_ready = gpio_en ? gpio_iomem_ready : ( video_en ? vga_iomem_ready : 1'b0);		
	assign iomem_rdata = gpio_en ? gpio_iomem_rdata : 32'h00000000;	

    wire resetn = btnL;
	
	always @(posedge clk) 
	begin
		if (!resetn) begin
			gpio <= 0;
		end else begin
			gpio_iomem_ready <= 0;
			if (iomem_valid && !iomem_ready && gpio_en) begin
				gpio_iomem_ready <= 1;
				gpio_iomem_rdata <= {8'h00, 1'b0, 1'b0, 1'b0, buttons[4:0], gpio[15:0]};
				if (iomem_wstrb[0]) gpio[7:0] <= iomem_wdata[7:0];
				if (iomem_wstrb[1]) gpio[15:8] <= iomem_wdata[15:8];
				if (iomem_wstrb[2]) gpio[23:16] <= iomem_wdata[23:16];
				if (iomem_wstrb[3]) gpio[31:24] <= iomem_wdata[31:24];					
			end
		end
	end

    //irrelevant variables currently without uart
    wire tx_uc, rx_uc;

    reg [31:0] 	ram_data, ram_addr;
    reg progmem_wen;

    // uC Circuit		
	picosoc_noflash soc (
		.clk	(clk),	 
		.resetn	(resetn),

		.ser_tx	(tx_uc),
		.ser_rx	(rx_uc),

		.irq_5	(1'b0),
		.irq_6	(1'b0),
		.irq_7	(1'b0),

		.iomem_valid(iomem_valid),
		.iomem_ready(iomem_ready),
		.iomem_wstrb(iomem_wstrb),
		.iomem_addr (iomem_addr),
		.iomem_wdata(iomem_wdata),
		.iomem_rdata(iomem_rdata),
		
		.progmem_wen	(progmem_wen),
		.progmem_waddr	(ram_addr),
		.progmem_wdata	(ram_data)		
	);	

    hdmi_wrapper hw(
		.clk_ext(clk_27),
        .clk(clk),
		.reset(!resetn),
		
		.vga_iomem_ready(vga_iomem_ready),	
		.iomem_valid(iomem_valid && video_en),
		.iomem_ready(iomem_ready),
		.iomem_wstrb(iomem_wstrb),
		.iomem_addr(iomem_addr),
		.iomem_wdata(iomem_wdata),

        .hdmi_clk_p(hdmi_clk_p),
        .hdmi_clk_n(hdmi_clk_n),
        .hdmi_dat_p(hdmi_dat_p),
        .hdmi_dat_n(hdmi_dat_n)
	);

endmodule