/*
 * test_top.sv
 *
 *  Created on: 2021-05-22 14:11
 *      Author: Jack Chen <redchenjs@live.com>
 */

`timescale 1ns / 1ps

module test_top;

logic clk_i;
logic rst_n_i;

logic dc_i;

logic spi_sclk_i;
logic spi_mosi_i;
logic spi_cs_n_i;
logic spi_miso_o;

logic sig_clk_i;

logic [3:0] aux_clk_i;
logic [3:0] aux_rst_n_i;

logic       spi_byte_vld;
logic [7:0] spi_byte_data;

logic       reg_rd_en;
logic [2:0] reg_rd_addr;
logic [7:0] reg_rd_data;

logic        reg_wr_en;
logic [63:0] reg_wr_data;

spi_slave spi_slave(
    .clk_i(clk_i),
    .rst_n_i(rst_n_i),

    .spi_byte_data_i(reg_rd_data),

    .spi_sclk_i(spi_sclk_i),
    .spi_mosi_i(spi_mosi_i),
    .spi_cs_n_i(spi_cs_n_i),

    .spi_miso_o(spi_miso_o),

    .spi_byte_vld_o(spi_byte_vld),
    .spi_byte_data_o(spi_byte_data)
);

regfile regfile(
    .clk_i(clk_i),
    .rst_n_i(rst_n_i),

    .reg_rd_addr_i(reg_rd_addr),

    .reg_wr_en_i(reg_wr_en & ~reg_rd_en),
    .reg_wr_data_i(reg_wr_data),

    .reg_rd_data_o(reg_rd_data)
);

control control(
    .clk_i(clk_i),
    .rst_n_i(rst_n_i),

    .dc_i(dc_i),

    .spi_byte_vld_i(spi_byte_vld),
    .spi_byte_data_i(spi_byte_data),

    .reg_rd_en_o(reg_rd_en),
    .reg_rd_addr_o(reg_rd_addr)
);

measure measure(
    .clk_i(clk_i),
    .rst_n_i(rst_n_i),

    .sig_clk_i(sig_clk_i),

    .ref_clk_i(aux_clk_i),
    .ref_rst_n_i(aux_rst_n_i),

    .reg_wr_en_o(reg_wr_en),
    .reg_wr_data_o(reg_wr_data)
);

initial begin
    clk_i   <= 1'b1;
    rst_n_i <= 1'b0;

    dc_i <= 1'b0;

    spi_cs_n_i <= 1'b1;
    spi_sclk_i <= 1'b0;
    spi_mosi_i <= 1'b0;

    sig_clk_i <= 1'b1;

    aux_clk_i   <= 4'h0;
    aux_rst_n_i <= 4'h0;

    #2 rst_n_i     <= 1'b1;
       aux_rst_n_i <= 4'hf;
end

always begin
    #2.4 clk_i <= ~clk_i;
end

always begin
    #250 sig_clk_i <= ~sig_clk_i;
end

always begin
    while (1) begin
        #2.4 aux_clk_i[0] <= ~aux_clk_i[0];
    end
end

always begin
    #1.2
    while (1) begin
        #2.4 aux_clk_i[1] <= ~aux_clk_i[1];
    end
end

always begin
    #2.4
    while (1) begin
        #2.4 aux_clk_i[2] <= ~aux_clk_i[2];
    end
end

always begin
    #3.6
    while (1) begin
        #2.4 aux_clk_i[3] <= ~aux_clk_i[3];
    end
end

always begin
    #50 spi_cs_n_i <= 1'b0;

    // DATA_RD
    #20 dc_i <= 1'b0;

    // 0x3B
    #15 spi_sclk_i <= 1'b0;
        spi_mosi_i <= 1'b0;  // BIT7
    #15 spi_sclk_i <= 1'b1;

    #15 spi_sclk_i <= 1'b0;
        spi_mosi_i <= 1'b0;  // BIT6
    #15 spi_sclk_i <= 1'b1;

    #15 spi_sclk_i <= 1'b0;
        spi_mosi_i <= 1'b1;  // BIT5
    #15 spi_sclk_i <= 1'b1;

    #15 spi_sclk_i <= 1'b0;
        spi_mosi_i <= 1'b1;  // BIT4
    #15 spi_sclk_i <= 1'b1;

    #15 spi_sclk_i <= 1'b0;
        spi_mosi_i <= 1'b1;  // BIT3
    #15 spi_sclk_i <= 1'b1;

    #15 spi_sclk_i <= 1'b0;
        spi_mosi_i <= 1'b0;  // BIT2
    #15 spi_sclk_i <= 1'b1;

    #15 spi_sclk_i <= 1'b0;
        spi_mosi_i <= 1'b1;  // BIT1
    #15 spi_sclk_i <= 1'b1;

    #15 spi_sclk_i <= 1'b0;
        spi_mosi_i <= 1'b1;  // BIT0
    #15 spi_sclk_i <= 1'b1;

    #20 dc_i <= 1'b1;

    for (integer i = 0; i < 64; i++) begin
        #15 spi_sclk_i <= 1'b0;
            spi_mosi_i <= 1'b0;
        #15 spi_sclk_i <= 1'b1;
    end

    #1000000 rst_n_i <= 1'b0;
    #25 $stop;
end

endmodule
