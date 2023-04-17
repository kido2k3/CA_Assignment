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

    reg        SYS_load;
    reg [7:0]  SYS_pc_val;
    reg [2:0]  SYS_output_sel; //trong Ä'á»? lÃ  7 bit nhÆ°ng chá»‰ cáº§n 3 bit lÃ  Ä'á»§ hiá»‡n thá»±c
    
    wire[26:0] SYS_leds;
    //test
    reg [4:0] test_address_register; //chá»‰ dÃ nh cho test, test xong xÃ³a, Ä'á»ƒ xem Ä'á»‹a chá»‰ register Ä'Ã£ cháº¡y Ä'Ãºng chÆ°a
    wire [31:0] test_value_register;          //chá»‰ dÃ nh cho test, test xong xÃ³a, Ä'á»ƒ xem giÃ¡ trá»‹ register Ä'Ã£ cháº¡y Ä'Ãºng chÆ°a
    wire [7:0] out_pc;
    wire [31:0] out_ins;    
    wire [31:0] out_ALU;
    wire out_exc;
    wire [31:0] data_in_mem;
    system(
        SYS_clk,
        SYS_reset,

        SYS_load,
        SYS_pc_val,
        SYS_output_sel, //trong Ä'á»? lÃ  7 bit nhÆ°ng chá»‰ cáº§n 3 bit lÃ  Ä'á»§ hiá»‡n thá»±c
    
        SYS_leds,
    //test
        test_address_register, //chá»‰ dÃ nh cho test, test xong xÃ³a, Ä'á»ƒ xem Ä'á»‹a chá»‰ register Ä'Ã£ cháº¡y Ä'Ãºng chÆ°a
        test_value_register,          //chá»‰ dÃ nh cho test, test xong xÃ³a, Ä'á»ƒ xem giÃ¡ trá»‹ register Ä'Ã£ cháº¡y Ä'Ãºng chÆ°a
        out_pc,
        out_ins,    
        out_ALU,
        out_exc,
        data_in_mem
);
endmodule
