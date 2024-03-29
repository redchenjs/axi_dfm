/*
 * test_startup.sv
 *
 *  Created on: 2020-07-19 18:00
 *      Author: Jack Chen <redchenjs@live.com>
 */

`timescale 1ns / 1ps

module test_startup;

logic clk_i;
logic rst_n_i;

logic  [4:0] gate_sync_i;
logic [31:0] gate_shift_i;

logic [4:0] gate_en_o;

startup startup(
    .clk_i(clk_i),
    .rst_n_i(rst_n_i),

    .gate_sync_i(gate_sync_i),
    .gate_shift_i(gate_shift_i),

    .gate_en_o(gate_en_o)
);

initial begin
    clk_i   <= 1'b1;
    rst_n_i <= 1'b0;

    gate_shift_i <= 32'd99;

    #2 rst_n_i <= 1'b1;
end

always begin
    #2.4 clk_i <= ~clk_i;
end

always_ff @(posedge clk_i or negedge rst_n_i)
begin
    if (!rst_n_i) begin
        gate_sync_i <= 5'b00000;
    end else begin
        gate_sync_i <= gate_en_o;
    end
end

always begin
    #10000000 rst_n_i <= 1'b0;

    #25 $stop;
end

endmodule
