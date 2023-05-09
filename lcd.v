`define TWO_LINE            8'h38
`define INCREMENT_CURSOR    8'h06 
`define CLEAR_DISPLAY       8'h01
`define DISPLAYON_CURSOROFF 8'h0c 


module lcd_interface (        //đây là khối nhận input vào và xuất ra trên lcd
    input       SYS_clk,
    input       SYS_reset,
    input [7:0] PC,             //chỉ đơn giản là ghi lên
    input [2:0] SYS_output_sel,
    input [26:0] SYS_leds,

    output [14:4] pin
);
    reg RS;     
    reg EN;
    reg [7:0] DATA_out;
    wire  RW = 1'b0;

    assign pin[14:7] = DATA_out;
    assign pin[6]    = EN;
    assign pin[5]    = RW;
    assign pin[4]    = RS;

    wire us_clk;
    freq_divider us_divider(
        .SYS_clk    (SYS_clk),
        .SYS_reset  (SYS_reset), 
        .divided_clk(us_clk)
    );

    reg [31:0] state;

    always @(negedge us_clk, posedge SYS_reset) //sẽ cần giải thích vì sao lại chờ 1 microsecond
    begin
        if (SYS_reset)
        begin

        end

        else
        begin

        end
    end



endmodule


module freq_divider(
    input SYS_clk, SYS_reset,
    output reg divided_clk
);
    parameter divisor = 125;
    parameter m = divisor/2;
    integer count;
    
    always @(negedge clk, posedge SYS_reset)
    begin
        if (SYS_reset)
        begin
            count        <= 0;
            divided_clk  <= 1;
        end

        else
        begin
            if (count == m)
            begin
                count        <= 0;
                divided_clk  <= ~divided_clk;
            end
            else count <= count + 1;
        end
    end
endmodule