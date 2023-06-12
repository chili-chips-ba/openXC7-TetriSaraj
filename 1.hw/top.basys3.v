/*
 *  PicoSoC - A simple example SoC using PicoRV32
 *
 *  Copyright (C) 2017  Clifford Wolf <clifford@clifford.at>
 *
 *  Permission to use, copy, modify, and/or distribute this software for any
 *  purpose with or without fee is hereby granted, provided that the above
 *  copyright notice and this permission notice appear in all copies.
 *
 *  THE SOFTWARE IS PROVIDED "AS IS" AND THE AUTHOR DISCLAIMS ALL WARRANTIES
 *  WITH REGARD TO THIS SOFTWARE INCLUDING ALL IMPLIED WARRANTIES OF
 *  MERCHANTABILITY AND FITNESS. IN NO EVENT SHALL THE AUTHOR BE LIABLE FOR
 *  ANY SPECIAL, DIRECT, INDIRECT, OR CONSEQUENTIAL DAMAGES OR ANY DAMAGES
 *  WHATSOEVER RESULTING FROM LOSS OF USE, DATA OR PROFITS, WHETHER IN AN
 *  ACTION OF CONTRACT, NEGLIGENCE OR OTHER TORTIOUS ACTION, ARISING OUT OF
 *  OR IN CONNECTION WITH THE USE OR PERFORMANCE OF THIS SOFTWARE.
 *
 */

