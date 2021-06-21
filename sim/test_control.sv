/*
 * test_control.sv
 *
 *  Created on: 2020-07-19 18:00
 *      Author: Jack Chen <redchenjs@live.com>
 */

`timescale 1ns / 1ps

module test_control;

logic clk_i;
logic rst_n_i;

logic dc_i;

logic       spi_byte_vld_i;
logic [7:0] spi_byte_data_i;

logic       reg_rd_en_o;
logic [3:0] reg_rd_addr_o;

control control (
    .clk_i(clk_i),
    .rst_n_i(rst_n_i),

    .dc_i(dc_i),

    .spi_byte_vld_i(spi_byte_vld_i),
    .spi_byte_data_i(spi_byte_data_i),

    .reg_rd_en_o(reg_rd_en_o),
    .reg_rd_addr_o(reg_rd_addr_o)
);

initial begin
    clk_i   <= 1'b1;
    rst_n_i <= 1'b0;

    dc_i <= 1'b0;

    spi_byte_vld_i  <= 1'b0;
    spi_byte_data_i <= 8'h00;

    #2 rst_n_i <= 1'b1;
end

always begin
    #2.5 clk_i <= ~clk_i;
end

always begin
    // DATA_RD
    #40 dc_i <= 1'b0;
        spi_byte_vld_i  <= 1'b1;
        spi_byte_data_i <= 8'h3b;
    #5  spi_byte_vld_i  <= 1'b0;

    // DUMMY DATA
    for (integer i = 0; i < 32; i++) begin
        #40 dc_i <= 1'b1;
            spi_byte_vld_i  <= 1'b1;
            spi_byte_data_i <= 1'b0;
        #5  spi_byte_vld_i  <= 1'b0;
    end

    #75 rst_n_i <= 1'b0;
    #25 $stop;
end

endmodule
