module PulseGenerate#(
    parameter DATA_WIDTH = 8)
(
    input  wire                      clk,
    input  wire                      rst_n,
    input  wire                      st_trigger,
    input  wire[(DATA_WIDTH<<2)-1:0] pulsewidth,
    input  wire[DATA_WIDTH-1:0]      sync_delay,
    output wire                      pulse_out
);

    localparam IDLE              = 2'b00;
    localparam WAIT_SYNC_DELAY   = 2'b01;
    localparam PULSE_GENERATE    = 2'b10;

    reg [1:0]                   next_state;
    reg [1:0]                   state;
    reg                         pre_st_trigger;
    reg [(DATA_WIDTH<<2)-1:0]   pulsewidth_shadow;
    reg [DATA_WIDTH-1:0]        sync_delay_shadow;
    reg [DATA_WIDTH-1:0]        counts_trigger_delay;
    reg [11:0]                  counts_pulse_generate;

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
                    if ((pre_st_trigger) & (!st_trigger)) begin
                        next_state <= WAIT_SYNC_DELAY;
                    end
						  else begin
								next_state <= next_state;
						  end
                end
                WAIT_SYNC_DELAY : begin
                    if (counts_trigger_delay == sync_delay_shadow) begin
                        next_state <= PULSE_GENERATE;
                    end
						  else begin
								next_state <= next_state;
						  end
						  
                end
                PULSE_GENERATE : begin
                    if (counts_pulse_generate == pulsewidth_shadow) begin
                        next_state <= IDLE;
                    end
						  else begin
								next_state <= next_state;
						  end
                end
                default: begin
							next_state <= IDLE;
					end
            endcase
        end
    end

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            pre_st_trigger <= 1'b1;
        end
        else begin
            pre_st_trigger <= st_trigger;
        end
    end

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            pulsewidth_shadow <= {(4*DATA_WIDTH){1'b0}};
            sync_delay_shadow <= {DATA_WIDTH{1'b0}};
        end
        else if (state == IDLE) begin
            pulsewidth_shadow <= pulsewidth;
            sync_delay_shadow <= sync_delay;
        end
        else begin
            pulsewidth_shadow <= pulsewidth_shadow;
            sync_delay_shadow <= sync_delay_shadow;
        end
    end

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            counts_trigger_delay <= {DATA_WIDTH{1'b0}};
        end
        else if (state == WAIT_SYNC_DELAY) begin
            counts_trigger_delay <= counts_trigger_delay + 1'b1;
        end
        else begin
            counts_trigger_delay <= {DATA_WIDTH{1'b0}};
        end
    end

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            counts_pulse_generate <= 12'd0;
        end
        else if (state == PULSE_GENERATE) begin
            counts_pulse_generate <= counts_pulse_generate + 1'b1;
        end
        else begin
            counts_pulse_generate <= 12'd0;
        end
    end

    assign pulse_out = (state == PULSE_GENERATE);

endmodule

