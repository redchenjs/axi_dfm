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

    output logic spi_miso_o
);

logic sys_clk;
logic sys_rst_n;

logic [4:0] gate_en;
logic [4:0] gate_sync;

logic       spi_byte_vld;
logic [7:0] spi_byte_data;

logic       raw_rd_en;
logic [3:0] raw_rd_addr;

logic       reg_rd_en;
logic [3:0] reg_rd_addr;
logic [7:0] reg_rd_data;

logic  [4:0] raw_wr_en;
logic [63:0] raw_wr_data[5];

logic        reg_wr_en;
logic [63:0] reg_wr_data;

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

    .reg_rd_en_o(raw_rd_en),
    .reg_rd_addr_o(raw_rd_addr)
);

startup startup(
    .clk_i(sys_clk),
    .rst_n_i(sys_rst_n),

    .gate_sync_i(gate_sync),

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

            .reg_wr_en_o(raw_wr_en[i]),
            .reg_wr_data_o(raw_wr_data[i]),

            .gate_sync_o(gate_sync[i])
        );
    end
endgenerate

always_ff @(posedge sys_clk or negedge sys_rst_n)
begin
    if (!sys_rst_n) begin
        reg_rd_en   <= 1'b0;
        reg_rd_addr <= 4'h0;

        reg_wr_en   <= 1'b0;
        reg_wr_data <= 64'h0000_0000_0000_0000;
    end else begin
        reg_rd_en   <= raw_rd_en;
        reg_rd_addr <= raw_rd_addr;

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

endmodule
