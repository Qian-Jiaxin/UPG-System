module Sys_Controller#(
    parameter USART_ERROR_CODE = 8'hFF,
    parameter USART_HEAD0 = 8'hAB,
    parameter USART_HEAD1 = 8'hBA,
    parameter ADDR_WIDTH = 4'h07,
    parameter DATA_WIDTH = 4'h08
)(
    input   wire                        clk,
    input   wire                        rst_n,

    input   wire                        st_trigger_n,
    input   wire [27:0]                 usart_rx_bus,
    output  wire [27:0]                 pulse_out_bus,

    input   wire                        st_cs_n,
    input   wire                        st_rden_n,
    input   wire                        st_wren_n,
    input   wire [ADDR_WIDTH-1:0]       st_address,
    input   wire [DATA_WIDTH-1:0]       st_data_in,
    output  wire [DATA_WIDTH-1:0]       st_data_out,

    output  reg                         st_waring
);

    localparam IDEL = 3'b000;
    localparam CHECK = 3'b001;
    localparam EXCUTE = 3'b010;
    localparam ERROR = 3'b011; 
    reg [2:0] state, next_state;
    reg [1:0] wr_state;
    reg [7:0] st_waring_delay;
    reg [2:0] crc_rd_done_counts;
    reg [2:0] crc_wr_done_counts;

    reg  pre_st_trigger_n;
    reg  trigger_n;
    reg  crc_cs_wr_n, crc_cs_rd_n;

    wire negedge_st_trigger_n;
    wire [27:0] usartstream_done_bus;
    wire crc_temperature_done;
    wire crc_busvoltage_done;
    wire crc_status_done;
    wire crc_syncdelay_done;
    wire crc_pulsewidth_done;
    wire crc_enableid_done;
    wire [DATA_WIDTH-1:0] sync_delay_crc_rec;
    wire [DATA_WIDTH-1:0] sync_delay_crc_cal;
    wire [DATA_WIDTH-1:0] pulsewidth_crc_rec;
    wire [DATA_WIDTH-1:0] pulsewidth_crc_cal;
    wire [DATA_WIDTH-1:0] enable_id_crc_rec;
    wire [DATA_WIDTH-1:0] enable_id_crc_cal;
    
    Sys_Connect #(.USART_ERROR_CODE(USART_ERROR_CODE), .USART_HEAD0(USART_HEAD0), .USART_HEAD1(USART_HEAD1), .ADDR_WIDTH(ADDR_WIDTH), .DATA_WIDTH(DATA_WIDTH)) sys_connect_inst(
        .clk(clk),
        .rst_n(rst_n),

        .trigger_n(trigger_n),
        .usart_rx_bus(usart_rx_bus),
        .pulse_out_bus(pulse_out_bus),

        .st_cs_n(st_cs_n),
        .st_rden_n(st_rden_n),
        .st_wren_n(st_wren_n),
        .st_address(st_address),
        .st_data_in(st_data_in),
        .st_data_out(st_data_out),

        .crc_cs_wr_n(crc_cs_wr_n),
        .crc_cs_rd_n(crc_cs_rd_n),
        .usartstream_done_bus(usartstream_done_bus),
        .crc_temperature_done(crc_temperature_done),
        .crc_busvoltage_done(crc_busvoltage_done),
        .crc_status_done(crc_status_done),
        .crc_syncdelay_done(crc_syncdelay_done),
        .crc_pulsewidth_done(crc_pulsewidth_done),
        .crc_enableid_done(crc_enableid_done),

        .sync_delay_crc_rec(sync_delay_crc_rec),
        .sync_delay_crc_cal(sync_delay_crc_cal),
        .pulsewidth_crc_rec(pulsewidth_crc_rec),
        .pulsewidth_crc_cal(pulsewidth_crc_cal),
        .enable_id_crc_rec(enable_id_crc_rec),
        .enable_id_crc_cal(enable_id_crc_cal)
    );

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            pre_st_trigger_n <= 1'b1;
        end
        else begin
            pre_st_trigger_n <= st_trigger_n;
        end
    end

    assign negedge_st_trigger_n = (!st_trigger_n) &pre_st_trigger_n;

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin  
            state <= IDEL;
        end
        else begin
            state <= next_state;
        end
    end
    always @(*) begin
        if (!rst_n) begin
            next_state <= IDEL;
        end
        else begin
            case (state)
                IDEL : begin
                    if (negedge_st_trigger_n) begin
                        next_state <= CHECK;
                    end
                    else begin
                        next_state <= next_state;
                    end
                end
                CHECK : begin
                    if (crc_rd_done_counts == 3'd3) begin
                        if ((sync_delay_crc_rec == sync_delay_crc_cal) & (pulsewidth_crc_rec == pulsewidth_crc_cal) & (enable_id_crc_rec == enable_id_crc_cal)) begin
                            next_state <= EXCUTE;
                        end
                        else begin
                            next_state <= ERROR;
                        end
                    end
                    else begin
                        next_state <= next_state;
                    end
                end
                EXCUTE : begin
                    next_state <= IDEL;
                end
                ERROR : begin
                    if (st_waring_delay == 8'hff) begin
                        next_state <= IDEL;
                    end
                    else begin
                        next_state <= ERROR;
                    end
                end
                default : begin
                    next_state <= IDEL;
                end
            endcase
        end
    end

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            crc_cs_rd_n <= 1'b1;
            crc_rd_done_counts <= 3'b0;
        end
        else if (state == CHECK) begin
            crc_cs_rd_n <= 1'b0;
            crc_rd_done_counts <= crc_rd_done_counts + crc_syncdelay_done + crc_pulsewidth_done + crc_enableid_done;
        end
        else begin
            crc_cs_rd_n <= 1'b1;
            crc_rd_done_counts <= 3'b0;
        end
    end

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            trigger_n <= 1'b1;
        end
        else if (state == EXCUTE) begin
            trigger_n <= 1'b0;
        end
        else begin
            trigger_n <= 1'b1;
        end
    end

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            st_waring_delay <=8'd0;
        end
        else if (state == ERROR) begin
            st_waring_delay <= st_waring_delay + 1'd1;
        end
        else begin
            st_waring_delay <= 8'd0;
        end
    end

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            wr_state <= 2'b00;
        end
        else begin
            case (wr_state)
                2'b00 : begin
                    if (usartstream_done_bus != {28'b0}) begin
                        wr_state <= 2'b01;
                    end
                    else begin
                        wr_state <= wr_state;
                    end
                end
                2'b01 : begin
                    if (crc_wr_done_counts == 3'd3) begin
                        wr_state <= 2'b10;
                    end
                    else begin
                        wr_state <= wr_state;
                    end
                end
                2'b10 : begin
                    wr_state <= 2'b11;
                end
                2'b11 : begin
                    wr_state <= 2'b00;
                end
                default : begin
                    wr_state <= 2'b00;
                end
            endcase
        end
    end

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            crc_cs_wr_n <= 1'b1;
            crc_wr_done_counts <= 3'b0;
        end
        else if (wr_state == 2'b01) begin
            crc_cs_wr_n <= 1'b0;
            crc_wr_done_counts <= crc_wr_done_counts + crc_temperature_done + crc_busvoltage_done + crc_status_done;
        end
        else begin
            crc_cs_wr_n <= 1'b1;
            crc_wr_done_counts <= 3'b0;
        end
    end

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            st_waring <= 1'b0;
        end
        else if (state == ERROR) begin
            st_waring <= 1'b1;
        end
        else if (wr_state > 2'b01) begin
            st_waring <= 1'b1;
        end
        else begin
            st_waring <= 1'b0;
        end
    end

endmodule

module Sys_Connect #(
    parameter USART_ERROR_CODE = 8'hFF,
    parameter USART_HEAD0 = 8'hAB,
    parameter USART_HEAD1 = 8'hBA,
    parameter ADDR_WIDTH = 4'h07,
    parameter DATA_WIDTH = 4'h08
)(
    input   wire                        clk,
    input   wire                        rst_n,

    input   wire                        trigger_n,
    input   wire [27:0]                 usart_rx_bus,
    output  wire [27:0]                 pulse_out_bus,

    input   wire                        st_cs_n,
    input   wire                        st_rden_n,
    input   wire                        st_wren_n,
    input   wire [ADDR_WIDTH-1:0]       st_address,
    input   wire [DATA_WIDTH-1:0]       st_data_in,
    output  wire [DATA_WIDTH-1:0]       st_data_out,

    input   wire                        crc_cs_wr_n,
    input   wire                        crc_cs_rd_n,
    output  wire [27:0]                 usartstream_done_bus,
    output  wire                        crc_temperature_done,
    output  wire                        crc_busvoltage_done,
    output  wire                        crc_status_done,
    output  wire                        crc_syncdelay_done,
    output  wire                        crc_pulsewidth_done,
    output  wire                        crc_enableid_done,

    output  wire [DATA_WIDTH-1:0]       sync_delay_crc_rec,
    output  wire [DATA_WIDTH-1:0]       sync_delay_crc_cal,
    output  wire [DATA_WIDTH-1:0]       pulsewidth_crc_rec,
    output  wire [DATA_WIDTH-1:0]       pulsewidth_crc_cal,
    output  wire [DATA_WIDTH-1:0]       enable_id_crc_rec,
    output  wire [DATA_WIDTH-1:0]       enable_id_crc_cal
);

    wire  [DATA_WIDTH-1:0]      temperature       [0:27];
    wire  [DATA_WIDTH-1:0]      busvoltage        [0:27];
    wire  [DATA_WIDTH-1:0]      sync_delay        [0:27];
    wire                        cellstatus        [0:27];
    wire                        usartstream_done  [0:27];
    wire                        enable_id         [0:27];
    wire                        usart_rx          [0:27];
    wire                        pulse_out         [0:27];
    wire  [DATA_WIDTH*28-1:0]   temperature_bus;
    wire  [DATA_WIDTH*28-1:0]   busvoltage_bus;
    wire  [DATA_WIDTH*28-1:0]   sync_delay_bus;
    wire  [31:0]                status_32b;
    wire  [31:0]                enable_id_32b;
    wire  [31:0]                pulsewidth;
    wire  [DATA_WIDTH-1:0]      temperature_crc_cal;
    wire  [DATA_WIDTH-1:0]      busvoltage_crc_cal;
    wire  [DATA_WIDTH-1:0]      status_crc_cal;
    
    assign temperature_bus = {
        temperature[27], temperature[26], temperature[25], temperature[24],
        temperature[23], temperature[22], temperature[21], temperature[20],
        temperature[19], temperature[18], temperature[17], temperature[16],
        temperature[15], temperature[14], temperature[13], temperature[12],
        temperature[11], temperature[10], temperature[9],  temperature[8],
        temperature[7],  temperature[6],  temperature[5],  temperature[4],
        temperature[3],  temperature[2],  temperature[1],  temperature[0]
    };
    assign busvoltage_bus = {
        busvoltage[27], busvoltage[26], busvoltage[25], busvoltage[24],
        busvoltage[23], busvoltage[22], busvoltage[21], busvoltage[20],
        busvoltage[19], busvoltage[18], busvoltage[17], busvoltage[16],
        busvoltage[15], busvoltage[14], busvoltage[13], busvoltage[12],
        busvoltage[11], busvoltage[10], busvoltage[9],  busvoltage[8],
        busvoltage[7],  busvoltage[6],  busvoltage[5],  busvoltage[4],
        busvoltage[3],  busvoltage[2],  busvoltage[1],  busvoltage[0]
    };
    assign status_32b = { 4'b0, 
        cellstatus[27], cellstatus[26], cellstatus[25], cellstatus[24],
        cellstatus[23], cellstatus[22], cellstatus[21], cellstatus[20],
        cellstatus[19], cellstatus[18], cellstatus[17], cellstatus[16],
        cellstatus[15], cellstatus[14], cellstatus[13], cellstatus[12],
        cellstatus[11], cellstatus[10], cellstatus[9],  cellstatus[8],
        cellstatus[7],  cellstatus[6],  cellstatus[5],  cellstatus[4],
        cellstatus[3],  cellstatus[2],  cellstatus[1],  cellstatus[0]
    };
    assign usartstream_done_bus = {
        usartstream_done[27], usartstream_done[26], usartstream_done[25], usartstream_done[24],
        usartstream_done[23], usartstream_done[22], usartstream_done[21], usartstream_done[20],
        usartstream_done[19], usartstream_done[18], usartstream_done[17], usartstream_done[16],
        usartstream_done[15], usartstream_done[14], usartstream_done[13], usartstream_done[12],
        usartstream_done[11], usartstream_done[10], usartstream_done[9],  usartstream_done[8],
        usartstream_done[7],  usartstream_done[6],  usartstream_done[5],  usartstream_done[4],
        usartstream_done[3],  usartstream_done[2],  usartstream_done[1],  usartstream_done[0]
    };
    assign pulse_out_bus = {
        pulse_out[27], pulse_out[26], pulse_out[25], pulse_out[24],
        pulse_out[23], pulse_out[22], pulse_out[21], pulse_out[20],
        pulse_out[19], pulse_out[18], pulse_out[17], pulse_out[16],
        pulse_out[15], pulse_out[14], pulse_out[13], pulse_out[12],
        pulse_out[11], pulse_out[10], pulse_out[9],  pulse_out[8],
        pulse_out[7],  pulse_out[6],  pulse_out[5],  pulse_out[4],
        pulse_out[3],  pulse_out[2],  pulse_out[1],  pulse_out[0]
    };

    genvar i;
    generate
        for (i = 0; i < 28; i = i + 1) begin : unpack_signals
            assign sync_delay[i] = sync_delay_bus[i*DATA_WIDTH +: DATA_WIDTH];
            assign enable_id[i] = enable_id_32b[i +: 1'b1];
            assign usart_rx[i] = usart_rx_bus[i +: 1'b1];
        end
    endgenerate

    generate
        for (i = 0; i<28; i = i+1) begin : cell_controller_inst
            // 自动生成实例名称
            Cell_Controller #(.USART_ERROR_CODE(USART_ERROR_CODE), .USART_HEAD0(USART_HEAD0), .USART_HEAD1(USART_HEAD1), .DATA_WIDTH(DATA_WIDTH)) cell_controller_inst (
                .clk(clk),
                .rst_n(rst_n),
                .en(enable_id[i]),
                
                .usart_rx(usart_rx[i]),
                .temperature(temperature[i]),
                .busvoltage(busvoltage[i]),
                .cellstatus(cellstatus[i]),
                .usartstream_done(usartstream_done[i]),
                
                .trigger_n(trigger_n),
                .pulsewidth(pulsewidth),
                .sync_delay(sync_delay[i]),
                .pulse_out(pulse_out[i])
            );
        end
    endgenerate

    Distribute#(.ADDR_WIDTH(ADDR_WIDTH), .DATA_WIDTH(DATA_WIDTH)) distribute_inst(
        .clk(clk),
        .rst_n(rst_n),
        .st_cs_n(st_cs_n),
        .st_rden_n(st_rden_n),
        .st_wren_n(st_wren_n),
        .st_address(st_address),
        .st_data_in(st_data_in),
        .st_data_out(st_data_out),

        .temperature_bus(temperature_bus),
        .temperature_crc(temperature_crc_cal),

        .busvoltage_bus(busvoltage_bus),
        .busvoltage_crc(busvoltage_crc_cal),

        .status_32b(status_32b),
        .status_crc(status_crc_cal),
         
        .sync_delay_bus(sync_delay_bus),
        .sync_delay_crc(sync_delay_crc_rec),

        .pulsewidth_32b(pulsewidth),
        .pulsewidth_crc(pulsewidth_crc_rec),

        .enable_id_32b(enable_id_32b),
        .enable_id_crc(enable_id_crc_rec)
    );

    // wire crc_temperature_done;
    CRC #(.BYTES(8'd28), .DATA_WIDTH(DATA_WIDTH)) crc_temperature_inst(
        .clk(clk),
        .rst_n(rst_n),
        .crc_cs_n(crc_cs_wr_n),
        .data_in(temperature_bus),
        .data_out(temperature_crc_cal),
        .crc_done(crc_temperature_done)
    );

    // wire crc_busvoltage_done;
    CRC #(.BYTES(8'd28), .DATA_WIDTH(DATA_WIDTH)) crc_busvoltage_inst(
        .clk(clk),
        .rst_n(rst_n),
        .crc_cs_n(crc_cs_wr_n),
        .data_in(busvoltage_bus),
        .data_out(busvoltage_crc_cal),
        .crc_done(crc_busvoltage_done)
    );

    // wire crc_status_done;
    CRC #(.BYTES(8'd4), .DATA_WIDTH(DATA_WIDTH)) crc_status_inst(
        .clk(clk),
        .rst_n(rst_n),
        .crc_cs_n(crc_cs_wr_n),
        .data_in(status_32b),
        .data_out(status_crc_cal),
        .crc_done(crc_status_done)
    );

    // wire crc_syncdelay_done;
    CRC #(.BYTES(8'd28), .DATA_WIDTH(DATA_WIDTH)) crc_syncdelay_inst(
        .clk(clk),
        .rst_n(rst_n),
        .crc_cs_n(crc_cs_rd_n),
        .data_in(sync_delay_bus),
        .data_out(sync_delay_crc_cal),
        .crc_done(crc_syncdelay_done)
    );

    // wire crc_pulsewidth_done;
    CRC #(.BYTES(8'd4), .DATA_WIDTH(DATA_WIDTH)) crc_pulsewidth_inst(
        .clk(clk),
        .rst_n(rst_n),
        .crc_cs_n(crc_cs_rd_n),
        .data_in(pulsewidth),
        .data_out(pulsewidth_crc_cal),
        .crc_done(crc_pulsewidth_done)
    );

    // wire crc_enableid_done;
    CRC #(.BYTES(8'd4), .DATA_WIDTH(DATA_WIDTH)) crc_enableid_inst(
        .clk(clk),
        .rst_n(rst_n),
        .crc_cs_n(crc_cs_rd_n),
        .data_in(enable_id_32b),
        .data_out(enable_id_crc_cal),
        .crc_done(crc_enableid_done)
    );

endmodule
