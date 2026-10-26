`timescale 1ns / 1ps

module tb_mult;
    reg        clk;
    reg        rst_n;
    reg  [3:0] a;
    reg  [3:0] b;
    wire [7:0] p;

    integer i, j, errors;
    reg [7:0] expected;

    mult_array uut (
        .clk(clk),
        .rst_n(rst_n),
        .a(a),
        .b(b),
        .p(p)
    );

    // 10 ns clock period
    initial clk = 0;
    always #5 clk = ~clk;

    initial begin
        $dumpfile("mult.vcd");
        $dumpvars(0, tb_mult);

        errors = 0;
        a = 4'd0;
        b = 4'd0;
        rst_n = 1'b0;

        // Hold rst_n low for the first 2 cycles (20 ns)
        #20;
        rst_n = 1'b1;

        // Apply all 256 input combinations
        for (i = 0; i < 16; i = i + 1) begin
            for (j = 0; j < 16; j = j + 1) begin
                // Apply inputs just after falling edge (5 ns before rising edge 1)
                @(negedge clk);
                a = i[3:0];
                b = j[3:0];
                expected = i * j;

                // Wait 2 rising clock edges for the 2-cycle latency
                @(posedge clk); // Edge 1: captured into a_reg, b_reg
                @(posedge clk); // Edge 2: product captured into p
                #2;             // Wait 1 ns after Edge 2 to read registered output

                if (p !== expected) begin
                    $display("ERROR: a=%0d, b=%0d | expected=%0d, got=%0d", a, b, expected, p);
                    errors = errors + 1;
                end
            end
        end

        if (errors == 0)
            $display("PASS: 256 vectors checked, 0 errors");
        else
            $display("FAIL: 256 vectors checked, %0d errors", errors);

        #20;
        $finish;
    end
endmodule