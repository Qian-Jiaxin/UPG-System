module UsartRx#(
    parameter COMMUNICATION_ERROR_CODE = 8'hFF
)(
    input  wire                      clk,
    input  wire                      rst_n,
    input  wire                      rx,
    output wire [7:0]                data,
    output reg                       done
);

    localparam IDLE              = 2'b00;
    localparam SAMPLING          = 2'b01;
    localparam CHECK             = 2'b10;

    localparam BPS9600 = 16'd20832;
    localparam BIT10 = 4'd9;
    localparam SAMPLING_MIDPOINT = BPS9600>>1;

    reg [1:0]       state, next_state;
    reg             pre_rx;
    reg [15:0]      bpscounts;
    reg [3:0]       bitcounts;
    reg [3:0]       oversampcounts;
    reg [9:0]       rx_buffer;

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
                    if (pre_rx & (!rx)) begin
                        next_state <= SAMPLING;
                    end
                end
                SAMPLING : begin
                    if ((bitcounts == BIT10)&(bpscounts == BPS9600 - 16'd5)) begin
                        next_state <= CHECK;
                    end
                end
                CHECK : begin
                    if (done) begin
                        next_state <= IDLE;
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
            pre_rx <= 1'b1;
        end
        else begin
            pre_rx <= rx;
        end
    end

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            bpscounts <= 16'd0;
        end
        else if (state == SAMPLING) begin
            if (bpscounts < BPS9600) begin
                bpscounts <= bpscounts + 1'd1;
            end
            else begin
                bpscounts <= 16'd0;
            end
        end
        else begin
            bpscounts <= 16'd0;
        end
    end

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            bitcounts <= 4'd0;
        end
        else if (state == SAMPLING) begin
            if (bpscounts >= BPS9600) begin
                bitcounts <= bitcounts + 1'd1;
            end
            else begin
                bitcounts <= bitcounts;
            end
        end
        else begin
            bitcounts <= 4'd0;
        end
    end

    always @(negedge clk or negedge rst_n) begin
        if (!rst_n) begin
            oversampcounts <=4'd0;
        end
        else if (state == SAMPLING) begin
            if (bpscounts >= BPS9600) begin
                oversampcounts <= 4'd0;
            end
            else begin
                case (bpscounts)
                    SAMPLING_MIDPOINT - 8'd40 : begin
                        oversampcounts <= oversampcounts + rx;
                    end 
                    SAMPLING_MIDPOINT - 8'd30 : begin
                        oversampcounts <= oversampcounts + rx;
                    end 
                    SAMPLING_MIDPOINT - 8'd20 : begin
                        oversampcounts <= oversampcounts + rx;
                    end 
                    SAMPLING_MIDPOINT - 8'd10 : begin
                        oversampcounts <= oversampcounts + rx;
                    end 
                    SAMPLING_MIDPOINT : begin
                        oversampcounts <= oversampcounts + rx;
                    end                 
                    SAMPLING_MIDPOINT + 8'd10 : begin
                        oversampcounts <= oversampcounts + rx;
                    end                 
                    SAMPLING_MIDPOINT + 8'd20 : begin
                        oversampcounts <= oversampcounts + rx;
                    end 
                    SAMPLING_MIDPOINT + 8'd30 : begin
                        oversampcounts <= oversampcounts + rx;
                    end
                    SAMPLING_MIDPOINT + 8'd40 : begin
                        oversampcounts <= oversampcounts + rx;
                    end
                    default : begin
                        oversampcounts <= oversampcounts;
                    end
                endcase
            end
        end
        else begin
            oversampcounts <=4'd0;
        end
    end

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            rx_buffer <= 10'd0;
        end
        else if (state == SAMPLING) begin
            if (bpscounts == (BPS9600 - 16'd100)) begin
                case (bitcounts)
                    4'd0 : begin
                        rx_buffer[0] <= (oversampcounts >= 4'd6) ? 1'd1 : 1'd0;
                    end
                    4'd1 : begin
                        rx_buffer[1] <= (oversampcounts >= 4'd6) ? 1'd1 : 1'd0;
                    end
                    4'd2 : begin
                        rx_buffer[2] <= (oversampcounts >= 4'd6) ? 1'd1 : 1'd0;
                    end
                    4'd3 : begin
                        rx_buffer[3] <= (oversampcounts >= 4'd6) ? 1'd1 : 1'd0;
                    end
                    4'd4 : begin
                        rx_buffer[4] <= (oversampcounts >= 4'd6) ? 1'd1 : 1'd0;
                    end
                    4'd5 : begin
                        rx_buffer[5] <= (oversampcounts >= 4'd6) ? 1'd1 : 1'd0;
                    end
                    4'd6 : begin
                        rx_buffer[6] <= (oversampcounts >= 4'd6) ? 1'd1 : 1'd0;
                    end
                    4'd7 : begin
                        rx_buffer[7] <= (oversampcounts >= 4'd6) ? 1'd1 : 1'd0;
                    end
                    4'd8 : begin
                        rx_buffer[8] <= (oversampcounts >= 4'd6) ? 1'd1 : 1'd0;
                    end
                    4'd9 : begin
                        rx_buffer[9] <= (oversampcounts >= 4'd6) ? 1'd1 : 1'd0;
                    end
                    default : begin
                        rx_buffer <= rx_buffer;
                    end
                endcase
            end
            else begin
                rx_buffer <= rx_buffer;
            end
        end
        else if (state == CHECK) begin
            rx_buffer <= rx_buffer;
        end
        else begin
            rx_buffer <= 10'd0;
        end
    end

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            done <= 1'd0;
        end
        else if ((bitcounts == BIT10)&(bpscounts == BPS9600 - 16'd5)) begin
            done <= 1'd1;
        end
        else begin
            done <= 1'd0;
        end
    end

    assign data = ((rx_buffer[0] == 1'd0)&(rx_buffer[9]==1'd1)) ? rx_buffer[8:1] : COMMUNICATION_ERROR_CODE;

endmodule
