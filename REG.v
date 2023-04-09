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
input [4:0] test_address_register, //chỉ dành cho test, test xong xóa, để xem địa chỉ register đã chạy đúng chưa

output[31:0] REG_data_out1, 
output[31:0] REG_data_out2,
output [31:0] test_value_register          //chỉ dành cho test, test xong xóa, để xem giá trị register đã chạy đúng chưa
    );
    reg [31:0] register [0:31];
    integer i;
    initial
        begin 
        for(i = 0; i<32 ; i=i+1)
        register[i] = 32'b0;
        end
    assign REG_data_out1 = register[REG_address1];
    assign REG_data_out2 = register[REG_address2];
    //always @(posedge clk)
    always @(posedge clk)
    begin 
    if(REG_write_1)
        register[REG_address_wr] = REG_data_wb_in1;
    end

    assign test_value_register = register[test_address_register];
endmodule
