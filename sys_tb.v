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
    reg   SYS_reset;

    reg [2:0]  SYS_output_sel; //trong �'�? l�  7 bit nhưng chỉ cần 3 bit l�  �'ủ hiện thực
    
    // wire [7:0] F_PC;
    wire [31:0] F_instruction, D_instruction, EX_instruction, MEM_instruction, WB_instruction;
    // wire D_stall;
    // wire [1:0] MEM_to_D_forwardSignal;

    wire        WB_RegWrite_signal;
    wire [31:0] WB_write_data;
    wire [4:0]  WB_write_register;
    wire [2:0]  WB_exception_signal;
    wire [10:0] EX_control_signal;
    // wire [4:0] D_Reg_address1 = D_instruction[25:21], D_Reg_address2 = D_instruction[20:16];
    // wire [31:0] D_REG_data_out1, D_REG_data_out2;
    reg [31:0] testt_reg_add;
    wire [31:0]testt_reg;

    //test
   system #(.divisor(1))sy(
        //INPUT, giữ nguyên
        .clk                   (SYS_clk),
        .SYS_reset              (SYS_reset),
        .SYS_output_sel         (SYS_output_sel), //trong �'�? l�  7 bit nhưng chỉ cần 3 bit l�  �'ủ hiện thực

        //OUTPUT
        .SYS_leds               (SYS_leds)

    );
    initial begin
        SYS_clk=0;
        forever #5 SYS_clk =~ SYS_clk;

    end
    initial
        begin
             //ki?m tra gi? tr? thanh ghi s? 8
            SYS_reset = 0;
            SYS_output_sel = 0;
            #1 SYS_reset = 1;
            #11 SYS_reset = 0;
        end 
    initial #250 $finish;
endmodule
