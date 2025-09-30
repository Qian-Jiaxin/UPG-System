module CRC #(
    parameter BYTES = 4,
    parameter DATA_WIDTH = 4'h08
)(
    input wire clk,
    input wire rst_n,
    input wire crc_cs_n,
    input wire [BYTES*DATA_WIDTH-1:0] data_in,
    output reg [7:0] data_out,
    output reg crc_done
);
    localparam POLY = 8'b00000111;

    localparam COUNTS_COMPARE = BYTES*DATA_WIDTH;

    localparam IDLE = 2'b00;
    localparam CHECKING = 2'b01;

    reg [1:0] state;
    reg [1:0] next_state;
    reg pre_crc_cs_n;
    reg [7:0] counts;
    reg [BYTES*DATA_WIDTH-1:0] data_in_shadow;
    reg [7:0] data_out_shadow;

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            pre_crc_cs_n <= 1'b1;
        end
        else begin
            pre_crc_cs_n <= crc_cs_n;
        end
    end

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            state <= IDLE;
        end
        else begin
            state <= next_state;
        end
    end

    always @(*) begin
        if (!rst_n) begin
            next_state <= IDLE;
        end 
        else begin
            case (state)
                IDLE : begin
                    if (pre_crc_cs_n & (!crc_cs_n)) begin
                        next_state <= CHECKING;
                    end
                    else begin
                        next_state <= next_state;
                    end
                end
                CHECKING : begin
                    if (counts == COUNTS_COMPARE) begin
                        next_state <= IDLE;
                    end
                    else begin
                        next_state <= next_state;
                    end
                end
                default : begin
                    next_state <= IDLE;
                end
            endcase
        end
    end

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            counts <= 8'b0;
        end
        else if (state == CHECKING) begin
            counts <= counts + 1'b1;
        end
        else begin
            counts <= 8'b0;
        end
    end

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            {data_out_shadow, data_in_shadow} <= {data_in, 8'b0};
        end
        else if (state == CHECKING) begin
            if (data_out_shadow[7] == 1'b1) begin
                data_out_shadow[7] <= data_out_shadow[6];
                data_out_shadow[6] <= data_out_shadow[5];
                data_out_shadow[5] <= data_out_shadow[4];
                data_out_shadow[4] <= data_out_shadow[3];
                data_out_shadow[3] <= data_out_shadow[2];
                data_out_shadow[2] <= ~data_out_shadow[1];
                data_out_shadow[1] <= ~data_out_shadow[0];
                data_out_shadow[0] <= ~data_in_shadow[BYTES*DATA_WIDTH-1];
                data_in_shadow <= data_in_shadow << 1;
            end
            else begin
                {data_out_shadow, data_in_shadow} <= {data_out_shadow, data_in_shadow} << 1;
            end
        end
        else begin
            {data_out_shadow, data_in_shadow} <= {data_in, 8'b0};
        end
    end

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            crc_done <= 1'b0;
            data_out <= 8'd0;
        end
        else if (counts == COUNTS_COMPARE) begin
            crc_done <= 1'b1;
            data_out <= data_out_shadow;
        end
        else begin
            crc_done <= 1'b0;
            data_out <= data_out;
        end
    end

endmodule

