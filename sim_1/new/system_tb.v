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

    reg [4:0] test_address_register;
    wire [31:0] test_value_register;

    integer i;

    system sy   (test_address_register,
                SYS_clk,
                SYS_reset,
                SYS_load,
                SYS_pc_val,
                SYS_output_sel,
                SYS_leds,
                test_value_register
                );
    initial
    begin
        SYS_reset = 1;
        #1 SYS_reset = 0;
        test_address_register = 8; //kiểm tra giá trị thanh ghi số 8

        SYS_clk=0;
        forever #8 SYS_clk=~SYS_clk;
    end  
    
    initial
    begin
        for(i = 0; i<1000; i=i+1)
        begin
            SYS_output_sel = i%8;
            #1;
        end
        
        $monitor("clk = %d, reset = %d, register %d, val = %d",SYS_clk, SYS_reset, test_address_register, test_value_register);
        // $display("sel = %b",SYS_output_sel);
        // $display("leds = %b",SYS_leds);
    end    
endmodule
