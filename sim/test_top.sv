/*
 * test_top.sv
 *
 *  Created on: 2021-05-22 14:11
 *      Author: Jack Chen <redchenjs@live.com>
 */

`timescale 1ns / 1ps

module test_top;

localparam [31:0] DEFAULT_GATE_TIME_SHIFT = 32'd199;
localparam [31:0] DEFAULT_GATE_TIME_TOTAL = 32'd999;

logic clk_i;
logic rst_n_i;

logic dc_i;

logic spi_sclk_i;
logic spi_mosi_i;
logic spi_cs_n_i;
logic spi_miso_o;

logic sig_clk_i;

wire sys_clk   = clk_i;
wire sys_rst_n = rst_n_i;

logic [4:0] gate_en;
logic [4:0] gate_sync;

logic       spi_byte_vld;
logic [7:0] spi_byte_data;

logic       reg_rd_en;
logic [3:0] reg_rd_addr;
logic [7:0] reg_rd_data;

logic  [4:0] raw_wr_en;
logic [63:0] raw_wr_data[5];

logic        reg_wr_en;
logic [63:0] reg_wr_data;

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

    .reg_rd_en_i(reg_rd_en),
    .reg_rd_addr_i(reg_rd_addr),

    .reg_wr_en_i(reg_wr_en),
    .reg_wr_data_i(reg_wr_data),

    .reg_rd_data_o(reg_rd_data)
);

control control(
    .clk_i(sys_clk),
    .rst_n_i(sys_rst_n),

    .dc_i(dc_i),

    .spi_byte_vld_i(spi_byte_vld),
    .spi_byte_data_i(spi_byte_data),

    .reg_rd_en_o(reg_rd_en),
    .reg_rd_addr_o(reg_rd_addr)
);

startup startup(
    .clk_i(sys_clk),
    .rst_n_i(sys_rst_n),

    .gate_sync_i(gate_sync),
    .gate_shift_i(DEFAULT_GATE_TIME_SHIFT),

    .gate_en_o(gate_en)
);

genvar i;
generate
    for (i = 0; i < 5; i++) begin: measure_block
        measure measure(
            .clk_i(sys_clk),
            .rst_n_i(sys_rst_n),

            .sig_clk_i(sig_clk_i),

            .gate_en_i(gate_en[i]),
            .gate_total_i(DEFAULT_GATE_TIME_TOTAL),

            .reg_wr_en_o(raw_wr_en[i]),
            .reg_wr_data_o(raw_wr_data[i]),

            .gate_sync_o(gate_sync[i])
        );
    end
endgenerate

always_ff @(posedge sys_clk or negedge sys_rst_n)
begin
    if (!sys_rst_n) begin
        reg_wr_en   <= 1'b0;
        reg_wr_data <= 64'h0000_0000_0000_0000;
    end else begin
        reg_wr_en <= raw_wr_en[0] | raw_wr_en[1] | raw_wr_en[2] | raw_wr_en[3] | raw_wr_en[4];

        case (raw_wr_en)
            5'b00001:
                reg_wr_data <= raw_wr_data[0];
            5'b00010:
                reg_wr_data <= raw_wr_data[1];
            5'b00100:
                reg_wr_data <= raw_wr_data[2];
            5'b01000:
                reg_wr_data <= raw_wr_data[3];
            5'b10000:
                reg_wr_data <= raw_wr_data[4];
            default:
                reg_wr_data <= reg_wr_data;
        endcase
    end
end

initial begin
    clk_i   <= 1'b1;
    rst_n_i <= 1'b0;

    dc_i <= 1'b0;

    spi_cs_n_i <= 1'b1;
    spi_sclk_i <= 1'b0;
    spi_mosi_i <= 1'b0;

    sig_clk_i <= 1'b1;

    #2 rst_n_i <= 1'b1;
end

always begin
    #2.4 clk_i <= ~clk_i;
end

always begin
    #250 sig_clk_i <= ~sig_clk_i;
end

always begin
    #5000000
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

    #10 rst_n_i <= 1'b0;
    #25 $stop;
end

endmodule
