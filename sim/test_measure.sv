/*
 * test_measure.sv
 *
 *  Created on: 2020-07-19 18:00
 *      Author: Jack Chen <redchenjs@live.com>
 */

`timescale 1ns / 1ps

module test_measure;

logic clk_i;
logic rst_n_i;

logic sig_clk_i;

logic        gate_en_i;
logic [31:0] gate_total_i;

logic        reg_wr_en_o;
logic [63:0] reg_wr_data_o;

logic gate_sync_o;

measure measure(
    .clk_i(clk_i),
    .rst_n_i(rst_n_i),

    .sig_clk_i(sig_clk_i),

    .gate_en_i(gate_en_i),
    .gate_total_i(gate_total_i),

    .reg_wr_en_o(reg_wr_en_o),
    .reg_wr_data_o(reg_wr_data_o),

    .gate_sync_o(gate_sync_o)
);

initial begin
    clk_i   <= 1'b1;
    rst_n_i <= 1'b0;

    sig_clk_i  <= 1'b1;

    gate_en_i    <= 1'b1;
    gate_total_i <= 32'd499;

    #2 rst_n_i <= 1'b1;
end

always begin
    #2.5 clk_i <= ~clk_i;
end

always begin
    #250 sig_clk_i <= ~sig_clk_i;
end

always begin
    #10000000 rst_n_i <= 1'b0;

    #25 $stop;
end

endmodule
