
module vga_ram (
    input clk,	
	input wen, 
	input [13:0] waddr,
	input [11:0] wdata,	
    input ren,	
	input [13:0] raddr,		    	
    output reg [11:0] rdata
);
	//parameter MEM_INIT_FILE = "vid_ram.mem";
	(* ram_style = "block" *) reg [11:0] ram [0:12287];   //  memory for 16 character with dimension 16x16 pixels @ 12bpp
                                                          //4095 for 640x480; 12287 for 1280x720;
	//initial
	//if (MEM_INIT_FILE != "")
	//	$readmemh(MEM_INIT_FILE, ram);
	reg [11:0] pipeline_reg; //Additional register for pipeline
	
    //Without pipeline
    always @(posedge clk) 
	begin
		if (ren)
			rdata <= ram[raddr];
	end	

    //With pipeline
    /*always @(posedge clk) begin
        if (ren)
            pipeline_reg <= ram[raddr]; //First read from RAM
    end

    always @(posedge clk) begin
        rdata <= pipeline_reg; //Passing data from pipeline register to output
    end*/
			
    always @(posedge clk) 
	begin			
		if (wen)
			ram[waddr] <= wdata;
    end
	
endmodule
