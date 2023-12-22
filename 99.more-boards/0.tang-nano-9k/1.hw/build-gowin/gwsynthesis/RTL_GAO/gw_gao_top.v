module gw_gao(
    \hw/rgb_rdata[11] ,
    \hw/rgb_rdata[10] ,
    \hw/rgb_rdata[9] ,
    \hw/rgb_rdata[8] ,
    \hw/rgb_rdata[7] ,
    \hw/rgb_rdata[6] ,
    \hw/rgb_rdata[5] ,
    \hw/rgb_rdata[4] ,
    \hw/rgb_rdata[3] ,
    \hw/rgb_rdata[2] ,
    \hw/rgb_rdata[1] ,
    \hw/rgb_rdata[0] ,
    \hw/read_address[13] ,
    \hw/read_address[12] ,
    \hw/read_address[11] ,
    \hw/read_address[10] ,
    \hw/read_address[9] ,
    \hw/read_address[8] ,
    \hw/read_address[7] ,
    \hw/read_address[6] ,
    \hw/read_address[5] ,
    \hw/read_address[4] ,
    \hw/read_address[3] ,
    \hw/read_address[2] ,
    \hw/read_address[1] ,
    \hw/read_address[0] ,
    \hw/map_rdata[3] ,
    \hw/map_rdata[2] ,
    \hw/map_rdata[1] ,
    \hw/map_rdata[0] ,
    \hw/x[11] ,
    \hw/x[10] ,
    \hw/x[9] ,
    \hw/x[8] ,
    \hw/x[7] ,
    \hw/x[6] ,
    \hw/x[5] ,
    \hw/x[4] ,
    \hw/x[3] ,
    \hw/x[2] ,
    \hw/x[1] ,
    \hw/x[0] ,
    \hw/y[11] ,
    \hw/y[10] ,
    \hw/y[9] ,
    \hw/y[8] ,
    \hw/y[7] ,
    \hw/y[6] ,
    \hw/y[5] ,
    \hw/y[4] ,
    \hw/y[3] ,
    \hw/y[2] ,
    \hw/y[1] ,
    \hw/y[0] ,
    clk_27,
    tms_pad_i,
    tck_pad_i,
    tdi_pad_i,
    tdo_pad_o
);

input \hw/rgb_rdata[11] ;
input \hw/rgb_rdata[10] ;
input \hw/rgb_rdata[9] ;
input \hw/rgb_rdata[8] ;
input \hw/rgb_rdata[7] ;
input \hw/rgb_rdata[6] ;
input \hw/rgb_rdata[5] ;
input \hw/rgb_rdata[4] ;
input \hw/rgb_rdata[3] ;
input \hw/rgb_rdata[2] ;
input \hw/rgb_rdata[1] ;
input \hw/rgb_rdata[0] ;
input \hw/read_address[13] ;
input \hw/read_address[12] ;
input \hw/read_address[11] ;
input \hw/read_address[10] ;
input \hw/read_address[9] ;
input \hw/read_address[8] ;
input \hw/read_address[7] ;
input \hw/read_address[6] ;
input \hw/read_address[5] ;
input \hw/read_address[4] ;
input \hw/read_address[3] ;
input \hw/read_address[2] ;
input \hw/read_address[1] ;
input \hw/read_address[0] ;
input \hw/map_rdata[3] ;
input \hw/map_rdata[2] ;
input \hw/map_rdata[1] ;
input \hw/map_rdata[0] ;
input \hw/x[11] ;
input \hw/x[10] ;
input \hw/x[9] ;
input \hw/x[8] ;
input \hw/x[7] ;
input \hw/x[6] ;
input \hw/x[5] ;
input \hw/x[4] ;
input \hw/x[3] ;
input \hw/x[2] ;
input \hw/x[1] ;
input \hw/x[0] ;
input \hw/y[11] ;
input \hw/y[10] ;
input \hw/y[9] ;
input \hw/y[8] ;
input \hw/y[7] ;
input \hw/y[6] ;
input \hw/y[5] ;
input \hw/y[4] ;
input \hw/y[3] ;
input \hw/y[2] ;
input \hw/y[1] ;
input \hw/y[0] ;
input clk_27;
input tms_pad_i;
input tck_pad_i;
input tdi_pad_i;
output tdo_pad_o;

