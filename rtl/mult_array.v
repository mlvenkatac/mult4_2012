`timescale 1ns / 1ps

module mult_array(
    input            clk,
    input            rst_n,
    input      [3:0] a,
    input      [3:0] b,
    output reg [7:0] p
);
    // Input registers (8 flip-flops)
    reg [3:0] a_reg, b_reg;

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            a_reg <= 4'b0000;
            b_reg <= 4'b0000;
        end else begin
            a_reg <= a;
            b_reg <= b;
        end
    end

    // Partial products: 16 AND gates (pp_i[j] = a[j] AND b[i])
    wire [3:0] pp_0 = a_reg & {4{b_reg[0]}};
    wire [3:0] pp_1 = a_reg & {4{b_reg[1]}};
    wire [3:0] pp_2 = a_reg & {4{b_reg[2]}};
    wire [3:0] pp_3 = a_reg & {4{b_reg[3]}};

    // Row 0 outputs
    wire [3:0] r_0 = {1'b0, pp_0[3], pp_0[2], pp_0[1]};

    // Adder rows wires
    wire [3:0] s_1, s_2, s_3;
    wire [4:0] c_1, c_2, c_3;

    assign c_1[0] = 1'b0;
    assign c_2[0] = 1'b0;
    assign c_3[0] = 1'b0;

    // Row 1 (4 Full Adders)
    full_adder fa_r1_0 (.a(pp_1[0]), .b(r_0[0]), .cin(c_1[0]), .sum(s_1[0]), .cout(c_1[1]));
    full_adder fa_r1_1 (.a(pp_1[1]), .b(r_0[1]), .cin(c_1[1]), .sum(s_1[1]), .cout(c_1[2]));
    full_adder fa_r1_2 (.a(pp_1[2]), .b(r_0[2]), .cin(c_1[2]), .sum(s_1[2]), .cout(c_1[3]));
    full_adder fa_r1_3 (.a(pp_1[3]), .b(r_0[3]), .cin(c_1[3]), .sum(s_1[3]), .cout(c_1[4]));

    wire [3:0] r_1 = {c_1[4], s_1[3], s_1[2], s_1[1]};

    // Row 2 (4 Full Adders)
    full_adder fa_r2_0 (.a(pp_2[0]), .b(r_1[0]), .cin(c_2[0]), .sum(s_2[0]), .cout(c_2[1]));
    full_adder fa_r2_1 (.a(pp_2[1]), .b(r_1[1]), .cin(c_2[1]), .sum(s_2[1]), .cout(c_2[2]));
    full_adder fa_r2_2 (.a(pp_2[2]), .b(r_1[2]), .cin(c_2[2]), .sum(s_2[2]), .cout(c_2[3]));
    full_adder fa_r2_3 (.a(pp_2[3]), .b(r_1[3]), .cin(c_2[3]), .sum(s_2[3]), .cout(c_2[4]));

    wire [3:0] r_2 = {c_2[4], s_2[3], s_2[2], s_2[1]};

    // Row 3 (4 Full Adders)
    full_adder fa_r3_0 (.a(pp_3[0]), .b(r_2[0]), .cin(c_3[0]), .sum(s_3[0]), .cout(c_3[1]));
    full_adder fa_r3_1 (.a(pp_3[1]), .b(r_2[1]), .cin(c_3[1]), .sum(s_3[1]), .cout(c_3[2]));
    full_adder fa_r3_2 (.a(pp_3[2]), .b(r_2[2]), .cin(c_3[2]), .sum(s_3[2]), .cout(c_3[3]));
    full_adder fa_r3_3 (.a(pp_3[3]), .b(r_2[3]), .cin(c_3[3]), .sum(s_3[3]), .cout(c_3[4]));

    // Combinational 8-bit product assembly
    wire [7:0] p_comb = {c_3[4], s_3[3], s_3[2], s_3[1], s_3[0], s_2[0], s_1[0], pp_0[0]};

    // Output register (8 flip-flops)
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n)
            p <= 8'b00000000;
        else
            p <= p_comb;
    end
endmodule