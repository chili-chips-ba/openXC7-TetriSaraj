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

module top 
   import hdmi_pkg::*;
(
   input  logic  clk_ext, // External clock: GoWin=27MHz; Artix7=24MHz

   input  logic  butnL_n, // moveLeft  button -\ they return 0
   input  logic  butnR_n, // moveRight button -/  when pressed

 //HDMI output, goes directly to connector
   output logic  hdmi_clk_p,
   output logic  hdmi_clk_n,
   output bus3_t hdmi_dat_p,
   output bus3_t hdmi_dat_n,

// active-low LED monitor
   output logic  led_n 
);

   logic   clk_pix, srst_n;
   logic   frame_done;
   logic   mfram_done;

   bus12_t x, y;
   pix_t   pix;

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
//-----------------------------------------------------------
  always_comb begin: _my_game
     if (y[9:6] > 4'd8) begin // horizontal Gradient
        pix.R = x[10:3];
        pix.G = x[8:1];
        pix.B = x[7:0];
     end
     else unique case (x[10:7])
        4'd0: begin // pure Red
           pix.R = '1;
           pix.G = '0;
           pix.B = '0;
        end
        4'd1: begin // pure Green
           pix.R = '0;
           pix.G = '1;
           pix.B = '0;
        end
        4'd2: begin // pure Blue
           pix.R = '0;
           pix.G = '0;
           pix.B = '1;
        end
        4'd3: begin // vertical Gradient
           pix.R = {1'd0, y[5:0], 1'd1};
           pix.G = {1'd0, y[5:0], 1'd1};
           pix.B = {1'd0, y[5:0], 1'd1};
        end
        default: begin // interesting Scottish pattern
           pix.R = {y[5], x[5], y[5], x[5], 4'h4};
           pix.G = {y[6], x[3], y[6], x[3], 4'h3};
           pix.B = {x[7], y[1], x[7], y[1], 4'h2};
        end
     endcase
  end: _my_game
   

//-----------------------------------------------------------
// HDMI Backend: 1290x720P@60Hz display renderer
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
      .hdmi_dat_n (hdmi_dat_n)  //o[2:0] 
   );
    
//-----------------------------------------------------------
// LED monitor of game update speed is also provided
// For the light to be seen, convert from narrow Pulse1 to 50% duty cycle
//-----------------------------------------------------------
   always_ff @(negedge srst_n or posedge clk_pix) begin: _led_mon
      if (srst_n == LO) begin
         led_n <= HI;
      end
      else if (mfram_done == HI) begin
         led_n <= ~led_n;
      end
   end: _led_mon
   
endmodule: top

/*
------------------------------------------------------------------------------
Version History:
------------------------------------------------------------------------------
 2022/10/9 JI: initial creation    
*/