wire \hw/rgb_rdata[11] ;
wire \hw/rgb_rdata[10] ;
wire \hw/rgb_rdata[9] ;
wire \hw/rgb_rdata[8] ;
wire \hw/rgb_rdata[7] ;
wire \hw/rgb_rdata[6] ;
wire \hw/rgb_rdata[5] ;
wire \hw/rgb_rdata[4] ;
wire \hw/rgb_rdata[3] ;
wire \hw/rgb_rdata[2] ;
wire \hw/rgb_rdata[1] ;
wire \hw/rgb_rdata[0] ;
wire \hw/read_address[13] ;
wire \hw/read_address[12] ;
wire \hw/read_address[11] ;
wire \hw/read_address[10] ;
wire \hw/read_address[9] ;
wire \hw/read_address[8] ;
wire \hw/read_address[7] ;
wire \hw/read_address[6] ;
wire \hw/read_address[5] ;
wire \hw/read_address[4] ;
wire \hw/read_address[3] ;
wire \hw/read_address[2] ;
wire \hw/read_address[1] ;
wire \hw/read_address[0] ;
wire \hw/map_rdata[3] ;
wire \hw/map_rdata[2] ;
wire \hw/map_rdata[1] ;
wire \hw/map_rdata[0] ;
wire \hw/x[11] ;
wire \hw/x[10] ;
wire \hw/x[9] ;
wire \hw/x[8] ;
wire \hw/x[7] ;
wire \hw/x[6] ;
wire \hw/x[5] ;
wire \hw/x[4] ;
wire \hw/x[3] ;
wire \hw/x[2] ;
wire \hw/x[1] ;
wire \hw/x[0] ;
wire \hw/y[11] ;
wire \hw/y[10] ;
wire \hw/y[9] ;
wire \hw/y[8] ;
wire \hw/y[7] ;
wire \hw/y[6] ;
wire \hw/y[5] ;
wire \hw/y[4] ;
wire \hw/y[3] ;
wire \hw/y[2] ;
wire \hw/y[1] ;
wire \hw/y[0] ;
wire clk_27;
wire tms_pad_i;
wire tck_pad_i;
wire tdi_pad_i;
wire tdo_pad_o;
wire tms_i_c;
wire tck_i_c;
wire tdi_i_c;
wire tdo_o_c;
wire [9:0] control0;
wire gao_jtag_tck;
wire gao_jtag_reset;
wire run_test_idle_er1;
wire run_test_idle_er2;
wire shift_dr_capture_dr;
wire update_dr;
wire pause_dr;
wire enable_er1;
wire enable_er2;
wire gao_jtag_tdi;
wire tdo_er1;

IBUF tms_ibuf (
    .I(tms_pad_i),
    .O(tms_i_c)
);

IBUF tck_ibuf (
    .I(tck_pad_i),
    .O(tck_i_c)
);

IBUF tdi_ibuf (
    .I(tdi_pad_i),
    .O(tdi_i_c)
);

OBUF tdo_obuf (
    .I(tdo_o_c),
    .O(tdo_pad_o)
);

GW_JTAG  u_gw_jtag(
    .tms_pad_i(tms_i_c),
    .tck_pad_i(tck_i_c),
    .tdi_pad_i(tdi_i_c),
    .tdo_pad_o(tdo_o_c),
    .tck_o(gao_jtag_tck),
    .test_logic_reset_o(gao_jtag_reset),
    .run_test_idle_er1_o(run_test_idle_er1),
    .run_test_idle_er2_o(run_test_idle_er2),
    .shift_dr_capture_dr_o(shift_dr_capture_dr),
    .update_dr_o(update_dr),
    .pause_dr_o(pause_dr),
    .enable_er1_o(enable_er1),
    .enable_er2_o(enable_er2),
    .tdi_o(gao_jtag_tdi),
    .tdo_er1_i(tdo_er1),
    .tdo_er2_i(1'b0)
);

gw_con_top  u_icon_top(
    .tck_i(gao_jtag_tck),
    .tdi_i(gao_jtag_tdi),
    .tdo_o(tdo_er1),
    .rst_i(gao_jtag_reset),
    .control0(control0[9:0]),
    .enable_i(enable_er1),
    .shift_dr_capture_dr_i(shift_dr_capture_dr),
    .update_dr_i(update_dr)
);

ao_top u_ao_top(
    .control(control0[9:0]),
    .data_i({\hw/rgb_rdata[11] ,\hw/rgb_rdata[10] ,\hw/rgb_rdata[9] ,\hw/rgb_rdata[8] ,\hw/rgb_rdata[7] ,\hw/rgb_rdata[6] ,\hw/rgb_rdata[5] ,\hw/rgb_rdata[4] ,\hw/rgb_rdata[3] ,\hw/rgb_rdata[2] ,\hw/rgb_rdata[1] ,\hw/rgb_rdata[0] ,\hw/read_address[13] ,\hw/read_address[12] ,\hw/read_address[11] ,\hw/read_address[10] ,\hw/read_address[9] ,\hw/read_address[8] ,\hw/read_address[7] ,\hw/read_address[6] ,\hw/read_address[5] ,\hw/read_address[4] ,\hw/read_address[3] ,\hw/read_address[2] ,\hw/read_address[1] ,\hw/read_address[0] ,\hw/map_rdata[3] ,\hw/map_rdata[2] ,\hw/map_rdata[1] ,\hw/map_rdata[0] ,\hw/x[11] ,\hw/x[10] ,\hw/x[9] ,\hw/x[8] ,\hw/x[7] ,\hw/x[6] ,\hw/x[5] ,\hw/x[4] ,\hw/x[3] ,\hw/x[2] ,\hw/x[1] ,\hw/x[0] ,\hw/y[11] ,\hw/y[10] ,\hw/y[9] ,\hw/y[8] ,\hw/y[7] ,\hw/y[6] ,\hw/y[5] ,\hw/y[4] ,\hw/y[3] ,\hw/y[2] ,\hw/y[1] ,\hw/y[0] }),
    .clk_i(clk_27)
);

endmodule
