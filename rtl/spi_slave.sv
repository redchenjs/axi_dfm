/*
 * spi_slave.sv
 *
 *  Created on: 2020-04-06 23:07
 *      Author: Jack Chen <redchenjs@live.com>
 */

module spi_slave(
    input logic clk_i,
    input logic rst_n_i,

    input logic [7:0] spi_byte_data_i,

    input logic spi_sclk_i,
    input logic spi_mosi_i,
    input logic spi_cs_n_i,

    output logic spi_miso_o,

    output logic       spi_byte_vld_o,
    output logic [7:0] spi_byte_data_o
);

logic spi_rst_n;

logic       bit_st;
logic [2:0] bit_sel;

logic       byte_vld;
logic [7:0] byte_recv;
logic [7:0] byte_send;

logic [7:0] byte_mosi;
logic [7:0] byte_miso;

assign spi_miso_o = byte_miso[7];

assign spi_byte_vld_o  = byte_vld;
assign spi_byte_data_o = byte_recv;

rst_syn spi_rst_n_syn(
    .clk_i(clk_i),
    .rst_n_i(rst_n_i & ~spi_cs_n_i),
    .rst_n_o(spi_rst_n)
);

edge2en spi_sclk_en(
    .clk_i(clk_i),
    .rst_n_i(spi_rst_n),
    .data_i(bit_st & (bit_sel == 3'h0)),
    .pos_edge_o(byte_vld)
);

always_ff @(posedge spi_sclk_i or negedge spi_rst_n)
begin
    if (!spi_rst_n) begin
        bit_st  <= 1'b0;
        bit_sel <= 3'h0;

        byte_mosi <= 8'h00;
    end else begin
        bit_st  <= 1'b1;
        bit_sel <= bit_sel + 1'b1;

        byte_mosi <= {byte_mosi[6:0], spi_mosi_i};
    end
end

always_ff @(negedge spi_sclk_i or negedge spi_rst_n)
begin
    if (!spi_rst_n) begin
        byte_miso <= 8'h00;
    end else begin
        byte_miso <= (bit_sel == 3'h0) ? byte_send : {byte_miso[6:0], 1'b0};
    end
end

always_ff @(posedge byte_vld or negedge spi_rst_n)
begin
    if (!spi_rst_n) begin
        byte_recv <= 8'h00;
    end else begin
        byte_recv <= byte_mosi;
    end
end

always_ff @(negedge byte_vld or negedge spi_rst_n)
begin
    if (!spi_rst_n) begin
        byte_send <= 8'h00;
    end else begin
        byte_send <= spi_byte_data_i;
    end
end

endmodule
