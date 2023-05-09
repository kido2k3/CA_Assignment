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
    
    wire [7:0] F_PC;
    wire [31:0] F_instruction;
    wire [31:0] D_instruction;
    wire [31:0] EX_instruction, MEM_instruction, WB_instruction;
    
    wire        WB_RegWrite_signal;
    wire [4:0]  WB_write_register;
    wire [31:0] WB_write_data;
    
    wire [2:0]EX_exception_signal;
    wire [31:0] EX_a_operand, EX_b_operand;
    reg [31:0] testt_reg_add;
    wire [31:0]testt_reg;

    //test
   system sy(
        //INPUT, giữ nguyên
        .SYS_clk(SYS_clk),
        .SYS_reset(SYS_reset),
        .SYS_output_sel(SYS_output_sel), //trong �'�? l�  7 bit nhưng chỉ cần 3 bit l�  �'ủ hiện thực
        .testt_reg_add(testt_reg_add),

        //OUTPUT
        .testt_reg(testt_reg),
        .PC (F_PC),
        .F_instruction(F_instruction),
        .D_instruction(D_instruction),
        .EX_instruction(EX_instruction),
        .MEM_instruction(MEM_instruction),
        .WB_instruction(WB_instruction),
        .EX_exception_signal(EX_exception_signal),
        .EX_a_operand(EX_a_operand),
        .EX_b_operand(EX_b_operand),
        .WB_RegWrite_signal(WB_RegWrite_signal),
        .WB_write_register(WB_write_register),
        .WB_write_data(WB_write_data)
    );
    initial begin
        SYS_clk=0;
        forever #5 SYS_clk =~ SYS_clk;

    end
    initial
        begin
             //ki?m tra gi? tr? thanh ghi s? 8
            testt_reg_add = 9;
            SYS_reset = 0;
            SYS_output_sel = 2;
            #1 SYS_reset = 1;
            #2 SYS_reset = 0;
        end 
endmodule
