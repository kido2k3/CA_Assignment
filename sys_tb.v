`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 04/17/2023 03:18:56 PM
// Design Name: 
// Module Name: sys_tb
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


module sys_tb();
    reg   SYS_clk;
    wire  CLK_led;
    reg   SYS_reset;

    reg [2:0]  SYS_output_sel; //trong �'�? l�  7 bit nhưng chỉ cần 3 bit l�  �'ủ hiện thực
    
    // wire [7:0] F_PC;

    wire [26:0] SYS_leds;
    // wire [7:0] PC;
    // wire [31:0] testt_reg;
    //test
   system sy(
        //INPUT, giữ nguyên
        .clk                   (SYS_clk),
        .SYS_reset              (SYS_reset),
        .SYS_output_sel         (SYS_output_sel), //trong �'�? l�  7 bit nhưng chỉ cần 3 bit l�  �'ủ hiện thực

        //OUTPUT
        // .PC(PC),
        .SYS_leds (SYS_leds),
        .CLK_led (CLK_led)
        // .testt_reg (testt_reg)
    );
    initial begin
        SYS_clk=0;
        forever #1 SYS_clk =~ SYS_clk;

    end
    initial
        begin
             //ki?m tra gi? tr? thanh ghi s? 8
            SYS_output_sel = 2;
            SYS_reset = 0;
            #1 SYS_reset = 1;
            #3 SYS_reset = 0;
        end 
    // initial #250 $finish;
endmodule
