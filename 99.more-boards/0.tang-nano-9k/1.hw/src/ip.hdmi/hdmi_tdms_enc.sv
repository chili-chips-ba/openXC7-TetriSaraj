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
// Description: HDMI TDMS Encoder 
//  8 bits colour, 2 control bits and one blanking bits in the 10 bits
//  of TDMS-encoded data out. Runs with the pixel clock
///////////////////////////////////////////////////////////////////////////////

module hdmi_tdms_enc 
   import hdmi_pkg::*;
(
   input  logic   clk,
   input  logic   blank,
   input  tdms_t  raw,
                    
   output tdms_t  encoded
);

   bus9_t   xored;
   bus9_t   xnord;
             
   bus4_t   num_ones;

   bus9_t   data;
   bus9_t   data_n;

   bus4_t   data_disparity;

   bus4_t   dc_bias;
   bus4_t   dc_bias_plus;
   bus4_t   dc_bias_minus;

//-----------------------------------------------------
   always_comb begin: _comb
        
   // work out two different encodings for the byte
      xored[0] = raw.d[0];
      xnord[0] = raw.d[0];
      for (int i=1; i<8; i++) begin
         xored[i] =   raw.d[i] ^ xored[i-1];
         xnord[i] = ~(raw.d[i] ^ xnord[i-1]);
      end
      xored[8] = HI;
      xnord[8] = LO;
      
   // count how many ones are set in data
      num_ones = 4'd0;
      for (int i=0; i<8; i++) begin
         num_ones = num_ones + {3'd0, raw.d[i]};
      end     
 
   // decide which encoding to use
      if (
             ( num_ones > 4'd4) 
          || ({num_ones, raw.d[0]} == {4'd4, LO})
      ) begin
         data   =  xnord;
         data_n = ~xnord;
      end
      else begin
         data   =  xored;
         data_n = ~xored;
      end

   // Work out the DC bias of the dataword
      data_disparity = 4'd12;
      for (int i=0; i<8; i++) begin
         data_disparity = data_disparity + {3'd0, data[i]};
      end

   // Common/reused math
      dc_bias_plus  = bus4_t'(dc_bias + data_disparity);
      dc_bias_minus = bus4_t'(dc_bias - data_disparity);

   end: _comb
          
 
//-----------------------------------------------------
// work out what the final output should be
//-----------------------------------------------------
   always_ff @(posedge clk) begin: _flop
      if (blank == HI) begin 
         dc_bias <= '0;

       //in the control periods, all values have balanced bit count
         unique case (raw.c)
            2'd0   : encoded <= 10'b11_0101_0100;
            2'd1   : encoded <= 10'b00_1010_1011;
            2'd2   : encoded <= 10'b01_0101_0100;
            default: encoded <= 10'b10_1010_1011;
         endcase
      end
      else begin
         // dataword has no disparity
         if ((dc_bias == '0) || (data_disparity == '0)) begin
            if (data[8] == HI) begin
               dc_bias <= dc_bias_plus;
               encoded <= {2'b01, data[7:0]};
            end
            else begin
               dc_bias <= dc_bias_minus;
               encoded <= {2'b10, data_n[7:0]};
            end
         end

         // dataword has disparity
         else if (
             ({dc_bias[3], data_disparity[3]} == 2'b00)
          || ({dc_bias[3], data_disparity[3]} == 2'b11) 
         ) begin
            encoded <= {HI, data[8], data_n[7:0]};
            dc_bias <= bus4_t'(dc_bias_minus + {3'd0, data[8]});
         end

         else begin
            encoded <= {LO, data};
            dc_bias <= bus4_t'(dc_bias_plus - {3'd0, data_n[8]});
         end
      end // else: !if(blank == HI)
   end: _flop

endmodule: hdmi_tdms_enc

/*
------------------------------------------------------------------------------
Version History:
------------------------------------------------------------------------------
 2022/10/9 JI: initial creation    
*/
