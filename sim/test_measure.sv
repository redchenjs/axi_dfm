/*
 * test_ram_rw.sv
 *
 *  Created on: 2020-07-19 18:00
 *      Author: Jack Chen <redchenjs@live.com>
 */

`timescale 1ns / 1ps

module test_measure;

logic clk_i;
logic rst_n_i;

logic sig_clk_i;

logic       gate_st_i;
logic [7:0] gate_time_i;

logic        reg_wr_en_o;
logic [63:0] reg_wr_data_o;

measure measure(
    .clk_i(clk_i),
    .rst_n_i(rst_n_i),

    .sig_clk_i(sig_clk_i),

    .gate_st_i(gate_st_i),
    .gate_time_i(gate_time_i),

    .reg_wr_en_o(reg_wr_en_o),
    .reg_wr_data_o(reg_wr_data_o)
);

initial begin
    clk_i   <= 1'b1;
    rst_n_i <= 1'b0;

    sig_clk_i  <= 1'b1;

    gate_st_i   <= 1'b0;
    gate_time_i <= 8'h0a;

    #2 rst_n_i <= 1'b1;
end

always begin
    #2.5 clk_i <= ~clk_i;
end

always begin
    #250 sig_clk_i <= ~sig_clk_i;
end

always begin
    #5 gate_st_i <= 1'b1;
    #5 gate_st_i <= 1'b0;

    #1000 rst_n_i <= 1'b0;
    #25 $stop;
end

endmodule
