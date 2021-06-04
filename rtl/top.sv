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

    output logic spi_miso_o,

    output logic dbg_rst_n_o,
    output logic dbg_dc_o,
    output logic dbg_spi_sclk_o,
    output logic dbg_spi_mosi_o,
    output logic dbg_spi_cs_n_o,
    output logic dbg_spi_miso_o
);

logic sys_clk;
logic sys_rst_n;

logic       spi_byte_vld;
logic [7:0] spi_byte_data;

logic [31:0] gate_time;

logic       reg_rd_en;
logic [3:0] reg_rd_addr;
logic [7:0] reg_rd_data;

logic        reg_wr_en_a;
logic        reg_wr_en_b;
logic  [1:0] reg_wr_addr;
logic [63:0] reg_wr_data;

assign dbg_rst_n_o = rst_n_i;
assign dbg_dc_o = dc_i;
assign dbg_spi_sclk_o = spi_sclk_i;
assign dbg_spi_mosi_o = spi_mosi_i;
assign dbg_spi_cs_n_o = spi_cs_n_i;
assign dbg_spi_miso_o = spi_miso_o;

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

    .reg_rd_addr_i(reg_rd_addr),

    .reg_wr_en_i((reg_wr_en_a | reg_wr_en_b) & ~reg_rd_en),
    .reg_wr_addr_i({reg_wr_en_b, reg_wr_addr}),
    .reg_wr_data_i(reg_wr_en_b ? reg_wr_data : spi_byte_data),

    .reg_rd_data_o(reg_rd_data),

    .reg_gate_time_o(gate_time)
);

control control(
    .clk_i(sys_clk),
    .rst_n_i(sys_rst_n),

    .dc_i(dc_i),

    .spi_byte_vld_i(spi_byte_vld),
    .spi_byte_data_i(spi_byte_data),

    .reg_wr_en_o(reg_wr_en_a),
    .reg_wr_addr_o(reg_wr_addr),

    .reg_rd_en_o(reg_rd_en),
    .reg_rd_addr_o(reg_rd_addr)
);

measure measure(
    .clk_i(sys_clk),
    .rst_n_i(sys_rst_n),

    .sig_clk_i(sig_clk_i),

    .gate_time_i(gate_time),

    .reg_wr_en_o(reg_wr_en_b),
    .reg_wr_data_o(reg_wr_data)
);

endmodule
