///////////////////////////////////////////////////////////////////////////////
//
// (c) Copyright 2022 -- CHILI CHIPS LLC, All rights reserved.
//
//                      PROPRIETARY INFORMATION
//
// The information contained in this file is the property of CHILI CHIPS LLC.
// Except as specifically authorized in writing by CHILI CHIPS LLC, the holder
// of this file: (1) shall keep all information contained herein confidential;
// and (2) shall protect the same in whole or in part from disclosure and
// dissemination to all third parties; and (3) shall use the same for operation
// and maintenance purposes only.
//-----------------------------------------------------------------------------
// Top level of a future full video game. It instantiates:
//   1) video back-end that generates pixel clock and renders the screen
//   2) video front-end that creates the game 
// Also included is LED activity monitor which mimics game speed / difficulty.
//
// RTL is written in a way that facilitates porting to different FPGA platforms.
// Tested with:
//  1) Xilinx Artix7    (XC7A35T-1CPG236) on Digilent Cmod A7-35T, 24MHz ext.clock
//  2) GoWin  LittleBee (GW1NR-9C)        on Sipeed   TangNano-9K, 27MHz ext.clock
///////////////////////////////////////////////////////////////////////////////

module hdmi_wrapper 
   import hdmi_pkg::*;
(
   input  logic  clk_ext, // External clock: GoWin=27MHz; Artix7=24MHz
   input  logic  clk,       //Added - 100MHz
   input  logic  reset,

 //Added
   output logic vga_iomem_ready,
   input logic iomem_valid,
   input logic iomem_ready,
   input [3:0]  iomem_wstrb,
   input [31:0] iomem_addr,
   input [31:0] iomem_wdata,

 //HDMI output, goes directly to connector
   output logic  hdmi_clk_p,
   output logic  hdmi_clk_n,
   output bus3_t hdmi_dat_p,
   output bus3_t hdmi_dat_n

// active-low LED monitor
   //output logic  led_n, 

);

   //logic   clk_pix;
   logic   srst_n;
   logic   frame_done;
   logic   mfram_done;

   bus12_t x, y;
   pix_t   pix;

 //Added
   logic video_on;
//-----------------------------------------------------------
// Color generation algorithm: Based on the X,Y screen coordinates,
// set colors as you wish, or your imagination whispers to your ear
//    24'h00_00_00 is pitch-black 
//    24'hFF_FF_FF is bright-white
//
//   [2]=Red, [1]=Green, [0]=Blue
//
// Resolution is 1280x720Px60Hz, thus:
//    max visible X=1279 [10:0]
//    max visible Y= 719 [9:0]
//-----------------------------------------------------------č
   
    // signal declarations
	wire charset_on, charset_on1, charset_on2;	
	reg char_mem_write, map_mem_write;
	wire [13:0] write_address;    
	wire [11:0] map_read_address;
    wire [13:0] read_address;
	wire [11:0] rgb_rdata;
	wire [3:0] map_rdata;		
	
	always @(posedge clk) 
	begin
		if (reset) begin			
			char_mem_write <= 0;	
			map_mem_write <= 0;
		end else begin
			vga_iomem_ready <= 0;
			char_mem_write <= 0;
			map_mem_write <= 0;
			if (iomem_valid && !iomem_ready) begin
				vga_iomem_ready <= 1;				
				if(iomem_addr[23:20]==4'h1) begin
					if(iomem_wstrb[0]) begin
						char_mem_write <= 1;						
					end				
				end else if(iomem_addr[23:20]==4'h2) begin
					if(iomem_wstrb[0]) begin
						map_mem_write <= 1;
					end
				end
			end
		end
	end
	
	assign write_address = (iomem_addr[15:0]/4);
    //assign read_address = {map_rdata, y[3:0], x[3:0]};          //for 640x480
	//assign map_read_address = ( y >> 4 ) * 6'd40 + ( x >> 4 );  //for 640x480
    assign read_address = map_rdata*10'd768 + (y % 5'd24)*6'd32 + x[4:0];   //for 1280x720
	assign map_read_address = (y / 5'd24) * 6'd40 + ( x >> 5 );             //for 1280x720

	vga_map_ram map(
		.clk(clk),
		.wen(map_mem_write),			
		.waddr(write_address),		
		.wdata(iomem_wdata[3:0]),
		.ren(video_on), 
		.raddr(map_read_address), 
		.rdata(map_rdata)
	);
	
	vga_ram ram(
		.clk(clk),
		.wen(char_mem_write),			
		.waddr(write_address),		
		.wdata(iomem_wdata[11:0]),
		.ren(video_on), 
		.raddr(read_address), 
		.rdata(rgb_rdata)
	);
	

    // rgb multiplexing circuit
    always @(*)
	begin
        if(~video_on)
            pix = 24'h000000;      // blank
        else	
			//pix = rgb_rdata;
            pix[23:20] = rgb_rdata[11:8];   // Kopira R[3:0] u pix[23:20]
            pix[19:16] = 4'b0000;           // Postavlja 4 bita na 0
            pix[15:12] = rgb_rdata[7:4];    // Kopira G[3:0] u pix[15:12]
            pix[11:8]  = 4'b0000;           // Postavlja 4 bita na 0
            pix[7:4]   = rgb_rdata[3:0];    // Kopira B[3:0] u pix[7:4]
            pix[3:0]   = 4'b0000;           // Postavlja 4 bita na 0
	end

//-----------------------------------------------------------
// HDMI Backend: 1280x720P@60Hz display renderer
//-----------------------------------------------------------
   hdmi_backend u_hdmi_backend ( 
      .clk_ext    (clk_ext),    //i
      .clk_pix    (clk_pix),    //o 
      .srst_n     (srst_n),     //o
                                 
    // Current X and Y position of the pixel
      .hcount     (x),          //o[11:0] 
      .vcount     (y),          //o[11:0]  
      .pix        (pix),        //i[7:0].R/G/B

    //Pulse1 when done rendering: 
      .frame_done (frame_done), //o
      .mfram_done (mfram_done), //o

      .hdmi_clk_p (hdmi_clk_p), //o 
      .hdmi_clk_n (hdmi_clk_n), //o 
      .hdmi_dat_p (hdmi_dat_p), //o[2:0] 
      .hdmi_dat_n (hdmi_dat_n), //o[2:0] 

      .video_on   (video_on)
   );
   
endmodule: hdmi_wrapper

/*
------------------------------------------------------------------------------
Version History:
------------------------------------------------------------------------------
 2022/10/9 JI: initial creation    
*/
