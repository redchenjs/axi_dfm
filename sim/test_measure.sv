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

logic [3:0] ref_clk_i;
logic [3:0] ref_rst_n_i;

logic        reg_wr_en_o;
logic [63:0] reg_wr_data_o;

measure measure(
    .clk_i(clk_i),
    .rst_n_i(rst_n_i),

    .sig_clk_i(sig_clk_i),

    .ref_clk_i(ref_clk_i),
    .ref_rst_n_i(ref_rst_n_i),

    .reg_wr_en_o(reg_wr_en_o),
    .reg_wr_data_o(reg_wr_data_o)
);

initial begin
    clk_i   <= 1'b1;
    rst_n_i <= 1'b0;

    sig_clk_i <= 1'b1;

    ref_clk_i   <= 4'h0;
    ref_rst_n_i <= 4'h0;

    #2 rst_n_i     <= 1'b1;
       ref_rst_n_i <= 4'hf;
end

always begin
    #2.4 clk_i <= ~clk_i;
end

always begin
    #250 sig_clk_i <= ~sig_clk_i;
end

always begin
    while (1) begin
        #2.4 ref_clk_i[0] <= ~ref_clk_i[0];
    end
end

always begin
    #1.2
    while (1) begin
        #2.4 ref_clk_i[1] <= ~ref_clk_i[1];
    end
end

always begin
    #2.4
    while (1) begin
        #2.4 ref_clk_i[2] <= ~ref_clk_i[2];
    end
end

always begin
    #3.6
    while (1) begin
        #2.4 ref_clk_i[3] <= ~ref_clk_i[3];
    end
end

always begin
    #1000000 rst_n_i     <= 1'b0;
             ref_rst_n_i <= 4'h0;

    #25 $stop;
end

endmodule
