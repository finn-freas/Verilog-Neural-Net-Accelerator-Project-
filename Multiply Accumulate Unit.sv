// clr: acc = init (bias), en: acc += a*b, clr has priority

module mac (
    input  wire               clk,
    input  wire               rst_n,   // active low
    input  wire               clr,     // load init
    input  wire               en,      // accum
    input  wire signed [31:0] init,    // bias
    input  wire signed [7:0]  a,       // pixel
    input  wire signed [7:0]  b,       // wt
    output reg  signed [31:0] acc
);

    wire signed [15:0] prod = a * b;   // convert to 16 bits

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n)
            acc <= 32'sd0;
        else if (clr)
            acc <= init;
        else if (en)
            acc <= acc + {{16{prod[15]}}, prod};   // extend to 32 bits
        // else hold
    end

endmodule
