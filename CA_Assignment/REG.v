`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 03/22/2023 08:45:31 PM
// Design Name: 
// Module Name: REG
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


module REG(
input [4:0] REG_address1,
input [4:0] REG_address2, 
input [4:0] REG_address_wr, 
input REG_write_1, 
input [31:0] REG_data_wb_in1, 
input clk,
input SYS_reset,

output reg [31:0] REG_data_out1, 
output reg [31:0] REG_data_out2
);
    reg [31:0] register [0:31];
    integer i;

    always @(REG_address1, REG_address2, REG_address_wr, REG_write_1, REG_data_wb_in1)
    begin
        if (REG_address1 == REG_address_wr)
        begin
            if (REG_write_1)
                REG_data_out1 <= REG_data_wb_in1;
            else
                REG_data_out1 <= register[REG_address1];
        end
        else
            REG_data_out1 <= register[REG_address1];

        if (REG_address2 == REG_address_wr)
        begin
            if (REG_write_1)
                REG_data_out2 <= REG_data_wb_in1;
            else
                REG_data_out2 <= register[REG_address2];
        end
        else
            REG_data_out2 <= register[REG_address2];
    end


    always @(negedge clk, posedge SYS_reset)
    begin 
        if (SYS_reset)
        begin
            for(i = 0; i<32 ; i=i+1)
                register[i] <= 32'b0;
        end

        else if(REG_write_1)
            register[REG_address_wr] <= REG_data_wb_in1;
    end

endmodule