`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 03/24/2023 09:53:30 PM
// Design Name: 
// Module Name: ALU
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


module ALU(
    input           [3:0] control,
    input signed    [31:0] a,
    input signed    [31:0] b,
    input           [4:0] shamt,

    output signed   [31:0] result_out,
    output          [7:0] status_out
);
    reg [63:0] mul_ALU;
    reg [7:0] status;
    reg signed [31:0] result;
    assign status_out = status;
    assign result_out = result;
    always @(*)
    begin
        case (control)
        0: begin
            result = a&b;//and
            status[7] = (result == 0);
            status[6] = 1'b0;
            status[4] = 1'b0;
            status[5] = 1'b0;
            status[3] = 1'b0;
            status[2] = 1'b0;
            mul_ALU = 0;
            end
        1: begin
            result = a|b;//or
            status[7] = (result == 0);
            status[6] = 1'b0;
            status[4] = 1'b0;
            status[5] = 1'b0;
            status[3] = 1'b0;
            status[2] = 1'b0;
            mul_ALU = 0;
            end
        10:begin
            result = (~a&b)|(~b&a);//xor
            status[7] = (result == 0);
            status[6] = 1'b0;
            status[4] = 1'b0;
            status[5] = 1'b0;
            status[3] = 1'b0;
            status[2] = 1'b0;
            mul_ALU = 0;
            end
        11:begin
            result = ~(a|b);//nor
            status[7] = (result == 0);
            status[6] = 1'b0;
            status[4] = 1'b0;
            status[5] = 1'b0;
            status[3] = 1'b0;
            status[2] = 1'b0;
            mul_ALU = 0;
            end
        2: begin
            {status[5],result} = a+b;
            status[7] = (result == 0);
            status[6] = 1'b0;
            status[4] = result[31];
                            
            status[3] = (result%4) ? 1'b1 : 1'b0; //không align word
            status[2] = 1'b0;
            mul_ALU = 0;
            end
        6: begin
            {status[5],result} = a-b;
            status[7] = (result == 0);
            status[6] = 1'b0;
            status[4] = result[31];
                                
            status[3] = 1'b0;
            status[2] = 1'b0;
            mul_ALU = 0;
            end
        5: begin
            mul_ALU = a*b;
            result = mul_ALU[31:0];
            status[7] = (result == 0);
            // status[6] = (mul_ALU[63:32] || status[5])? 1'b1 : 1'b0; status [5] là cái gì? lúc này đã tính xong chưa?
            status[6] = (mul_ALU[63:32])? 1'b1 : 1'b0;
            status[4] = result[31];
            status[5] = 1'b0;
            status[3] = 1'b0;
            status[2] = 1'b0;
            end
        4: begin
            result = (b) ? a/b : 0;
            status[7] = (result == 0);
            status[6] = 1'b0;
            status[4] = result[31];
            status[5] = 1'b0;
            status[3] = 1'b0;
            status[2] = (b) ? 1'b0 : 1'b1;
            mul_ALU = 0;
            end
        12:begin    //sra
            result = b>>>shamt;
            status[7] = (result == 0);
            status[6] = 1'b0;
            status[4] = 1'b0;
            status[5] = 1'b0;
            status[3] = 1'b0;
            status[2] = 1'b0;
            mul_ALU = 0;
            end
        13:begin
            result = a+b;
            status[7] = (result == 0);
            status[6] = 1'b0;
            status[4] = result[31];
            status[5] = 1'b0;
            status[3] = 1'b0; //không align word
            status[2] = 1'b0;
            mul_ALU = 0;
            end
        7: begin
            result = a-b;
            result = (result[31]) ? 1 : 0;
            status[7] = (result == 0);
            status[6] = 1'b0;
            status[4] = result[31];
            status[5] = 1'b0;
            status[3] = 1'b0;
            status[2] = 1'b0;
            mul_ALU = 0;
            end
        8: begin    //sll
            result = b<<shamt;
            status[7] = (result == 0);
            status[6] = 1'b0;
            status[4] = 1'b0;
            status[5] = 1'b0;
            status[3] = 1'b0;
            status[2] = 1'b0;
            mul_ALU = 0;
            end
        9: begin    //srl
            result = b>>shamt;
            status[7] = (result == 0);
            status[6] = 1'b0;
            status[4] = 1'b0;
            status[5] = 1'b0;
            status[3] = 1'b0;
            status[2] = 1'b0;
            mul_ALU = 0;
            end
        default: 
        begin
            result = 0;
            status[7] = (result == 0);
            status[6] = 1'b0;
            status[4] = 1'b0;
            status[5] = 1'b0;
            status[3] = 1'b0;
            status[2] = 1'b0;
            mul_ALU = 0;
        end
        endcase
        status[1] = 1'b0;
        status[0] = 1'b0;
    end
endmodule
