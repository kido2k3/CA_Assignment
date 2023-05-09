`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 05/09/2023 02:56:20 PM
// Design Name: 
// Module Name: freq_divider
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


module freq_divider(
    input SYS_clk, SYS_reset,
    output divided_clk
);
    reg out;
    parameter divisor = 250_000_000;
    //parameter divisor = 1;
    parameter m = divisor/2;
    integer count;
    
    always @(negedge SYS_clk, posedge SYS_reset)
    begin
        if (SYS_reset)
        begin
            count        <= 0;
            out  <= 1;
        end

        else
        begin
            if (count >= m)
            begin
                count        <= 0;
                out  <= ~out;
            end
            else count <= count + 1;
        end
    end
    assign divided_clk = out;
endmodule
