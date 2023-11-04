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
// Technology-specific GoWin PLL. From external 27MHz source, creates:
//
// for rendering on a 1280x720P@60Hz screen, CVT-RBv2
//      302.28MHz 5x serial pixel clock
//       60.465MHz pixel clock
//
//
// Also see: https://github.com/hdl-util/hdmi
///////////////////////////////////////////////////////////////////////////////

module fpga_pll (
   input  logic clk_ext,  // 27MHz for the Sipeed GoWin board

   output logic srst_n,
   output logic clk_pix5, // 5x pixel clock: 302.28MHz
   output logic clk_pix   // pixel clock: 60.465MHz
);

   logic pll_lock;
   logic srst_n_pipe;

//--------------------------------------------------
//-- Clock multiplier from 27MHz
//--------------------------------------------------
   rPLL #(
   //___1920x1080: Our GoWin FPGA cannot reliably do it

   //___1280x720, CVT-RBv2
      .DEVICE           ("GW1NR-9C"),
      .FCLKIN           ("27"),
      .DYN_IDIV_SEL     ("false"),
      .IDIV_SEL         (4),
      .DYN_FBDIV_SEL    ("false"),
      .FBDIV_SEL        (55),
      .DYN_ODIV_SEL     ("false"),
      .ODIV_SEL         (2),
      .PSDA_SEL         ("0000"),
      .DYN_DA_EN        ("true"),
      .DUTYDA_SEL       ("1000"),
      .CLKOUT_FT_DIR    (1'b1),
      .CLKOUTP_FT_DIR   (1'b1),
      .CLKOUT_DLY_STEP  (0),
      .CLKOUTP_DLY_STEP (0),
      .CLKFB_SEL        ("internal"),
      .CLKOUT_BYPASS    ("false"),
      .CLKOUTP_BYPASS   ("false"),
      .CLKOUTD_BYPASS   ("false"),
      .DYN_SDIV_SEL     (2),
      .CLKOUTD_SRC      ("CLKOUT"),
      .CLKOUTD3_SRC     ("CLKOUT")

   )
   u_pll (
      .CLKOUT   (clk_pix5),
      .LOCK     (pll_lock),
      .CLKOUTP  (),
      .CLKOUTD  (),
      .CLKOUTD3 (),
       
      .RESET    (1'b0),
      .RESET_P  (1'b0),
      .CLKIN    (clk_ext),
      .CLKFB    (1'b0),
      .FBDSEL   ('0),
      .IDSEL    ('0),
      .ODSEL    ('0),
      .PSDA     ('0),
      .DUTYDA   ('0),
      .FDLY     ('0)
   );

//--------------------------------------------------
// Clock divider: 302.28MHz -> 60.465MHz
//--------------------------------------------------
   CLKDIV #(
      .DIV_MODE ("5"),
      .GSREN    ("false")
   )
   u_clkdiv (
      .CLKOUT   (clk_pix),
      .HCLKIN   (clk_pix5),
      .RESETN   (pll_lock),
      .CALIB    (1'b0)
   );

//--------------------------------------------------
// Reset synchronizer
//--------------------------------------------------

  always_ff @(negedge pll_lock or posedge clk_pix) begin  
     if (pll_lock == 1'b0) begin
        srst_n_pipe <= 1'b0;
        srst_n      <= 1'b0;
     end
     else begin   
        srst_n_pipe <= 1'b1;
        srst_n      <= srst_n_pipe;
     end
  end

endmodule: fpga_pll

/*
------------------------------------------------------------------------------
Version History:
------------------------------------------------------------------------------
 2022/10/28 IV,AV: initial creation    
*/
                         