module top (
    input 	clk,		// 100MHz on Basys 3
	
	input 	btnC,		// btnCenter on Basys 3
	input	btnU,		// btnUp on Basys 3
	input 	btnD,		// btnDown on Basys 3
	input 	btnL,		// btnLeft on Basys 3
	input	btnR,		// btnRight on Basys 3
	
    output 	tx,
    input  	rx,

    input  [15:0] sw,
    output [15:0] led,	
	
    output hsync,       // to VGA connector
    output vsync,       // to VGA connector	
	output [11:0] rgb   // to DAC, to VGA connector
);

    // VGA signals
	wire [9:0] 		w_x, w_y;
    wire 			w_video_on, w_p_tick;
    reg  [11:0] 	rgb_reg;
    wire [11:0] 	rgb_next;
	
	wire clk_bufg;
	BUFG bufg (
		.I(clk),
		.O(clk_bufg)
	);
	
	wire btnC_out;
	debounce debBtnC (
		.clk	(clk), 
		.in		(btnC), 
		.out	(btnC_out)
	);

	wire btnL_out;
	debounce debBtnL (
		.clk	(clk), 
		.in		(btnL), 
		.out	(btnL_out)
	);
	
	wire btnR_out;
	debounce debBtnR (
		.clk	(clk), 
		.in		(btnR), 
		.out	(btnR_out)
	);	
	
	wire btnD_out;
	debounce debBtnD (
		.clk	(clk), 
		.in		(btnD), 
		.out	(btnD_out)
	);	
	
	wire btnU_out;
	debounce debBtnU (
		.clk	(clk), 
		.in		(btnU), 
		.out	(btnU_out)
	);
	
    ///////////////////////////////////
    // Power-on Reset
    ///////////////////////////////////
    reg [5:0] reset_cnt = 0;
    wire resetn = &reset_cnt;

    always @(posedge clk_bufg) begin
        reset_cnt <= reset_cnt + !resetn;
    end	

    ///////////////////////////////////
    // Peripheral Bus
    ///////////////////////////////////	
	wire        iomem_valid;
	reg         iomem_ready;
	wire [ 3:0] iomem_wstrb;
	wire [31:0] iomem_addr;
	wire [31:0] iomem_wdata;
	reg  [31:0] iomem_rdata;

	reg  [31:0] gpio;
	wire [4:0]  debug_pins_char_gen;
	reg gpio_iomem_ready;
	wire vga_iomem_ready;
	reg [31:0] gpio_iomem_rdata;

	wire[4:0] buttons;
	assign buttons = { btnC_out, btnD_out, btnL_out, btnR_out, btnU_out};
 		
    // enable signals for each of the peripherals
    wire gpio_en    = (iomem_addr[31:24] == 8'h03); /* GPIO mapped to 0x03xx_xxxx */
    wire video_en   = (iomem_addr[31:24] == 8'h05); /* Video device mapped to 0x05xx_xxxx */
	
	assign led[9:0] = gpio[9:0];	
	assign led[10] = r_CLK_1HZ;
	assign led[15:11] = debug_pins_char_gen;	

	assign iomem_ready = gpio_en ? gpio_iomem_ready : ( video_en ? vga_iomem_ready : 1'b0);		
	assign iomem_rdata = gpio_en ? gpio_iomem_rdata : 32'h00000000;	
	
	always @(posedge clk) 
	begin
		if (!resetn) begin
			gpio <= 0;
		end else begin
			gpio_iomem_ready <= 0;
			if (iomem_valid && !iomem_ready && gpio_en) begin
				gpio_iomem_ready <= 1;
				gpio_iomem_rdata <= {8'h00, hsync, vsync, w_video_on, buttons[4:0], gpio[15:0]};
				if (iomem_wstrb[0]) gpio[7:0] <= iomem_wdata[7:0];
				if (iomem_wstrb[1]) gpio[15:8] <= iomem_wdata[15:8];
				if (iomem_wstrb[2]) gpio[23:16] <= iomem_wdata[23:16];
				if (iomem_wstrb[3]) gpio[31:24] <= iomem_wdata[31:24];					
			end
		end
	end
	
	// uC Circuit		
	picosoc_noflash soc (
		.clk	(clk),	 
		.resetn	(resetn),

		.ser_tx	(tx),
		.ser_rx	(rx),

		.irq_5	(1'b0),
		.irq_6	(1'b0),
		.irq_7	(1'b0),

		.iomem_valid(iomem_valid),
		.iomem_ready(iomem_ready),
		.iomem_wstrb(iomem_wstrb),
		.iomem_addr (iomem_addr),
		.iomem_wdata(iomem_wdata),
		.iomem_rdata(iomem_rdata)
	);	

    // VGA Controller
    vga_controller vga(
		.clk_100MHz(clk), 
		.reset(!resetn), 		
		.hsync(hsync), 
		.vsync(vsync),
		.video_on(w_video_on), 
		.p_tick(w_p_tick), 
		.x(w_x), 
		.y(w_y)
	);
	
    // VGA Wrapper
    vga_wrapper at(
		.clk(clk),
		.reset(!resetn),		
		.vga_iomem_ready(vga_iomem_ready),
		
		.iomem_valid(iomem_valid && video_en),
		.iomem_ready(iomem_ready),
		.iomem_wstrb(iomem_wstrb),
		.iomem_addr(iomem_addr),
		.iomem_wdata(iomem_wdata),

		.video_on(w_video_on), 
		.x(w_x), 
		.y(w_y), 
		.rgb(rgb_next),
		
		.o_debug_pins(debug_pins_char_gen)
	);
	
    // RGB buffer
    always @(posedge clk)
	begin
        if(w_p_tick)
            rgb_reg <= rgb_next;
	end
	
    // output
    assign rgb = rgb_reg;
	
    // Constants (parameters) to create the frequencies needed:
    // Input clock is 100.0 MHz, system clock.
    // Formula is: (100000 KHz / 1 Hz) * 50% duty cycle    
    // So for 1/2 Hz: (100000000 / 1) * 0.5 = 50000000, Input clock is generated 100MHz        
    parameter c_CNT_CLK_HZ = 50000000;        
    // These signals will be the counters:        
    reg [31:0] r_CNT_CLK_HZ = 0;       
    // These signals will toggle at the frequencies needed:          
    reg r_CLK_1HZ       = 1'b0;        
    always @(posedge clk)  
    begin        
        if (r_CNT_CLK_HZ == c_CNT_CLK_HZ-1) begin// -1, since counter starts at 0                
            r_CLK_1HZ <= !r_CLK_1HZ;
            r_CNT_CLK_HZ <= 0;
        end else
            r_CNT_CLK_HZ <= r_CNT_CLK_HZ + 1;            
    end                                         
    //------------------------------------------------------------------------------    
	
endmodule
