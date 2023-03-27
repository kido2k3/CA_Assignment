`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 03/27/2023 05:42:37 PM
// Design Name: 
// Module Name: system_tb
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module system_tb;
reg SYS_clk;
reg SYS_reset;
reg SYS_load;
reg [7:0] SYS_pc_val;
reg [7 :0] SYS_output_sel;
wire [26:0] SYS_leds;
integer i;

system sy   (SYS_clk,SYS_reset,SYS_load,SYS_pc_val,SYS_output_sel,SYS_leds
            );
initial
    begin
     SYS_reset = 0;
     SYS_load = 0;

        SYS_clk=0;
        forever
        #8 SYS_clk=~SYS_clk;
  
    end  
initial
    begin
        for(i = 0; i<1000; i=i+1)
            begin
              SYS_output_sel = i%8;
              #1;
            end
            $display("clk = %d reset = %d load = %d val = %b",SYS_clk, SYS_reset, SYS_load, SYS_pc_val);
            $display("sel = %b",SYS_output_sel);
            $display("leds = %b",SYS_leds);
    end    
endmodule
