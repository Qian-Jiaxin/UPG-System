module UsartRx_Stream#(
    parameter COMMUNICATION_ERROR_CODE = 8'hFF,
    parameter HEAD0 = 8'hAB,
    parameter HEAD1 = 8'hBA
)
(
    input wire          clk,
    input wire          rst_n,
    input wire          usart_rx,
    output reg [7:0]    temperature,
    output reg [7:0]    busvoltage,
    output reg          cellstatus,
    output reg          done
);

    wire [7:0] data;
    wire byte_rx_done;
	 wire posedge_byte_rx_done;
    reg pre_byte_rx_done;
    reg [7:0] temperature_shadow;
    reg [7:0] busvoltage_shadow;
    reg [7:0] status_shadow;
    reg [7:0] CRC_shadow;
    reg crc_cs_n;
    wire crc_done;
    wire [7:0] CRC;


    UsartRx #(.COMMUNICATION_ERROR_CODE(COMMUNICATION_ERROR_CODE)) usartrx_inst(
        .clk(clk),
        .rst_n(rst_n),
        .rx(usart_rx),
        .data(data),
        .done(byte_rx_done)
    );

    CRC #(.BYTES(3), .DATA_WIDTH(8)) crc_inst(
        .clk(clk),
        .rst_n(rst_n),
        .crc_cs_n(crc_cs_n),
        .data_in({temperature_shadow, busvoltage_shadow, status_shadow}),
        .data_out(CRC),
        .crc_done(crc_done)
    );
    
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            pre_byte_rx_done <= 1'b0;
        end
        else begin
            pre_byte_rx_done <= byte_rx_done;
        end
    end

    assign posedge_byte_rx_done = (!pre_byte_rx_done) & byte_rx_done;

    localparam IDLE = 2'b00;
    localparam RECEIVE = 2'b01;
    localparam CHECK = 2'b10;

    reg [1:0] state;
    reg [7:0] pre_recdata, recdata;
    reg [3:0] counts;

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            state <= IDLE;
        end
        else begin
            case (state) 
                IDLE : begin
                    if ((pre_recdata == HEAD0)&(recdata == HEAD1)) begin
                        state <= RECEIVE;
                    end
                    else begin
                        state <= state;
                    end
                end
                RECEIVE : begin
                    if (counts == 4'd4) begin
                        state <= CHECK;
                    end
                    else begin
                        state <= state;
                    end
                end
                CHECK : begin
                    if (crc_done) begin
                        state <= IDLE;
                    end
                    else begin
                        state <= state;
                    end
                end
                default :;
            endcase

        end
    end

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            pre_recdata <= 8'b0;
            recdata <= data;
        end
        else if (posedge_byte_rx_done) begin
            pre_recdata <= recdata;
            recdata <= data;
        end
        else begin
            pre_recdata <= pre_recdata;
            recdata <= recdata;
        end
    end

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            counts <= 4'b0;
        end
        else if (state == RECEIVE) begin
            if (posedge_byte_rx_done) begin
                counts <= counts + 1'd1;
            end
            else begin
                counts <= counts;
            end
        end
        else begin
            counts <= 4'b0;
        end
    end

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            temperature_shadow <= 8'd0;
            busvoltage_shadow <= 8'd0;
            status_shadow <= 8'd0;
            CRC_shadow <= 8'd0;
        end
        else if ((state == RECEIVE)) begin
            if (counts == 4'd1) begin
                temperature_shadow <= recdata;
            end
            else if (counts == 4'd2) begin
                busvoltage_shadow <= recdata;
            end
            else if (counts == 4'd3) begin
                status_shadow <= recdata;
            end
            else if (counts ==4'd4) begin
                CRC_shadow <= recdata;
            end
        end
        else begin
            temperature_shadow <= temperature_shadow;
            busvoltage_shadow <= busvoltage_shadow;
            status_shadow <= status_shadow;
            CRC_shadow <= CRC_shadow;
        end
    end

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            crc_cs_n <= 1'b1;
        end
        else if (state == CHECK) begin
            crc_cs_n <= 1'b0;
        end
        else begin
            crc_cs_n <= 1'b1;
        end
    end

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            temperature <= 8'd0;
            busvoltage <= 8'd0;
            cellstatus <= 1'd0;
        end
        else if (crc_done) begin
            if (CRC == CRC_shadow) begin
                temperature <= temperature_shadow;
                busvoltage <= busvoltage_shadow;
                cellstatus <= (status_shadow == 8'b0) ? 1'b0 : 1'b1;
            end
            else begin
                temperature <= COMMUNICATION_ERROR_CODE;
                busvoltage <= COMMUNICATION_ERROR_CODE;
                cellstatus <= 1'b1;
            end
        end
        else begin
            temperature <= temperature;
            busvoltage <= busvoltage;
            cellstatus <= cellstatus;
        end
    end

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            done <= 1'b0;
        end
        else if (crc_done) begin
            done <= 1'b1;
        end
        else begin
            done <= 1'b0;
        end
    end

endmodule
