/*
 * top.sv
 *
 *  Created on: 2020-07-19 17:33
 *      Author: Jack Chen <redchenjs@live.com>
 */

module digital_frequency_meter(
    input logic clk_i,          // clk_i = 12 MHz
    input logic rst_n_i,        // rst_n_i, active low

    input logic dc_i,

    input logic spi_sclk_i,
    input logic spi_mosi_i,
    input logic spi_cs_n_i,

    input logic sig_clk_i,

    output logic gate_sync_o,
    output logic spi_miso_o
);

logic sys_clk;
logic sys_rst_n;

logic       spi_byte_vld;
logic [7:0] spi_byte_data;

logic        reg_wr_en;
logic [63:0] reg_wr_data;

logic [2:0] reg_rd_addr;
logic [7:0] reg_rd_data;

logic       gate_st;
logic [7:0] gate_time;

sys_ctl sys_ctl(
    .clk_i(clk_i),
    .rst_n_i(rst_n_i),

    .sys_clk_o(sys_clk),
    .sys_rst_n_o(sys_rst_n)
);

spi_slave spi_slave(
    .clk_i(sys_clk),
    .rst_n_i(sys_rst_n),

    .spi_byte_data_i(reg_rd_data),

    .spi_sclk_i(spi_sclk_i),
    .spi_mosi_i(spi_mosi_i),
    .spi_cs_n_i(spi_cs_n_i),

    .spi_miso_o(spi_miso_o),

    .spi_byte_vld_o(spi_byte_vld),
    .spi_byte_data_o(spi_byte_data)
);

regfile regfile(
    .clk_i(sys_clk),
    .rst_n_i(sys_rst_n),

    .reg_wr_en_i(reg_wr_en),
    .reg_wr_data_i(reg_wr_data),

    .reg_rd_addr_i(reg_rd_addr),
    .reg_rd_data_o(reg_rd_data)
);

control control(
    .clk_i(sys_clk),
    .rst_n_i(sys_rst_n),

    .dc_i(dc_i),

    .spi_byte_vld_i(spi_byte_vld),
    .spi_byte_data_i(spi_byte_data),

    .gate_st_o(gate_st),
    .gate_time_o(gate_time),

    .reg_rd_addr_o(reg_rd_addr)
);

measure measure(
    .clk_i(sys_clk),
    .rst_n_i(sys_rst_n),

    .sig_clk_i(sig_clk_i),

    .gate_st_i(gate_st),
    .gate_time_i(gate_time),

    .gate_sync_o(gate_sync_o),

    .reg_wr_en_o(reg_wr_en),
    .reg_wr_data_o(reg_wr_data)
);

endmodule
