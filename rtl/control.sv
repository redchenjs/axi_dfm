/*
 * control.sv
 *
 *  Created on: 2020-07-19 18:00
 *      Author: Jack Chen <redchenjs@live.com>
 */

module control(
    input logic clk_i,
    input logic rst_n_i,

    input logic dc_i,

    input logic       spi_byte_vld_i,
    input logic [7:0] spi_byte_data_i,

    output logic       reg_rd_en_o,
    output logic [2:0] reg_rd_addr_o
);

typedef enum logic [7:0] {
    DATA_RD = 8'h3b
} cmd_t;

logic       rd_en;
logic [2:0] rd_addr;

assign reg_rd_en_o   = rd_en & spi_byte_vld_i;
assign reg_rd_addr_o = rd_addr;

always_ff @(posedge clk_i or negedge rst_n_i)
begin
    if (!rst_n_i) begin
        rd_en   <= 1'b0;
        rd_addr <= 3'h0;
    end else begin
        if (spi_byte_vld_i) begin
            if (!dc_i) begin  // Command
                if (spi_byte_data_i == DATA_RD) begin
                    rd_en <= 1'b1;
                end else begin
                    rd_en <= 1'b0;
                end

                rd_addr <= 3'h0;
            end else begin    // Data
                rd_en   <= 1'b0;
                rd_addr <= rd_addr + 1'b1;
            end
        end
    end
end

endmodule
