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

    output logic       gate_st_o,
    output logic [7:0] gate_time_o,

    output logic [2:0] reg_rd_addr_o
);

typedef enum logic [7:0] {
    SET_ST = 8'h2a,
    REG_RD = 8'h3a
} cmd_t;

logic set_wr_en;

logic       gate_st;
logic [7:0] gate_time;

logic [2:0] reg_rd_addr;

assign gate_st_o   = gate_st & spi_byte_vld_i;
assign gate_time_o = gate_time;

assign reg_rd_addr_o = reg_rd_addr;

always_ff @(posedge clk_i or negedge rst_n_i)
begin
    if (!rst_n_i) begin
        gate_st   <= 1'b0;
        gate_time <= 8'h00;

        set_wr_en <= 1'b0;

        reg_rd_addr <= 32'h0000_0000;
    end else begin
        if (spi_byte_vld_i) begin
            if (!dc_i) begin  // Command
                gate_time <= gate_time;

                case (spi_byte_data_i)
                    SET_ST: begin
                        gate_st <= 1'b1;
    
                        set_wr_en <= 1'b0;
                    end
                    default: begin
                        gate_st <= 1'b0;
    
                        set_wr_en <= 1'b0;
                    end
                endcase

                reg_rd_addr <= 32'h0000_0000;
            end else begin    // Data
                set_wr_en <= 1'b0;

                gate_st <= 1'b0;
                gate_time <= set_wr_en ? spi_byte_data_i : gate_time;

                reg_rd_addr <= reg_rd_addr + 1'b1;
            end
        end
    end
end

endmodule
